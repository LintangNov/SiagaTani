import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import '../models/farm_model.dart';
import '../models/surrounding_pin_model.dart'; // Import model pin
import '../services/firestore_service.dart';

class FarmController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // --- FORM CONTROLLERS ---
  final nameController = TextEditingController();
  final sizeController = TextEditingController();
  
  // --- STATE ---
  var selectedLocation = Rxn<LatLng>(); 
  var address = "Belum memilih lokasi".obs;
  var isLoadingLocation = false.obs;
  var isSaving = false.obs;

  // Values
  var selectedVariety = "Cabai Rawit".obs;
  var selectedPattern = "Monokultur".obs;
  var selectedPhase = "Vegetatif".obs;
  var selectedWatering = "Sedang".obs;
  var isMulchUsed = false.obs;
  var pestHistory = "Tidak Pernah".obs;
  var recentlySprayed = false.obs;

  // NOTE: Variable hostPlantsNearby dihapus dari inputan UI, 
  // tapi nanti dihitung otomatis saat save.

  // 1. Ambil Lokasi (Sama seperti sebelumnya)
  Future<void> getCurrentLocation() async {
    isLoadingLocation.value = true;
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      selectedLocation.value = LatLng(position.latitude, position.longitude);
      await _getAddressFromLatLng(position.latitude, position.longitude);
    } finally {
      isLoadingLocation.value = false;
    }
  }
  
  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        address.value = "${placemarks[0].subLocality}, ${placemarks[0].locality}";
      }
    } catch (e) {
      address.value = "Koordinat: $lat, $lng";
    }
  }

  // 2. Fungsi Simpan Cerdas (Smart Save)
  Future<void> saveFarm() async {
    if (nameController.text.isEmpty || selectedLocation.value == null) {
      Get.snackbar("Gagal", "Nama lahan dan Lokasi wajib diisi!");
      return;
    }

    isSaving.value = true;
    try {
      // --- LOGIKA BARU: DETEKSI OTOMATIS TANAMAN SEKITAR ---
      
      // a. Ambil semua pin dari database
      List<SurroundingPinModel> allPins = await _firestoreService.getAllPins();
      
      // b. Hitung jarak
      bool hasHostNearby = false;
      final Distance distanceCalc = const Distance();

      for (var pin in allPins) {
        // Hitung jarak dalam Meter
        double distanceInMeters = distanceCalc.as(
          LengthUnit.Meter,
          selectedLocation.value!, // Lokasi Lahan Cabai Kita
          LatLng(pin.latitude, pin.longitude), // Lokasi Pin Tetangga
        );

        // Jika ada tanaman inang (selain "Lainnya") dalam radius 1000m (1km)
        // Maka kita anggap berisiko (hostPlantsNearby = Ya)
        if (distanceInMeters <= 1000 && pin.plantType != 'Lainnya') {
          hasHostNearby = true;
          break; // Ketemu satu saja sudah cukup untuk bilang "Ya"
        }
      }

      // --- SELESAI LOGIKA ---

      FarmModel newFarm = FarmModel(
        farmName: nameController.text,
        latitude: selectedLocation.value!.latitude,
        longitude: selectedLocation.value!.longitude,
        landSize: sizeController.text,
        variety: selectedVariety.value,
        
        // HASIL OTOMATIS DI SINI:
        hostPlantsNearby: hasHostNearby ? "Ya" : "Tidak", 
        
        isMulchUsed: isMulchUsed.value,
        plantingPattern: selectedPattern.value,
        pestHistory: pestHistory.value,
        currentPhase: selectedPhase.value,
        recentlySprayedPesticide: recentlySprayed.value,
        wateringIntensity: selectedWatering.value,
      );

      await _firestoreService.addFarm(newFarm);
      
      Get.back(); 
      Get.snackbar("Sukses", "Lahan disimpan! Status Inang Sekitar: ${hasHostNearby ? 'Ada' : 'Aman'}");
      
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan: $e");
    } finally {
      isSaving.value = false;
    }
  }
}