import 'package:cloud_firestore/cloud_firestore.dart';

enum CropStage { seedling, vegetative, flowering, fruiting, harvesting }

enum MulchType { none, black, silver }

class FarmModel {
  String? id;
  final String farmName;
  final String address;
  final double latitude;
  final double longitude;
  final String landSize;
  final String variety;
  
  final CropStage cropStage;
  final MulchType mulchType;
  final String lastPesticideTime;

  final String hostPlantsNearby;
  final bool isMulchUsed;
  final String plantingPattern;
  final String pestHistory;
  final String currentPhase; 
  final bool recentlySprayedPesticide;
  final String pesticideType;
  final String wateringIntensity;

  FarmModel({
    this.id,
    required this.farmName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.landSize,
    required this.variety,
    required this.cropStage,
    required this.mulchType,
    required this.lastPesticideTime,
    required this.hostPlantsNearby,
    required this.isMulchUsed,
    required this.plantingPattern,
    required this.pestHistory,
    required this.currentPhase,
    required this.recentlySprayedPesticide,
    this.pesticideType = '',
    required this.wateringIntensity,
  });

  Map<String, dynamic> toMap() {
    return {
      'farmName': farmName,
      'address': address,
      'location': GeoPoint(latitude, longitude),
      'landSize': landSize,
      'variety': variety,
      'cropStage': cropStage.toString(), 
      'mulchType': mulchType.toString(),
      'lastPesticideTime': lastPesticideTime,
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

  factory FarmModel.fromMap(Map<String, dynamic> map, String documentId) {
    GeoPoint geoPoint = map['location'] as GeoPoint;
    
    CropStage parseStage(String? val) {
      return CropStage.values.firstWhere(
        (e) => e.toString() == val, 
        orElse: () => CropStage.vegetative 
      );
    }
    
    MulchType parseMulch(String? val) {
      return MulchType.values.firstWhere(
        (e) => e.toString() == val, 
        orElse: () => MulchType.none 
      );
    }

    return FarmModel(
      id: documentId,
      farmName: map['farmName'] ?? 'Lahan Tanpa Nama',
      address: map['address'] ?? 'Alamat tidak diketahui',
      latitude: geoPoint.latitude,
      longitude: geoPoint.longitude,
      landSize: map['landSize'] ?? '',
      variety: map['variety'] ?? '',
      cropStage: parseStage(map['cropStage']),
      mulchType: parseMulch(map['mulchType']),
      lastPesticideTime: map['lastPesticideTime'] ?? '',
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