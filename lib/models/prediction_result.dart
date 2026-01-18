enum RiskLevel { low, moderate, high, severe }

class PredictionResult {
  final String pestName;
  final double percentage;
  final RiskLevel riskLevel;
  final String shortDescription;
  final String detailedAnalysis;
  final List<String> preventionSteps;

  PredictionResult({
    required this.pestName,
    required this.percentage,
    required this.riskLevel,
    required this.shortDescription,
    required this.detailedAnalysis,
    required this.preventionSteps,
  });

  String get formattedPercentage => "${(percentage * 100).toStringAsFixed(0)}%";
  
  String get riskLevelString {
    switch (riskLevel) {
      case RiskLevel.low: return "RENDAH";
      case RiskLevel.moderate: return "SEDANG";
      case RiskLevel.high: return "TINGGI";
      case RiskLevel.severe: return "BAHAYA";
    }
  }
}