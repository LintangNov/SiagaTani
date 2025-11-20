import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/surrounding_pin_model.dart';
import '../services/firestore_service.dart';

class MapSetupController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  
  // State Map
  final MapController mapController = MapController();
  var currentCenter = LatLng(-6.200, 106.816).obs; // Default Jakarta
  var existingPins = <SurroundingPinModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _locateUser();
    bindPinsStream();
  }

  // 1. Ambil Lokasi User saat Masuk
  void _locateUser() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position pos = await Geolocator.getCurrentPosition();
    currentCenter.value = LatLng(pos.latitude, pos.longitude);
    mapController.move(currentCenter.value, 16.0); // Zoom ke user
    isLoading.value = false;
  }

  // 2. Dengarkan Data Pin dari Firestore (Realtime)
  void bindPinsStream() {
    existingPins.bindStream(_firestoreService.getPinsStream());
  }

  // 3. Fungsi Saat User Tap di Peta (Tambah Pin)
  void onMapTap(TapPosition tapPosition, LatLng latlng) {
    _showAddPinDialog(latlng);
  }

  void _showAddPinDialog(LatLng location) {
    String selectedPlant = "Terong"; // Default

    Get.defaultDialog(
      title: "Tanaman Apa Ini?",
      content: Column(
        children: [
          Text("Lokasi: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}"),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedPlant,
            items: ["Terong", "Pepaya", "Jagung", "Tembakau", "Lainnya"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => selectedPlant = val!,
            decoration: InputDecoration(labelText: "Jenis Tanaman"),
          ),
        ],
      ),
      textConfirm: "Simpan Pin",
      textCancel: "Batal",
      onConfirm: () {
        _savePinToDb(location, selectedPlant);
        Get.back();
      },
    );
  }

  void _savePinToDb(LatLng location, String type) async {
    var newPin = SurroundingPinModel(
      plantType: type,
      latitude: location.latitude,
      longitude: location.longitude,
    );
    await _firestoreService.addSurroundingPin(newPin);
    Get.snackbar("Sukses", "Pin $type ditambahkan!");
  }
}