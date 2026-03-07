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
  final String? imageUrl;

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
    this.imageUrl,
  });

  /// Serializes to a plain Map (no Firestore types).
  Map<String, dynamic> toJson() {
    return {
      'farmName': farmName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
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
      'imageUrl': imageUrl,
    };
  }

  factory FarmModel.fromJson(Map<String, dynamic> map, String documentId) {
    CropStage parseStage(String? val) {
      return CropStage.values.firstWhere(
        (e) => e.toString() == val,
        orElse: () => CropStage.vegetative,
      );
    }

    MulchType parseMulch(String? val) {
      return MulchType.values.firstWhere(
        (e) => e.toString() == val,
        orElse: () => MulchType.none,
      );
    }

    return FarmModel(
      id: documentId,
      farmName: map['farmName'] ?? 'Lahan Tanpa Nama',
      address: map['address'] ?? 'Alamat tidak diketahui',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      landSize: map['landSize']?.toString() ?? '',
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
      imageUrl: map['imageUrl'],
    );
  }

  FarmModel copyWith({
    String? id,
    String? farmName,
    String? address,
    double? latitude,
    double? longitude,
    String? landSize,
    String? variety,
    CropStage? cropStage,
    MulchType? mulchType,
    String? lastPesticideTime,
    String? hostPlantsNearby,
    bool? isMulchUsed,
    String? plantingPattern,
    String? pestHistory,
    String? currentPhase,
    bool? recentlySprayedPesticide,
    String? pesticideType,
    String? wateringIntensity,
    String? imageUrl,
  }) {
    return FarmModel(
      id: id ?? this.id,
      farmName: farmName ?? this.farmName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      landSize: landSize ?? this.landSize,
      variety: variety ?? this.variety,
      cropStage: cropStage ?? this.cropStage,
      mulchType: mulchType ?? this.mulchType,
      lastPesticideTime: lastPesticideTime ?? this.lastPesticideTime,
      hostPlantsNearby: hostPlantsNearby ?? this.hostPlantsNearby,
      isMulchUsed: isMulchUsed ?? this.isMulchUsed,
      plantingPattern: plantingPattern ?? this.plantingPattern,
      pestHistory: pestHistory ?? this.pestHistory,
      currentPhase: currentPhase ?? this.currentPhase,
      recentlySprayedPesticide:
          recentlySprayedPesticide ?? this.recentlySprayedPesticide,
      pesticideType: pesticideType ?? this.pesticideType,
      wateringIntensity: wateringIntensity ?? this.wateringIntensity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
