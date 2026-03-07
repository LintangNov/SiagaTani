import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:siaga_tani/controllers/map_setup_controller.dart';
import 'package:siaga_tani/core/utils/ui_utils.dart';
import '../data/models/farm_model.dart';
import '../data/services/firestore_service.dart';
import '../view/farm_detail_screen.dart';

class FarmController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final nameController = TextEditingController();
  final sizeController = TextEditingController();

  var selectedVariety = ''.obs;
  var selectedPattern = ''.obs;
  var selectedPhase = ''.obs;
  var pestHistory = ''.obs;
  var mulchInput = ''.obs;
  var sprayInput = ''.obs;

  var isSaving = false.obs;

  Future<void> saveFarm() async {
    final MapSetupController mapController = Get.find<MapSetupController>();

    if (mapController.myFarmLocation.value == null) {
      UiUtils.showWarning('Lokasi lahan belum ditentukan di peta!');
      return;
    }

    isSaving.value = true;
    try {
      // --- LOGIKA JARAK (SCIENTIFIC) ---
      bool hasHostNearby = false;
      const Distance distanceCalc = Distance();

      final myLocation = mapController.myFarmLocation.value!;

      for (final data in mapController.surroundingData) {
        if (data['type'] == 'Lainnya') continue;

        final double distanceMeters = distanceCalc.as(
          LengthUnit.Meter,
          myLocation,
          LatLng(data['lat'], data['lng']),
        );

        if (distanceMeters <= 1000) {
          hasHostNearby = true;
          debugPrint(
            'Inang ${data['type']} terdeteksi dalam jarak ${distanceMeters.toStringAsFixed(0)}m',
          );
          break;
        }
      }

      CropStage stage = CropStage.vegetative;
      if (selectedPhase.value == 'Bibit') {
        stage = CropStage.seedling;
      } else if (selectedPhase.value == 'Vegetatif') {
        stage = CropStage.vegetative;
      } else if (selectedPhase.value == 'Berbunga') {
        stage = CropStage.flowering;
      } else if (selectedPhase.value.contains('Berbuah')) {
        stage = CropStage.fruiting;
      }

      MulchType mulch = MulchType.none;
      if (mulchInput.value.contains('Perak')) {
        mulch = MulchType.silver;
      } else if (mulchInput.value.contains('Hitam')) {
        mulch = MulchType.black;
      }

      final String finalName = nameController.text.isEmpty
          ? 'Lahan ${selectedVariety.value}'
          : nameController.text;

      final FarmModel newFarm = FarmModel(
        farmName: finalName,
        address: mapController.currentAddress.value,
        latitude: mapController.myFarmLocation.value!.latitude,
        longitude: mapController.myFarmLocation.value!.longitude,
        landSize: '1000 m2',
        variety: selectedVariety.value,
        cropStage: stage,
        mulchType: mulch,
        lastPesticideTime: sprayInput.value,
        currentPhase: selectedPhase.value,
        hostPlantsNearby: hasHostNearby ? 'Ya' : 'Tidak',
        isMulchUsed: mulch != MulchType.none,
        plantingPattern: selectedPattern.value,
        pestHistory: pestHistory.value,
        recentlySprayedPesticide: sprayInput.value.contains('Baru'),
        wateringIntensity: 'Sedang',
        pesticideType: '',
      );

      await _firestoreService.addFarm(newFarm);

      Get.off(() => FarmDetailScreen(), arguments: newFarm);

      UiUtils.showSuccess(
        'Lahan berhasil disimpan! Analisis risiko sedang berjalan.',
      );
    } catch (e) {
      UiUtils.showError('Gagal menyimpan: $e');
      debugPrint('saveFarm error: $e');
    } finally {
      isSaving.value = false;
    }
  }
}
