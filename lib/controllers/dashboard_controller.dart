import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../data/models/farm_model.dart';
import '../data/models/farm_risk_status.dart';
import '../data/models/surrounding_pin_model.dart';
import '../data/models/weather_model.dart';
import '../data/services/firestore_service.dart';
import '../data/services/prediction_service.dart';
import '../data/services/weather_service.dart';

enum LocationStatus { loading, ok, gpsOff, denied, blocked, failed }

class DailyTip {
  final String title;
  final String body;
  final IconData icon;

  const DailyTip(this.title, this.body, this.icon);
}

class DashboardController extends GetxController {
  static const int _maxTips = 3;
  static const Duration _cacheTtl = Duration(minutes: 15);

  final WeatherService _weatherService = WeatherService();
  final FirestoreService _firestoreService = FirestoreService();
  final PredictionService _predictionService = PredictionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final currentWeather = Rxn<WeatherModel>();
  final isLoadingWeather = true.obs;
  final weatherFailed = false.obs;
  final weatherUpdatedAt = Rxn<DateTime>();
  final weatherLabel = ''.obs;

  final userName = 'Petani'.obs;
  final currentLocation = 'Mencari lokasi...'.obs;
  final locationStatus = LocationStatus.loading.obs;

  final dailyTips = <DailyTip>[].obs;

  final farms = <FarmModel>[].obs;
  final farmsLoading = true.obs;
  final farmsFailed = false.obs;
  final farmRisks = <String, FarmRiskStatus>{}.obs;

  final Map<String, String> _riskSignature = {};
  final Map<String, DateTime> _riskFetchedAt = {};
  StreamSubscription<List<FarmModel>>? _farmSub;
  DateTime? _lastWeatherFetchTime;
  bool _hasDeviceLocation = false;

