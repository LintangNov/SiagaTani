import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import '../models/farm_model.dart';
import '../models/surrounding_pin_model.dart';
import '../services/firestore_service.dart';

class FarmController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final nameController = TextEditingController();
  final sizeController = TextEditingController();
  
  var selectedLocation = Rxn<LatLng>(); 
  var address = "Belum memilih lokasi".obs; // Ini akan terisi otomatis
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

  Future<void> getCurrentLocation() async {
    isLoadingLocation.value = true;
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      selectedLocation.value = LatLng(position.latitude, position.longitude);
      // Panggil geocoding untuk dapat teks alamat
      await _getAddressFromLatLng(position.latitude, position.longitude);
    } finally {
      isLoadingLocation.value = false;
    }
  }
  
  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Update variable address agar tampil di UI dan siap disimpan
        address.value = "${place.subLocality}, ${place.locality}";
      } else {
        address.value = "Lokasi tidak dikenal";
      }
    } catch (e) {
      address.value = "Koordinat: $lat, $lng";
    }
  }

  Future<void> saveFarm() async {
    if (nameController.text.isEmpty || selectedLocation.value == null) {
      Get.snackbar("Gagal", "Nama lahan dan Lokasi wajib diisi!");
      return;
    }

    isSaving.value = true;
    try {
      // Cek Inang (Logika sebelumnya)
      List<SurroundingPinModel> allPins = await _firestoreService.getAllPins();
      bool hasHostNearby = false;
      final Distance distanceCalc = const Distance();

      for (var pin in allPins) {
        double distanceInMeters = distanceCalc.as(
          LengthUnit.Meter,
          selectedLocation.value!, 
          LatLng(pin.latitude, pin.longitude), 
        );
        if (distanceInMeters <= 1000 && pin.plantType != 'Lainnya') {
          hasHostNearby = true;
          break; 
        }
      }

      // Buat Object FarmModel dengan Alamat
      FarmModel newFarm = FarmModel(
        farmName: nameController.text,
        address: address.value, // <--- SIMPAN ALAMAT TEKS DI SINI
        latitude: selectedLocation.value!.latitude,
        longitude: selectedLocation.value!.longitude,
        landSize: sizeController.text,
        variety: selectedVariety.value,
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
      Get.snackbar("Sukses", "Lahan di ${address.value} tersimpan!");
      
    } catch (e) {
      Get.snackbar("Error", "Gagal menyimpan: $e");
    } finally {
      isSaving.value = false;
    }
  }
}