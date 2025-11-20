// File: lib/models/prediction_result.dart

class PredictionResult {
  final String pestName;
  final double percentage;   // Contoh: 0.85 (85%)
  final String riskLevel;    // "RENDAH", "SEDANG", "TINGGI"
  final String description;
  final List<String> preventionSteps; // List saran

  PredictionResult({
    required this.pestName,
    required this.percentage,
    required this.riskLevel,
    required this.description,
    required this.preventionSteps,
  });
  
  // Helper untuk memformat persentase ke string "85.2%"
  String get formattedPercentage => "${(percentage * 100).toStringAsFixed(1)}%";
}