import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart'; // Versi 8.2.2
import 'package:latlong2/latlong.dart';      // Versi 0.9.1
import 'package:geolocator/geolocator.dart';  // Versi 14.0.2

class MapSetupController extends GetxController {
  // --- STATE UTAMA ---
  final MapController mapController = MapController();
  
  // Lokasi Lahan Kita (Pin Merah - Center)
  var myFarmLocation = Rxn<LatLng>(); 
  
  // Lokasi Tanaman Sekitar (Pin Kuning - List)
  var surroundingPins = <Marker>[].obs; 
  
  // Helper untuk UI "Gojek Style"
  var currentCenter = const LatLng(-7.795, 110.369).obs; // Default Jogja

  @override
  void onInit() {
    super.onInit();
    _getCurrentLocation();
  }

  // 1. Ambil Lokasi Saat Ini (GPS)
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      Position position = await Geolocator.getCurrentPosition();
      LatLng userPos = LatLng(position.latitude, position.longitude);
      
      currentCenter.value = userPos;
      // Pindahkan kamera peta ke lokasi user
      mapController.move(userPos, 16.0);
    } catch (e) {
      print("Gagal ambil GPS: $e");
    }
  }

  // 2. Fungsi saat Map Digeser (Untuk Lahan Saya)
  // PERBAIKAN: Gunakan MapCamera, bukan MapPosition
  void onPositionChanged(MapCamera camera, bool hasGesture) {
    currentCenter.value = camera.center;
  }

  // 3. Simpan Lokasi Lahan Saya
  void saveMyFarmLocation() {
    myFarmLocation.value = currentCenter.value;
    Get.snackbar(
      "Tersimpan", 
      "Lokasi lahan utama berhasil dikunci!",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // 4. Tambah Pin Tanaman Sekitar (Tap di Peta)
  void addSurroundingPin(LatLng point) {
    // Tampilkan Dialog Pilih Tanaman
    Get.defaultDialog(
      title: "Tanaman Apa Ini?",
      content: Column(
        children: [
          _buildPlantOption(point, "Jagung", Icons.grass),
          _buildPlantOption(point, "Tembakau", Icons.smoking_rooms),
          _buildPlantOption(point, "Lainnya", Icons.park),
        ],
      ),
    );
  }

  Widget _buildPlantOption(LatLng point, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(label),
      onTap: () {
        // Tambahkan ke List Marker
        surroundingPins.add(
          Marker(
            point: point,
            width: 40,
            height: 40,
            // Di versi 8+, Marker child tetap didukung
            child: const Icon(Icons.location_on, color: Colors.orange, size: 40),
          ),
        );
        Get.back(); // Tutup dialog
      },
    );
  }
}