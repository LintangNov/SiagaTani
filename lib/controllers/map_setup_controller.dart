import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/farm_constants.dart';
import '../utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class MapSetupController extends GetxController {
  final MapController mapController = MapController();

  var myFarmLocation = Rxn<LatLng>();
  var surroundingPins = <Marker>[].obs;
  var surroundingData = <Map<String, dynamic>>[].obs;

  // default location: Yogyakarta, Indonesia
  var currentCenter = const LatLng(-7.795, 110.369).obs;
  var currentAddress = "Geser pin untuk lokasi...".obs;
  var isLoadingAddress = false.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    checkLocationPermissionAndFetch();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    mapController.dispose();
    super.onClose();
  }

  Future<void> checkLocationPermissionAndFetch() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showDialogServiceDisabled();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showDialogPermissionDenied();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showDialogSettingsNeeded();
      return;
    }

    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      isLoadingAddress.value = true;
      currentAddress.value = "Sedang mencari koordinat...";

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      LatLng userPos = LatLng(position.latitude, position.longitude);

      currentCenter.value = userPos;

      try {
        mapController.move(userPos, 16.0);
      } catch (e) {
        print("Info: Map belum siap digerakkan, tapi data lokasi aman. ($e)");
      }

      _getAddressFromLatLng(userPos.latitude, userPos.longitude);
    } catch (e) {
      print("Gagal ambil GPS: $e");
      _showErrorSnackbar(e.toString());
    } finally {
      isLoadingAddress.value = false;
    }
  }

  // --- USER CENTERED DIALOGS & SNACKBAR ---

  void _showDialogServiceDisabled() {
    Get.defaultDialog(
      title: "GPS Mati",
      middleText:
          "SiagaTani butuh GPS nyala biar bisa nemuin lahanmu otomatis.",
      textConfirm: "Nyalakan",
      textCancel: "Nanti",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF2C3312),
      onConfirm: () async {
        Get.back();
        await Geolocator.openLocationSettings();
        Future.delayed(
          const Duration(seconds: 2),
          () => checkLocationPermissionAndFetch(),
        );
      },
    );
  }

  void _showDialogPermissionDenied() {
    Get.defaultDialog(
      title: "Butuh Izin Lokasi",
      middleText:
          "Boleh minta izin lokasi? Biar kamu gak capek geser-geser peta manual.",
      textConfirm: "Boleh, Izinkan",
      textCancel: "Gak Dulu",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF2C3312),
      onConfirm: () {
        Get.back();
        checkLocationPermissionAndFetch();
      },
    );
  }

  void _showDialogSettingsNeeded() {
    Get.defaultDialog(
      title: "Izin Ditolak Permanen",
      middleText:
          "Yah, izinnya ditolak permanen. Mau buka pengaturan buat aktifin manual?",
      textConfirm: "Buka Pengaturan",
      textCancel: "Biarin Aja",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF2C3312),
      onConfirm: () async {
        Get.back();
        await Geolocator.openAppSettings();
      },
    );
  }

  void _showErrorSnackbar(String error) {
    Get.snackbar(
      "Gagal Deteksi Lokasi",
      "Sinyal kurang oke nih. Mau coba lagi?",
      backgroundColor: Colors.orange.shade800,
      colorText: Colors.white,
      icon: const Icon(Icons.signal_wifi_bad, color: Colors.white),
      duration: const Duration(seconds: 6),
      mainButton: TextButton(
        onPressed: () => checkLocationPermissionAndFetch(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "Coba Lagi",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
          ),
        ),
      ),
    );
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

        String address = "$street, $subLoc, $loc".replaceAll(
          RegExp(r'^, | , '),
          '',
        );
        if (address.trim().isEmpty) address = "Lokasi Terpilih";

        currentAddress.value = address;
      } else {
        currentAddress.value = "Alamat tidak ditemukan";
      }
    } catch (e) {
      currentAddress.value =
          "Koordinat: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}";
    } finally {
      isLoadingAddress.value = false;
    }
  }

  void saveMyFarmLocation(BuildContext context) {
    myFarmLocation.value = currentCenter.value;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lokasi Aman!",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Text(
              "Lokasi tersimpan: ${currentAddress.value}",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void addSurroundingPin(BuildContext context, LatLng point) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            "Apa yang ditanam disini?",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                children: FarmConstants.hostPlants.map((plant) {
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_florist,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      plant,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      surroundingPins.add(
                        Marker(
                          point: point,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.orange,
                            size: 40,
                          ),
                        ),
                      );
                      surroundingData.add({
                        "type": plant,
                        "lat": point.latitude,
                        "lng": point.longitude,
                      });
                      Navigator.pop(dialogContext); // Close dialog

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Berhasil menandai $plant",
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