  Stream<List<FarmModel>> get farmListStream => _firestoreService.getFarms();

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    fetchCurrentLocation();
    ever(currentWeather, (_) => generateSmartTips());
    _listenFarms();
  }

  @override
  void onClose() {
    _farmSub?.cancel();
    super.onClose();
  }

  void retryFarms() {
    farmsLoading.value = true;
    farmsFailed.value = false;
    _listenFarms();
  }

  void _listenFarms() {
    _farmSub?.cancel();
    _farmSub = farmListStream.listen(
      (list) {
        farms.assignAll(list);
        farmsLoading.value = false;
        farmsFailed.value = false;
        _loadFarmRisks(list);
        if (!_hasDeviceLocation && currentWeather.value == null) {
          _useFarmWeatherFallback();
        }
      },
      onError: (Object e) {
        debugPrint('Farm stream error: $e');
        farmsLoading.value = false;
        farmsFailed.value = true;
      },
    );
  }

  Future<void> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.reload();
        user = _auth.currentUser;
      } catch (e) {
        debugPrint('fetchUserData reload error: $e');
      }
      final String fullName = user?.displayName ?? '';
      userName.value = fullName.trim().isEmpty
          ? 'Petani'
          : fullName.trim().split(' ')[0];
    }
  }

  // ── Lokasi ────────────────────────────────────────────────

  Future<void> fetchCurrentLocation({bool forceRefresh = false}) async {
    if (forceRefresh) {
      isLoadingWeather.value = true;
      locationStatus.value = LocationStatus.loading;
      currentLocation.value = 'Memuat lokasi...';
    }

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationProblem(LocationStatus.gpsOff);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationProblem(LocationStatus.denied);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _locationProblem(LocationStatus.blocked);
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _hasDeviceLocation = true;
      locationStatus.value = LocationStatus.ok;
      weatherLabel.value = '';

      fetchWeather(
        position.latitude,
        position.longitude,
        isRefresh: forceRefresh,
      );

      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        final String subLoc = place.subLocality ?? '';
        final String loc = place.locality ?? '';
        final String text = (subLoc.isNotEmpty && loc.isNotEmpty)
            ? '$subLoc, $loc'
            : (loc.isNotEmpty ? loc : subLoc);
        currentLocation.value = text.isEmpty ? 'Lokasi Anda' : text;
      } else {
        currentLocation.value = 'Lokasi Anda';
      }
    } catch (e) {
      debugPrint('Gagal ambil lokasi: $e');
      _locationProblem(LocationStatus.failed);
    }
  }

  void _locationProblem(LocationStatus status) {
    _hasDeviceLocation = false;
    locationStatus.value = status;
    currentLocation.value = 'Lokasi belum tersedia';
    if (farms.isNotEmpty && currentWeather.value == null) {
      _useFarmWeatherFallback();
    } else {
      isLoadingWeather.value = false;
    }
  }

  void _useFarmWeatherFallback() {
    if (farms.isEmpty) {
      isLoadingWeather.value = false;
      return;
    }
    final farm = farms.first;
    weatherLabel.value = 'Cuaca di ${farm.farmName}';
    fetchWeather(farm.latitude, farm.longitude);
  }

  Future<void> handleLocationAction() async {
    switch (locationStatus.value) {
      case LocationStatus.gpsOff:
        await Geolocator.openLocationSettings();
        break;
      case LocationStatus.blocked:
        await Geolocator.openAppSettings();
        break;
      case LocationStatus.denied:
        final permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          locationStatus.value = LocationStatus.blocked;
        } else if (permission != LocationPermission.denied) {
          await fetchCurrentLocation(forceRefresh: true);
        }
        break;
      case LocationStatus.failed:
      case LocationStatus.ok:
      case LocationStatus.loading:
        await fetchCurrentLocation(forceRefresh: true);
        break;
    }
  }

  // ── Cuaca ─────────────────────────────────────────────────

  Future<void> refreshAll() async {
    await fetchCurrentLocation(forceRefresh: true);
    await fetchUserData();
  }

  /// Muat ulang cuaca dari koordinat yang sedang dipakai (HP atau lahan).
  Future<void> refreshWeather() async {
    if (_hasDeviceLocation || farms.isEmpty) {
      await fetchCurrentLocation(forceRefresh: true);
    } else {
      final farm = farms.first;
      weatherLabel.value = 'Cuaca di ${farm.farmName}';
      await fetchWeather(farm.latitude, farm.longitude, isRefresh: true);
    }
  }

  Future<void> fetchWeather(
    double lat,
    double lng, {
    bool isRefresh = false,
  }) async {
    if (!isRefresh &&
        _lastWeatherFetchTime != null &&
        currentWeather.value != null &&
        DateTime.now().difference(_lastWeatherFetchTime!) < _cacheTtl) {
      isLoadingWeather.value = false;
      return;
    }

    isLoadingWeather.value = true;
    weatherFailed.value = false;
    try {
      final weather = await _weatherService.getWeatherByLocation(lat, lng);
      currentWeather.value = weather;
      _lastWeatherFetchTime = DateTime.now();
      weatherUpdatedAt.value = _lastWeatherFetchTime;
    } catch (e) {
      debugPrint('Error Weather: $e');
      if (currentWeather.value == null) weatherFailed.value = true;
    } finally {
      isLoadingWeather.value = false;
    }
  }

  void generateSmartTips() {
    final w = currentWeather.value;
    if (w == null) {
      dailyTips.clear();
      return;
    }
    final tips = <DailyTip>[];

    if (w.temperature > 30) {
      tips.add(
        DailyTip(
          'Cuaca Panas',
          'Suhu ${w.temperature.toStringAsFixed(0)} derajat. Siram tanaman pagi atau sore hari.',
          Icons.wb_sunny_outlined,
        ),
      );
    }
    if (w.condition.toLowerCase().contains('hujan')) {
      tips.add(
        const DailyTip(
          'Akan Hujan',
          'Tunda pemupukan sampai hujan reda.',
          Icons.water_drop_outlined,
        ),
      );
    }
    if (w.humidity > 80) {
      tips.add(
        const DailyTip(
          'Udara Lembap',
          'Udara lembap. Waspadai jamur pada daun dan buah.',
          Icons.cloud_outlined,
        ),
      );
    }
    if (tips.isEmpty) {
      tips.add(
        const DailyTip(
          'Cuaca Mendukung',
          'Cuaca baik hari ini. Periksa tanaman Anda seperti biasa.',
          Icons.eco_outlined,
        ),
      );
    }
    dailyTips.assignAll(tips.take(_maxTips));
  }

  // ── Risiko per lahan ──────────────────────────────────────

  Future<void> _loadFarmRisks(List<FarmModel> list) async {
    final now = DateTime.now();
    final liveIds = list.map((f) => f.id).whereType<String>().toSet();
    farmRisks.removeWhere((id, _) => !liveIds.contains(id));

    final pending = <FarmModel>[];
    for (final farm in list) {
      final id = farm.id;
      if (id == null) continue;
      final signature = farm.toJson().toString();
      final fetchedAt = _riskFetchedAt[id];
      final fresh = fetchedAt != null && now.difference(fetchedAt) < _cacheTtl;
      final status = farmRisks[id];
      if (fresh &&
          _riskSignature[id] == signature &&
          status != null &&
          status.state != FarmRiskState.error) {
        continue;
      }
      _riskSignature[id] = signature;
      farmRisks[id] = const FarmRiskStatus.loading();
      pending.add(farm);
    }
    if (pending.isEmpty) return;

    List<SurroundingPinModel> pins = const [];
    try {
      pins = await _firestoreService.getAllPins();
    } catch (e) {
      debugPrint('Pins error: $e');
    }

    await Future.wait(pending.map((farm) => _loadOneRisk(farm, pins)));
  }

  Future<void> _loadOneRisk(
    FarmModel farm,
    List<SurroundingPinModel> pins,
  ) async {
    final id = farm.id!;
    try {
      final weather = await _weatherService.getWeatherByLocation(
        farm.latitude,
        farm.longitude,
      );
      const distance = Distance();
      final origin = LatLng(farm.latitude, farm.longitude);
      final nearby = <String>[
        for (final pin in pins)
          if (distance.as(LengthUnit.Meter, origin, pin.toLatLng) <= 1000)
            pin.plantType,
      ];
      final results = _predictionService.analyzeRisk(farm, weather, nearby);
      farmRisks[id] = FarmRiskStatus.fromTop(
        results.isEmpty ? null : results.first,
      );
      _riskFetchedAt[id] = DateTime.now();
    } catch (e) {
      debugPrint('Risk error ($id): $e');
      farmRisks[id] = const FarmRiskStatus.error();
    }
  }
}
