enum RiskLevel { low, moderate, high, severe }

class PredictionResult {
  final String pestName;
  final double percentage;   // Contoh: 0.85 (85%)
  final RiskLevel riskLevel; // Menggunakan Enum
  final String shortDescription; // Alasan singkat untuk header (saat ditutup)
  final String detailedAnalysis;
  final List<String> preventionSteps; // List saran pencegahan

  PredictionResult({
    required this.pestName,
    required this.percentage,
    required this.riskLevel,
  required this.shortDescription,
    required this.detailedAnalysis,
    required this.preventionSteps,
  });

  // Helper untuk memformat persentase ke string "85.2%"
String get formattedPercentage => "${(percentage * 100).toStringAsFixed(0)}%";
  
  // Helper untuk mendapatkan string level (jika dibutuhkan)
  String get riskLevelString {
    switch (riskLevel) {
      case RiskLevel.low: return "RENDAH";
      case RiskLevel.moderate: return "SEDANG";
      case RiskLevel.high: return "TINGGI";
      case RiskLevel.severe: return "BAHAYA";
    }
  }
}