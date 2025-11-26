import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

import '../models/weather_model.dart';
import '../models/farm_model.dart';
import '../services/firestore_service.dart';
import '../services/weather_service.dart'; // Pastikan pakai yang ASLI
// HAPUS import dummy_weather_service

class DashboardController extends GetxController {
  final WeatherService _weatherService = WeatherService(); // Pakai API Asli
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var currentWeather = Rxn<WeatherModel>();
  var isLoadingWeather = true.obs;
  
  // Data Header
  var userName = "Petani".obs;
  var currentLocation = "Mencari lokasi...".obs; 
  
  var dailyTips = <Map<String, dynamic>>[].obs;

  Stream<List<FarmModel>> get farmListStream => _firestoreService.getFarms();

  @override
  void onInit() {
    super.onInit();
    fetchUserData(); 
    fetchCurrentLocation(); // Di dalamnya akan panggil fetchWeather
    ever(currentWeather, (_) => generateSmartTips());
  }

  // 1. Ambil Nama User
  Future<void> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.reload(); 
        user = _auth.currentUser; 
      } catch (e) {
        print("Gagal reload user: $e");
      }

      String fullName = user?.displayName ?? "";
      if (fullName.trim().isEmpty) {
        userName.value = "Petani"; 
      } else {
        List<String> names = fullName.trim().split(" ");
        userName.value = names.isNotEmpty ? names[0] : fullName;
      }
    }
  }

  // 2. Ambil Lokasi & Panggil Cuaca
  Future<void> fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentLocation.value = "GPS Mati";
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentLocation.value = "Izin Ditolak";
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        currentLocation.value = "Izin Diblokir";
        return;
      }

      // Ambil koordinat
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // --- PANGGIL CUACA API (Pakai lat/lng asli) ---
      fetchWeather(position.latitude, position.longitude);

      // Ambil Nama Alamat
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String subLoc = place.subLocality ?? "";
        String loc = place.locality ?? "";
        
        if (subLoc.isNotEmpty && loc.isNotEmpty) {
           currentLocation.value = "$subLoc, $loc";
        } else {
           currentLocation.value = loc.isNotEmpty ? loc : "Lokasi tidak dikenal";
        }
      }
    } catch (e) {
      print("Gagal ambil lokasi dashboard: $e");
      currentLocation.value = "Gagal memuat lokasi";
    }
  }

  // 3. Fungsi Fetch Weather (Hanya SATU fungsi ini)
  void fetchWeather(double lat, double lng) async {
    isLoadingWeather.value = true;
    try {
      // Panggil Service API
      var weather = await _weatherService.getWeatherByLocation(lat, lng);
      currentWeather.value = weather;
    } catch (e) {
      print("Error Weather: $e");
    } finally {
      isLoadingWeather.value = false;
    }
  }

  // 4. Smart Tips
  void generateSmartTips() {
    if (currentWeather.value == null) return;
    var w = currentWeather.value!;
    var tips = <Map<String, dynamic>>[];

    if (w.temperature > 30) {
      tips.add({
        "title": "Cuaca Panas Terik",
        "body": "Suhu mencapai ${w.temperature}°C. Siram tanaman sore ini.",
        "icon": Icons.wb_sunny,
        "color": Colors.orange.shade100,
        "textColor": Colors.orange.shade900,
      });
    }
    if (w.condition.toLowerCase().contains("hujan")) {
      tips.add({
        "title": "Potensi Hujan",
        "body": "Tunda pemupukan agar tidak hanyut.",
        "icon": Icons.water_drop,
        "color": Colors.blue.shade100,
        "textColor": Colors.blue.shade900,
      });
    }
    if (w.humidity > 80) {
      tips.add({
        "title": "Kelembapan Tinggi",
        "body": "Waspada jamur pada daun.",
        "icon": Icons.cloud,
        "color": Colors.grey.shade200,
        "textColor": Colors.grey.shade800,
      });
    }
    
    var generalTips = [
      {"title": "Info Pasar", "body": "Harga cabai rawit stabil Rp 45.000/kg.", "icon": Icons.monetization_on, "color": Colors.green.shade100, "textColor": Colors.green.shade900},
      {"title": "Tips Budidaya", "body": "Rotasi dengan jagung memutus siklus kutu.", "icon": Icons.lightbulb, "color": Colors.yellow.shade100, "textColor": Colors.yellow.shade900}
    ];
    tips.add(generalTips[Random().nextInt(generalTips.length)]);
    dailyTips.assignAll(tips);
  }
}