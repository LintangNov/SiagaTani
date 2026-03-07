import 'package:latlong2/latlong.dart';

class SurroundingPinModel {
  String? id;
  final String plantType;
  final double latitude;
  final double longitude;

  SurroundingPinModel({
    this.id,
    required this.plantType,
    required this.latitude,
    required this.longitude,
  });

  /// Serializes to a plain Map (no Firestore types).
  Map<String, dynamic> toJson() {
    return {
      'plantType': plantType,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory SurroundingPinModel.fromJson(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return SurroundingPinModel(
      id: documentId,
      plantType: map['plantType'] ?? 'Lainnya',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  LatLng get toLatLng => LatLng(latitude, longitude);
}
