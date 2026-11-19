import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

/// Cuaca dari Open-Meteo (https://open-meteo.com) — gratis untuk penggunaan
/// non-komersial dan tidak memerlukan API key.
///
/// Satu panggilan mengambil 30 hari riwayat + 4 hari prakiraan per jam, lalu
/// diringkas menjadi data harian untuk algoritma prediksi hama:
/// curah hujan 24 jam asli, jam daun basah, akumulasi derajat-hari, dan
/// penentuan musim dengan kriteria dasarian BMKG.
class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const Duration _cacheTtl = Duration(minutes: 10);
  static const int _pastDays = 30;

  /// Ambang jam basah: RH >= 90% atau ada hujan pada jam itu. Pendekatan umum
  /// untuk menduga lama daun basah (leaf wetness) tanpa sensor fisik.
  static const double _wetRh = 90.0;

  static final Map<String, _CacheEntry> _cache = {};

  Future<WeatherModel> getWeatherByLocation(double lat, double lng) async {
    final bundle = await _load(lat, lng);
    return bundle.current;
  }

  /// Prakiraan untuk besok (ringkasan harian).
  Future<WeatherModel> getForecastByLocation(double lat, double lng) async {
    final bundle = await _load(lat, lng);
    return bundle.tomorrow;
  }

  // ── Pengambilan & cache ──────────────────────────────────────

  Future<_Bundle> _load(double lat, double lng) {
    final key = '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}';
    final hit = _cache[key];
    if (hit != null && DateTime.now().difference(hit.at) < _cacheTtl) {
      return hit.future;
    }
    final future = _fetch(lat, lng);
    _cache[key] = _CacheEntry(DateTime.now(), future);
    // Jangan simpan kegagalan di cache.
    future.catchError((Object _) {
      _cache.remove(key);
      return _Bundle.empty;
    });
    return future;
  }

  Future<_Bundle> _fetch(double lat, double lng) async {
    final url = Uri.parse(
      '$_baseUrl?latitude=$lat&longitude=$lng'
      '&current=temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m'
      '&hourly=temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m'
      '&past_days=$_pastDays&forecast_days=4&timezone=auto',
    );

    final http.Response response;
    try {
      response = await http.get(url).timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('WeatherService fetch error: $e');
      throw Exception('Gagal terhubung ke layanan cuaca');
    }
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat cuaca (status ${response.statusCode})');
    }
    return _parse(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // ── Parsing ──────────────────────────────────────────────────

  _Bundle _parse(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;

    final times = List<String>.from(hourly['time']);
    final temp = _nums(hourly['temperature_2m']);
    final rh = _nums(hourly['relative_humidity_2m']);
    final rain = _nums(hourly['precipitation']);
    final wind = _nums(hourly['wind_speed_10m']);
    final codes = _nums(hourly['weather_code']);

    // Waktu Open-Meteo sudah dalam zona waktu lokasi (timezone=auto).
    final nowStr = current['time'] as String;
    final today = nowStr.substring(0, 10);

    // Indeks jam terakhir yang sudah lewat.
    int nowIdx = times.lastIndexWhere((t) => t.compareTo(nowStr) <= 0);
    if (nowIdx < 0) nowIdx = 0;
    final start24 = math.max(0, nowIdx - 23);
    double rain24 = 0;
    int wet24 = 0;
    for (var i = start24; i <= nowIdx; i++) {
      rain24 += rain[i];
      if (_isWet(rh[i], rain[i])) wet24++;
    }

    // Kelompokkan per tanggal.
    final history = <DailyWeather>[];
    final forecast = <DailyWeather>[];
    double todayMax = -100;
    final Map<String, List<int>> byDay = {};
    for (var i = 0; i < times.length; i++) {
      byDay.putIfAbsent(times[i].substring(0, 10), () => []).add(i);
    }
    final forecastCodes = <int>[];
    final forecastWind = <double>[];
    for (final entry in byDay.entries) {
      final idx = entry.value;
      if (entry.key == today) {
        for (final i in idx) {
          todayMax = math.max(todayMax, temp[i]);
        }
        continue;
      }
      final day = _summarize(entry.key, idx, temp, rh, rain);
      if (entry.key.compareTo(today) < 0) {
        history.add(day);
      } else {
        forecast.add(day);
        if (forecast.length == 1) {
          forecastCodes.addAll(idx.map((i) => codes[i].round()));
          forecastWind.addAll(idx.map((i) => wind[i]));
        }
      }
    }

    final temperature = (current['temperature_2m'] as num).toDouble();
    final humidity = (current['relative_humidity_2m'] as num).toDouble();

    final now = WeatherModel(
      temperature: temperature,
      humidity: humidity,
      condition: describeWmo((current['weather_code'] as num).round()),
      season: _season(history),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      rainfall24h: rain24,
      maxTemp: todayMax > -100 ? todayMax : temperature,
      wetHours: wet24,
      history: history,
      forecast: forecast,
    );

    final t = forecast.isNotEmpty ? forecast.first : null;
    final tomorrow = t == null
        ? now
        : WeatherModel(
            temperature: t.tMean,
            humidity: t.rhMean,
            condition: describeWmo(
              forecastCodes.isEmpty ? 0 : forecastCodes.reduce(math.max),
            ),
            season: now.season,
            windSpeed: forecastWind.isEmpty
                ? 0
                : forecastWind.reduce((a, b) => a + b) / forecastWind.length,
            rainfall24h: t.rain,
            maxTemp: t.tMax,
            wetHours: t.wetHours,
            history: history,
            forecast: forecast.skip(1).toList(),
          );

    return _Bundle(now, tomorrow);
  }

  DailyWeather _summarize(
    String date,
    List<int> idx,
    List<double> temp,
    List<double> rh,
    List<double> rain,
  ) {
    double tMax = -100, tMin = 100, rainSum = 0, rhSum = 0;
    int wet = 0;
    for (final i in idx) {
      tMax = math.max(tMax, temp[i]);
      tMin = math.min(tMin, temp[i]);
      rainSum += rain[i];
      rhSum += rh[i];
      if (_isWet(rh[i], rain[i])) wet++;
    }
    return DailyWeather(
      date: DateTime.parse(date),
      tMax: tMax,
      tMin: tMin,
      rain: rainSum,
      rhMean: rhSum / idx.length,
      wetHours: wet,
    );
  }

  static bool _isWet(double rh, double rain) => rh >= _wetRh || rain >= 0.1;

  /// Kriteria BMKG: musim hujan bila curah hujan dasarian (10 hari) >= 50 mm
  /// berturut-turut 3 dasarian; musim kemarau bila < 50 mm berturut-turut.
  /// Di luar itu dianggap masa peralihan (pancaroba).
  static String _season(List<DailyWeather> history) {
    if (history.length < 30) return 'Musim Peralihan';
    final last30 = history.sublist(history.length - 30);
    final dasarian = [
      for (var d = 0; d < 3; d++)
        last30.skip(d * 10).take(10).fold(0.0, (s, x) => s + x.rain),
    ];
    if (dasarian.every((r) => r >= 50)) return 'Musim Hujan';
    if (dasarian.every((r) => r < 50)) return 'Musim Kemarau';
    return 'Musim Peralihan';
  }

  static List<double> _nums(dynamic list) => (list as List)
      .map((e) => e == null ? 0.0 : (e as num).toDouble())
      .toList();

  /// Kode cuaca WMO → deskripsi Bahasa Indonesia.
  static String describeWmo(int code) {
    switch (code) {
      case 0:
        return 'cerah';
      case 1:
        return 'cerah sedikit berawan';
      case 2:
        return 'berawan sebagian';
      case 3:
        return 'mendung';
      case 45:
      case 48:
        return 'berkabut';
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return 'gerimis';
      case 61:
      case 80:
        return 'hujan ringan';
      case 63:
      case 81:
        return 'hujan sedang';
      case 65:
      case 82:
        return 'hujan lebat';
      case 66:
      case 67:
        return 'hujan dingin';
      case 95:
        return 'hujan badai petir';
      case 96:
      case 99:
        return 'badai petir dan hujan es';
      default:
        return code >= 71 && code <= 77 ? 'salju' : 'berawan';
    }
  }
}

class _Bundle {
  final WeatherModel current;
  final WeatherModel tomorrow;
  const _Bundle(this.current, this.tomorrow);

  static final _Bundle empty = _Bundle(
    WeatherModel(
      temperature: 0,
      humidity: 0,
      condition: '',
      season: '',
      windSpeed: 0,
    ),
    WeatherModel(
      temperature: 0,
      humidity: 0,
      condition: '',
      season: '',
      windSpeed: 0,
    ),
  );
}

class _CacheEntry {
  final DateTime at;
  final Future<_Bundle> future;
  const _CacheEntry(this.at, this.future);
}
