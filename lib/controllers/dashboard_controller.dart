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
  // Default text ajakan
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

  // --- LOGIKA UTAMA PENGAMBILAN LOKASI ---
  Future<void> fetchCurrentLocation({bool forceRefresh = false}) async {
    if (forceRefresh) {
      isLoadingWeather.value = true;
      currentLocation.value = "Sedang memuat...";
    }

    try {
      // 1. Cek GPS Service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentLocation.value = "GPS Mati. Ketuk untuk nyalakan"; 
        _stopLoading();
        return;
      }

      // 2. Cek Izin
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Coba minta izin sekali lagi
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentLocation.value = "Izin ditolak. Ketuk beri izin";
          _stopLoading();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Kalau permanen, gak bisa requestPermission, harus ke settings
        currentLocation.value = "Izin diblokir. Ketuk buka setting";
        _stopLoading();
        return;
      }

      // 3. Kalau lolos, ambil posisi
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

  // --- FUNGSI PINTAR HANDLE TAP (PERBAIKAN DISINI) ---
  // --- FUNGSI PINTAR HANDLE TAP (VERSI PANTANG MENYERAH) ---
  void handleLocationTap() async {
    // 1. Cek GPS Hardware dulu (Kalo GPS mati, popup izin gak akan guna)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Ini biasanya memunculkan dialog sistem Android "Turn on Device Location?"
      // Jadi tetep kerasa kayak "Popup", bukan masuk full screen setting.
      await Geolocator.openLocationSettings();
      return;
    }

    // 2. LANGSUNG HAJAR MINTA IZIN (Tanpa Cek Status Dulu)
    // Ini akan memaksa aplikasi memunculkan Popup "Allow SiagaTani to access location?"
    // (Selama belum di-blokir permanen oleh Android)
    LocationPermission permission = await Geolocator.requestPermission();

    // 3. Cek Hasilnya
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      // Mantap! Diizinkan. Langsung ambil data.
      fetchCurrentLocation(forceRefresh: true);
    } 
    else if (permission == LocationPermission.deniedForever) {
      // Nah, kalau masuk sini, berarti Android udah ngunci pintu.
      // Popup gak keluar karena diblokir sistem.
      // Kita kasih info aja lewat Snackbar kecil (User gak dipaksa pindah halaman)
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
    // Kalau 'denied' biasa, kita diem aja. 
    // Karena user baru aja nutup popupnya, jadi dia tau dia nolak.
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