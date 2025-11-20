import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart'; // Pastikan ini dari package latlong2
import '../models/farm_model.dart';
import '../services/firestore_service.dart';

class FarmController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // --- FORM CONTROLLERS ---
  final nameController = TextEditingController();
  final sizeController = TextEditingController();
  
  // --- OBSERVABLE VARIABLES (STATE) ---
  var selectedLocation = Rxn<LatLng>(); // Koordinat lahan
  var address = "Belum memilih lokasi".obs;
  var isLoadingLocation = false.obs;
  var isSaving = false.obs;

  // Dropdown Values
  var selectedVariety = "Cabai Rawit".obs;
  var selectedPattern = "Monokultur".obs;
  var selectedPhase = "Vegetatif".obs;
  var selectedWatering = "Sedang".obs;
  
  // Radio/Checkbox Values
  var hostPlantsNearby = "Tidak Tahu".obs; // Ya/Tidak/Tidak Tahu
  var isMulchUsed = false.obs;
  var pestHistory = "Tidak Pernah".obs;
  var recentlySprayed = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    sizeController.dispose();
    super.onClose();
  }

  // 1. Fungsi Mendapatkan Lokasi GPS Saat Ini
  Future<void> getCurrentLocation() async {
    isLoadingLocation.value = true;
    try {
      // Cek permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      
      // Set lokasi
      selectedLocation.value = LatLng(position.latitude, position.longitude);
      
      // Ambil alamat (Geocoding)
      await _getAddressFromLatLng(position.latitude, position.longitude);
      
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil lokasi: $e");
    } finally {
      isLoadingLocation.value = false;
    }
  }

  // Helper: Ubah Koordinat jadi Alamat
  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        address.value = "${place.subLocality}, ${place.locality}";
      }
    } catch (e) {
      address.value = "Koordinat: $lat, $lng";
    }
  }

  // 2. Fungsi Simpan ke Database
  Future<void> saveFarm() async {
    if (nameController.text.isEmpty || selectedLocation.value == null) {
      Get.snackbar("Gagal", "Nama lahan dan Lokasi wajib diisi!");
      return;
    }

    isSaving.value = true;
    try {
      // Buat Object Model
      FarmModel newFarm = FarmModel(
        farmName: nameController.text,
        latitude: selectedLocation.value!.latitude,
        longitude: selectedLocation.value!.longitude,
        landSize: sizeController.text,
        variety: selectedVariety.value,
        hostPlantsNearby: hostPlantsNearby.value,
        isMulchUsed: isMulchUsed.value,
        plantingPattern: selectedPattern.value,
        pestHistory: pestHistory.value,
        currentPhase: selectedPhase.value,
        recentlySprayedPesticide: recentlySprayed.value,
        wateringIntensity: selectedWatering.value,
      );

      // Kirim ke Firestore
      await _firestoreService.addFarm(newFarm);
      
      Get.back(); // Tutup halaman tambah
      Get.snackbar("Sukses", "Lahan berhasil ditambahkan!");
      
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan: $e");
    } finally {
      isSaving.value = false;
    }
  }
}