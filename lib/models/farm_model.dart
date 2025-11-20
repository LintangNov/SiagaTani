import 'package:cloud_firestore/cloud_firestore.dart';

class FarmModel {
  String? id;
  final String farmName; // User bisa namai misal "Lahan Belakang"
  final double latitude;
  final double longitude;
  final String landSize; // "100 m2"

  // A. Informasi Lahan
  final String variety; // "Cabai Rawit", "Cabai Merah Besar"
  final String hostPlantsNearby; // "Ya", "Tidak", "Tidak Tahu"
  final bool isMulchUsed;
  final String plantingPattern; // "Monokultur", "Tumpangsari", dll
  final String pestHistory; // "Pernah", "Tidak Pernah"

  // B. Fase Tanaman
  final String currentPhase; // "Bibit", "Vegetatif", "Berbunga", "Berbuah Muda", "Berbuah Matang"

  // C. Kegiatan Budidaya
  final bool recentlySprayedPesticide;
  final String pesticideType; // Opsional
  final String wateringIntensity; // "Rendah", "Sedang", "Tinggi"

  FarmModel({
    this.id,
    required this.farmName,
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
      'location': GeoPoint(latitude, longitude), // Format Firestore
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