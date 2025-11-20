import 'package:cloud_firestore/cloud_firestore.dart';

class FarmModel {
  String? id;
  final String farmName;
  final String address; // <--- FIELD BARU
  final double latitude;
  final double longitude;
  final String landSize;

  // A. Informasi Lahan
  final String variety;
  final String hostPlantsNearby;
  final bool isMulchUsed;
  final String plantingPattern;
  final String pestHistory;

  // B. Fase Tanaman
  final String currentPhase;

  // C. Kegiatan Budidaya
  final bool recentlySprayedPesticide;
  final String pesticideType;
  final String wateringIntensity;

  FarmModel({
    this.id,
    required this.farmName,
    required this.address, // <--- Tambahkan di Constructor
    required this.latitude,
    required this.longitude,
    required this.landSize,
    required this.variety,
    required this.hostPlantsNearby,
    required this.isMulchUsed,
    required this.plantingPattern,
    required this.pestHistory,
    required this.currentPhase,
    required this.recentlySprayedPesticide,
    this.pesticideType = '',
    required this.wateringIntensity,
  });

  // Konversi ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'farmName': farmName,
      'address': address, // <--- Simpan ke Firestore
      'location': GeoPoint(latitude, longitude),
      'landSize': landSize,
      'variety': variety,
      'hostPlantsNearby': hostPlantsNearby,
      'isMulchUsed': isMulchUsed,
      'plantingPattern': plantingPattern,
      'pestHistory': pestHistory,
      'currentPhase': currentPhase,
      'recentlySprayedPesticide': recentlySprayedPesticide,
      'pesticideType': pesticideType,
      'wateringIntensity': wateringIntensity,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Konversi dari Firestore Map ke Object Dart
  factory FarmModel.fromMap(Map<String, dynamic> map, String documentId) {
    GeoPoint geoPoint = map['location'] as GeoPoint;
    return FarmModel(
      id: documentId,
      farmName: map['farmName'] ?? 'Lahan Tanpa Nama',
      address: map['address'] ?? 'Alamat tidak diketahui', // <--- Ambil dari Firestore
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
      landSize: map['landSize'] ?? '',
      variety: map['variety'] ?? '',
      hostPlantsNearby: map['hostPlantsNearby'] ?? 'Tidak Tahu',
      isMulchUsed: map['isMulchUsed'] ?? false,
      plantingPattern: map['plantingPattern'] ?? '',
      pestHistory: map['pestHistory'] ?? '',
      currentPhase: map['currentPhase'] ?? '',
      recentlySprayedPesticide: map['recentlySprayedPesticide'] ?? false,
      pesticideType: map['pesticideType'] ?? '',
      wateringIntensity: map['wateringIntensity'] ?? 'Sedang',
    );
  }
}