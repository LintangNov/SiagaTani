// Tambahkan Enum ini di luar class
enum RiskLevel { low, moderate, high, severe }

class PredictionResult {
  final String pestName;
  final double percentage;   // 0.0 - 1.0
  final RiskLevel riskLevel; // Menggunakan Enum
  final String description;
  final List<String> preventionSteps;

  PredictionResult({
    required this.pestName,
    required this.percentage,
    required this.riskLevel,
    required this.description,
    required this.preventionSteps,
  });

  // Helper untuk format persentase
  String get formattedPercentage => "${(percentage * 100).toStringAsFixed(1)}%";
  
  // Helper untuk mendapatkan string level (untuk UI lama jika perlu)
  String get riskLevelString {
    switch (riskLevel) {
      case RiskLevel.low: return "RENDAH";
      case RiskLevel.moderate: return "SEDANG";
      case RiskLevel.high: return "TINGGI";
      case RiskLevel.severe: return "BAHAYA";
    }
  }
}