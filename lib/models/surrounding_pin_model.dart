import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class SurroundingPinModel {
  String? id;
  final String plantType; // Contoh: "Terong", "Jagung", "Pepaya", "Lainnya"
  final double latitude;
  final double longitude;

  SurroundingPinModel({
    this.id,
    required this.plantType,
    required this.latitude,
    required this.longitude,
  });

  // Untuk menyimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'plantType': plantType,
      'location': GeoPoint(latitude, longitude),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Dari Firestore ke Objek Dart
  factory SurroundingPinModel.fromMap(Map<String, dynamic> map, String documentId) {
    GeoPoint geo = map['location'] as GeoPoint;
    return SurroundingPinModel(
      id: documentId,
      plantType: map['plantType'] ?? 'Lainnya',
      latitude: geo.latitude,
      longitude: geo.longitude,
    );
  }

  // Helper untuk konversi ke LatLng (dipakai flutter_map)
  LatLng get toLatLng => LatLng(latitude, longitude);
}