import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

import '../models/weather_model.dart';
import '../models/farm_model.dart';
import '../services/firestore_service.dart';
import '../services/weather_service.dart';

class DashboardController extends GetxController {
  final WeatherService _weatherService = WeatherService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var currentWeather = Rxn<WeatherModel>();
  var isLoadingWeather = true.obs;
  
  var userName = "Petani".obs;
  var currentLocation = "Mencari lokasi...".obs; 
  
  var dailyTips = <Map<String, dynamic>>[].obs;
  DateTime? _lastWeatherFetchTime; 

  Stream<List<FarmModel>> get farmListStream => _firestoreService.getFarms();

  @override
  void onInit() {
    super.onInit();
    fetchUserData(); 
    fetchCurrentLocation(); 
    ever(currentWeather, (_) => generateSmartTips());
  }

  Future<void> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try { await user.reload(); user = _auth.currentUser; } catch (e) {}
      String fullName = user?.displayName ?? "";
      userName.value = fullName.trim().isEmpty ? "Petani" : fullName.split(" ")[0];
    }
  }

  // --- AMBIL LOKASI ---
  Future<void> fetchCurrentLocation({bool forceRefresh = false}) async {
    if (forceRefresh) {
      isLoadingWeather.value = true;
      currentLocation.value = "Sedang memuat...";
    }

    try {

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentLocation.value = "GPS Mati. Ketuk untuk nyalakan"; 
        _stopLoading();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentLocation.value = "Izin ditolak. Ketuk beri izin";
          _stopLoading();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        currentLocation.value = "Izin diblokir. Ketuk buka setting";
        _stopLoading();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      fetchWeather(position.latitude, position.longitude, isRefresh: forceRefresh);

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String subLoc = place.subLocality ?? "";
        String loc = place.locality ?? "";
        currentLocation.value = (subLoc.isNotEmpty && loc.isNotEmpty) ? "$subLoc, $loc" : loc;
      }
    } catch (e) {
      print("Gagal ambil lokasi: $e");
      currentLocation.value = "Gagal memuat. Ketuk ulangi";
      _stopLoading();
    }
  }


  void handleLocationTap() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      fetchCurrentLocation(forceRefresh: true);
    } 
    else if (permission == LocationPermission.deniedForever) {

      Get.snackbar(
        "Izin Diblokir Sistem", 
        "HP Anda menolak menampilkan popup izin. Cek pengaturan jika ingin mengubah.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        mainButton: TextButton(
          onPressed: () => Geolocator.openAppSettings(),
          child: const Text("Buka", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }

  }

  void _stopLoading() {
    isLoadingWeather.value = false;
  }

  void fetchWeather(double lat, double lng, {bool isRefresh = false}) async {
    if (!isRefresh && 
        _lastWeatherFetchTime != null && 
        currentWeather.value != null &&
        DateTime.now().difference(_lastWeatherFetchTime!).inMinutes < 15) {
      isLoadingWeather.value = false;
      return;
    }

    isLoadingWeather.value = true;
    try {
      var weather = await _weatherService.getWeatherByLocation(lat, lng);
      currentWeather.value = weather;
      _lastWeatherFetchTime = DateTime.now(); 
    } catch (e) {
      print("Error Weather: $e");
    } finally {
      isLoadingWeather.value = false;
    }
  }

  void generateSmartTips() {
    if (currentWeather.value == null) return;
    var w = currentWeather.value!;
    var tips = <Map<String, dynamic>>[];

    if (w.temperature > 30) {
      tips.add({"title": "Cuaca Panas", "body": "Suhu ${w.temperature}°C. Siram tanaman.", "icon": Icons.wb_sunny, "color": Colors.orange.shade100, "textColor": Colors.orange.shade900});
    }
    if (w.condition.toLowerCase().contains("hujan")) {
      tips.add({"title": "Potensi Hujan", "body": "Tunda pemupukan.", "icon": Icons.water_drop, "color": Colors.blue.shade100, "textColor": Colors.blue.shade900});
    }
    if (w.humidity > 80) {
      tips.add({"title": "Lembap Tinggi", "body": "Waspada jamur.", "icon": Icons.cloud, "color": Colors.grey.shade200, "textColor": Colors.grey.shade800});
    }
    
    var generalTips = [
      {"title": "Info Pasar", "body": "Harga cabai stabil.", "icon": Icons.monetization_on, "color": Colors.green.shade100, "textColor": Colors.green.shade900},
      {"title": "Tips Budidaya", "body": "Rotasi tanaman itu penting.", "icon": Icons.lightbulb, "color": Colors.yellow.shade100, "textColor": Colors.yellow.shade900}
    ];
    tips.add(generalTips[Random().nextInt(generalTips.length)]);
    dailyTips.assignAll(tips);
  }

  
}