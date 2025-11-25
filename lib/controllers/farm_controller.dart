import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siaga_tani/controllers/map_setup_controller.dart'; 
import '../models/farm_model.dart';
import '../services/firestore_service.dart';
import '../view/farm_detail_screen.dart';
import 'package:latlong2/latlong.dart';

class FarmController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final nameController = TextEditingController();
  final sizeController = TextEditingController();
  
  // Observable Values untuk Kuesioner
  var selectedVariety = "".obs;
  var selectedPattern = "".obs;
  var selectedPhase = "".obs;
  var pestHistory = "".obs;
  var mulchInput = "".obs; 
  var sprayInput = "".obs; 
  
  var isSaving = false.obs;

  Future<void> saveFarm() async {
    final MapSetupController mapController = Get.find<MapSetupController>();
    
    if (mapController.myFarmLocation.value == null) {
      Get.snackbar("Gagal", "Lokasi lahan belum ditentukan di peta!");
      return;
    }

    isSaving.value = true;
    try {
      // --- PERBAIKAN LOGIKA JARAK (SCIENTIFIC) ---
      bool hasHostNearby = false;
      final Distance distanceCalc = const Distance();
      
      // Lokasi lahan kita
      final myLocation = mapController.myFarmLocation.value!;

      // Cek setiap pin yang ada di peta
      for (var data in mapController.surroundingData) {
        // Abaikan jika jenisnya 'Lainnya'
        if (data['type'] == 'Lainnya') continue;

        // Hitung jarak meter
        double distanceMeters = distanceCalc.as(
          LengthUnit.Meter,
          myLocation,
          LatLng(data['lat'], data['lng'])
        );

        // Ambang batas 1000 meter (1 KM) sesuai riset lalat buah
        if (distanceMeters <= 1000) {
          hasHostNearby = true;
          print("Inang ${data['type']} terdeteksi dalam jarak ${distanceMeters.toStringAsFixed(0)}m");
          break; // Ketemu satu saja sudah cukup risiko
        }
      }

      // 2. Konversi String ke Enum
      CropStage stage = CropStage.vegetative;
      if (selectedPhase.value == "Bibit") stage = CropStage.seedling;
      else if (selectedPhase.value == "Vegetatif") stage = CropStage.vegetative;
      else if (selectedPhase.value == "Berbunga") stage = CropStage.flowering;
      else if (selectedPhase.value.contains("Berbuah")) stage = CropStage.fruiting;

      MulchType mulch = MulchType.none;
      if (mulchInput.value.contains("Perak")) mulch = MulchType.silver;
      else if (mulchInput.value.contains("Hitam")) mulch = MulchType.black;

      String finalName = nameController.text.isEmpty 
          ? "Lahan ${selectedVariety.value}" 
          : nameController.text;

      // 3. Buat Model
      FarmModel newFarm = FarmModel(
        farmName: finalName,
        address: mapController.currentAddress.value, 
        latitude: mapController.myFarmLocation.value!.latitude,
        longitude: mapController.myFarmLocation.value!.longitude,
        landSize: "1000 m2", 
        variety: selectedVariety.value,
        
        cropStage: stage,
        mulchType: mulch,
        lastPesticideTime: sprayInput.value,
        
        currentPhase: selectedPhase.value,
        hostPlantsNearby: hasHostNearby ? "Ya" : "Tidak",
        isMulchUsed: mulch != MulchType.none,
        plantingPattern: selectedPattern.value,
        pestHistory: pestHistory.value,
        recentlySprayedPesticide: sprayInput.value.contains("Baru"),
        wateringIntensity: "Sedang", 
        pesticideType: "",
      );

      // 4. Simpan
      await _firestoreService.addFarm(newFarm);
      
      // 5. Navigasi
      Get.off(() => const FarmDetailScreen(), arguments: newFarm);
      
      Get.snackbar("Sukses", "Lahan berhasil disimpan! Analisis risiko sedang berjalan.", backgroundColor: Colors.green, colorText: Colors.white);
      
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan: $e");
      print(e);
    } finally {
      isSaving.value = false;
    }
  }
}