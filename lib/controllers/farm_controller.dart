import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:siaga_tani/controllers/map_setup_controller.dart'; // Import Map Controller
import '../models/farm_model.dart';
import '../services/firestore_service.dart';
import '../view/farm_detail_screen.dart';

class FarmController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  // --- INPUT FORM ---
  final nameController = TextEditingController();
  final sizeController = TextEditingController();
  
  var isSaving = false.obs;

  // Values (Sesuai inputan kuesioner)
  var selectedVariety = "Cabai Rawit".obs;
  var selectedPattern = "Monokultur".obs;
  var selectedPhase = "Vegetatif".obs;
  var selectedWatering = "Sedang".obs;
  var isMulchUsed = "Tidak".obs; // String biar cocok dengan UI
  var pestHistory = "Tidak Pernah".obs;
  var recentlySprayed = false.obs;

  // --- HAPUS: getCurrentLocation & _getAddressFromLatLng ---
  // (Karena logika ini sudah dipindah ke MapSetupController biar lebih canggih/debounce)

  Future<void> saveFarm() async {
    // 1. Ambil Data dari MapSetupController
    final MapSetupController mapController = Get.find<MapSetupController>();
    
    // Validasi Lokasi
    if (mapController.myFarmLocation.value == null) {
      Get.snackbar("Gagal", "Lokasi lahan belum ditentukan di peta!");
      return;
    }

    isSaving.value = true;
    try {
      // 2. LOGIKA CEK INANG (Data Pendukung)
      // Kita cek dari pin yang BARU SAJA ditambahkan user di peta
      bool hasHostNearby = false;
      
      // Cek daftar pin di MapController
      if (mapController.surroundingData.isNotEmpty) {
        // Kalau ada pin selain 'Lainnya', anggap ada inang
        hasHostNearby = mapController.surroundingData.any((data) => data['type'] != 'Lainnya');
      }

      // 3. Auto-Generate Nama jika kosong (Karena di UI Questionnaire tidak ada input nama)
      String finalName = nameController.text.isEmpty 
          ? "Lahan ${selectedVariety.value}" 
          : nameController.text;

      String finalSize = sizeController.text.isEmpty 
          ? "1000 m2" // Default size
          : sizeController.text;

      // 4. Buat Object FarmModel
      FarmModel newFarm = FarmModel(
        farmName: finalName,
        // Ambil alamat yang sudah di-geocode otomatis oleh MapController
        address: mapController.currentAddress.value, 
        latitude: mapController.myFarmLocation.value!.latitude,
        longitude: mapController.myFarmLocation.value!.longitude,
        landSize: finalSize,
        variety: selectedVariety.value,
        // Hasil logika inang otomatis
        hostPlantsNearby: hasHostNearby ? "Ya" : "Tidak", 
        isMulchUsed: isMulchUsed.value == "Ya, Pakai",
        plantingPattern: selectedPattern.value,
        pestHistory: pestHistory.value,
        currentPhase: selectedPhase.value,
        recentlySprayedPesticide: recentlySprayed.value,
        wateringIntensity: selectedWatering.value,
      );

      // 5. Simpan ke Firestore
      await _firestoreService.addFarm(newFarm);
      
      // 6. Navigasi ke Dashboard Detail (Langsung Analisis)
      Get.off(() => const FarmDetailScreen(), arguments: newFarm);
      
      Get.snackbar(
        "Sukses", 
        "Lahan berhasil disimpan di ${newFarm.address}!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan: $e");
      print(e);
    } finally {
      isSaving.value = false;
    }
  }
}