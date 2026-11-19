/// Ringkasan cuaca satu hari (dari data per jam Open-Meteo).
class DailyWeather {
  final DateTime date;
  final double tMax;
  final double tMin;
  final double rain; // mm/hari
  final double rhMean; // %
  final int wetHours; // jam dengan RH >= 90% atau hujan

  const DailyWeather({
    required this.date,
    required this.tMax,
    required this.tMin,
    required this.rain,
    required this.rhMean,
    required this.wetHours,
  });

  double get tMean => (tMax + tMin) / 2;

  /// Derajat-hari metode rata-rata sederhana di atas suhu ambang [base].
  double degreeDays(double base) => (tMean - base).clamp(0.0, 40.0);
}

class WeatherModel {
  final double temperature;
  final double humidity;
  final String condition;
  final String season;
  final double windSpeed; // km/jam
  final double rainfall24h; // mm, total 24 jam terakhir
  final double maxTemp;
  final int wetHours; // jam basah dalam 24 jam terakhir

  /// Riwayat harian (lama → baru), tidak termasuk hari ini. Kosong bila
  /// sumber data tidak menyediakan riwayat.
  final List<DailyWeather> history;

  /// Prakiraan harian mulai besok.
  final List<DailyWeather> forecast;

  WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.season,
    required this.windSpeed,
    this.rainfall24h = 0.0,
    this.maxTemp = 30.0,
    this.wetHours = 0,
    this.history = const [],
    this.forecast = const [],
  });

  bool get hasHistory => history.length >= 7;

  List<DailyWeather> _last(int days) =>
      history.length <= days ? history : history.sublist(history.length - days);

  /// Rata-rata suhu harian [days] hari terakhir (fallback: suhu sekarang).
  double meanTemp(int days) {
    final h = _last(days);
    if (h.isEmpty) return temperature;
    return h.map((d) => d.tMean).reduce((a, b) => a + b) / h.length;
  }

  double meanMaxTemp(int days) {
    final h = _last(days);
    if (h.isEmpty) return maxTemp;
    return h.map((d) => d.tMax).reduce((a, b) => a + b) / h.length;
  }

  double meanHumidity(int days) {
    final h = _last(days);
    if (h.isEmpty) return humidity;
    return h.map((d) => d.rhMean).reduce((a, b) => a + b) / h.length;
  }

  double rainTotal(int days) {
    final h = _last(days);
    if (h.isEmpty) return rainfall24h;
    return h.fold(0.0, (s, d) => s + d.rain);
  }

  /// Jumlah hari hujan (>= 1 mm, definisi BMKG) dalam [days] hari terakhir.
  int rainyDays(int days) => _last(days).where((d) => d.rain >= 1.0).length;

  /// Akumulasi derajat-hari [days] hari terakhir di atas suhu ambang [base].
  double degreeDays(int days, double base) {
    final h = _last(days);
    if (h.isEmpty) return (temperature - base).clamp(0.0, 40.0) * days;
    return h.fold(0.0, (s, d) => s + d.degreeDays(base));
  }

  double forecastRain(int days) =>
      forecast.take(days).fold(0.0, (s, d) => s + d.rain);

  int forecastWetHours(int days) =>
      forecast.take(days).fold(0, (s, d) => s + d.wetHours);
}
