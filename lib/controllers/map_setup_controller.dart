import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; 
import '../utils/farm_constants.dart';

class MapSetupController extends GetxController {
  final MapController mapController = MapController();
  
  var myFarmLocation = Rxn<LatLng>(); 
  var surroundingPins = <Marker>[].obs; 
  var surroundingData = <Map<String, dynamic>>[].obs; 
  var currentCenter = const LatLng(-7.795, 110.369).obs;
  var currentAddress = "Geser pin untuk lokasi...".obs;
  var isLoadingAddress = false.obs;
  
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
      _getAddressFromLatLng(userPos.latitude, userPos.longitude);
    } catch (e) {
      print("Gagal ambil GPS: $e");
    }
  }

  void onPositionChanged(MapCamera camera, bool hasGesture) {
    currentCenter.value = camera.center;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _getAddressFromLatLng(camera.center.latitude, camera.center.longitude);
    });
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    isLoadingAddress.value = true;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
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

  void saveMyFarmLocation() {
    myFarmLocation.value = currentCenter.value;
    Get.snackbar("Lokasi Tersimpan", "Lokasi: ${currentAddress.value}", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
  }

  void addSurroundingPin(LatLng point) {
    Get.defaultDialog(
      title: "Tanaman Tetangga",
      content: SizedBox(
        height: 300,
        child: SingleChildScrollView(
          child: Column(
            children: FarmConstants.hostPlants.map((plant) {
              return ListTile(
                leading: const Icon(Icons.local_florist, color: Colors.orange),
                title: Text(plant),
                onTap: () {
                  surroundingPins.add(Marker(point: point, width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.orange, size: 40)));
                  surroundingData.add({"type": plant, "lat": point.latitude, "lng": point.longitude});
                  Get.back(); 
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}