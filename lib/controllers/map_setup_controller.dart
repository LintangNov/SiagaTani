import 'dart:async'; // Untuk Timer
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Pastikan import ini ada
import '../utils/farm_constants.dart';

class MapSetupController extends GetxController {
  final MapController mapController = MapController();
  
  // State
  var myFarmLocation = Rxn<LatLng>(); 
  var surroundingPins = <Marker>[].obs; 
  var surroundingData = <Map<String, dynamic>>[]; 
  var currentCenter = const LatLng(-7.795, 110.369).obs;
  
  // STATE ALAMAT (BARU)
  var currentAddress = "Geser pin untuk lokasi...".obs;
  var isLoadingAddress = false.obs;
  
  // Timer untuk Debounce (biar gak panggil API terus-terusan pas geser)
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _getCurrentLocation();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
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
      mapController.move(userPos, 16.0);
      
      // Langsung cari alamat saat pertama kali dapat lokasi
      _getAddressFromLatLng(userPos.latitude, userPos.longitude);
      
    } catch (e) {
      print("Gagal ambil GPS: $e");
    }
  }

  // 2. Fungsi saat Map Digeser (Logic Debounce)
  void onPositionChanged(MapCamera camera, bool hasGesture) {
    currentCenter.value = camera.center;
    
    // Kalau sedang ada timer berjalan, batalkan (artinya user masih geser)
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Mulai timer baru. Jika user diam selama 800ms, baru cari alamat
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _getAddressFromLatLng(camera.center.latitude, camera.center.longitude);
    });
  }

  // Helper: Cari Alamat dari Koordinat
  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    isLoadingAddress.value = true;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Format: "Jalan X, Desa Y"
        String street = place.street ?? "";
        String subLoc = place.subLocality ?? "";
        String loc = place.locality ?? "";
        
        currentAddress.value = "$street, $subLoc, $loc".replaceAll(RegExp(r'^, | , '), '');
      } else {
        currentAddress.value = "Alamat tidak ditemukan";
      }
    } catch (e) {
      currentAddress.value = "Koordinat: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}";
    } finally {
      isLoadingAddress.value = false;
    }
  }

  // 3. Simpan Lokasi Lahan Saya
  void saveMyFarmLocation() {
    myFarmLocation.value = currentCenter.value;
    // Kita bisa juga simpan address ke variable global/storage kalau perlu
    Get.snackbar(
      "Lokasi Tersimpan", 
      "Lokasi: ${currentAddress.value}",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // 4. Tambah Pin Tanaman Sekitar
  void addSurroundingPin(LatLng point) {
    Get.defaultDialog(
      title: "Tanaman Tetangga",
      content: SizedBox(
        height: 300,
        child: SingleChildScrollView(
          child: Column(
            children: FarmConstants.hostPlants.map((plant) {
              return _buildPlantOption(point, plant);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantOption(LatLng point, String label) {
    return ListTile(
      leading: Icon(_getIconForPlant(label), color: Colors.orange),
      title: Text(label),
      onTap: () {
        surroundingPins.add(
          Marker(
            point: point,
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: Colors.orange, size: 40),
          ),
        );
        surroundingData.add({
          "type": label,
          "lat": point.latitude,
          "lng": point.longitude,
        });
        Get.back(); 
      },
    );
  }

  IconData _getIconForPlant(String type) {
    switch (type) {
      case "Jagung": return Icons.grass;
      case "Mangga": 
      case "Jeruk": return Icons.park; 
      default: return Icons.local_florist; 
    }
  }
}