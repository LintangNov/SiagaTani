import 'dart:math';
import '../models/farm_model.dart';
import '../models/weather_model.dart';
import '../models/prediction_result.dart';

// --- INTERFACE LOGIKA HAMA ---
abstract class PestLogic {
  RiskAssessment? calculateRisk(FarmModel farm, WeatherModel weather, List<String> nearbyPlants);
}

// Helper Class Internal untuk perhitungan
class RiskAssessment {
  final String name;
  final double score;
  final RiskLevel level;
  final String reasoning;
  final List<String> mitigation;

  RiskAssessment(this.name, this.score, this.level, this.reasoning, this.mitigation);
}

// ============================================================
// 1. LOGIKA LALAT BUAH (Bactrocera spp.)
// ============================================================
class FruitFlyLogic implements PestLogic {
  @override
  RiskAssessment? calculateRisk(FarmModel farm, WeatherModel weather, List<String> nearbyPlants) {
    // Syarat Utama: Harus fase berbuah
    if (!farm.currentPhase.contains("Berbuah")) return null;

    double score = 0.3; // Base risk
    List<String> reasons = [];

    // A. Cuaca (Optimum 25-33 C)
    if (weather.temperature >= 25 && weather.temperature <= 33) {
      score += 0.3;
      reasons.add("Suhu optimal (25-33°C) untuk aktivitas lalat.");
    } else if (weather.temperature < 16) {
      score -= 0.2;
      reasons.add("Suhu terlalu dingin menghambat terbang.");
    }

    // B. Hujan/Lembap (Lalat suka lembap)
    if (weather.condition.toLowerCase().contains("hujan") || weather.humidity > 80) {
      score += 0.2;
      reasons.add("Kondisi lembap/hujan memicu lalat menyerang buah lunak.");
    }

    // C. Inang Alternatif (Polifag)
    bool hasHost = nearbyPlants.any((p) => ["Mangga", "Jambu", "Jeruk", "Pepaya", "Pisang", "Nangka", "Mentimun", "Terong"].contains(p));
    if (hasHost) {
      score += 0.2;
      reasons.add("Terdeteksi tanaman inang (Buah-buahan/Terong) di sekitar.");
    }

    // Kalkulasi Akhir
    score = score.clamp(0.0, 0.99);
    return RiskAssessment(
      "Lalat Buah (Bactrocera spp.)",
      score,
      _getLevel(score),
      reasons.join(" "),
      [
        "Pasang perangkap Metil Eugenol (Petrogenol).",
        "Sanitasi: Kubur buah busuk yang jatuh.",
        "Rotasi tanaman untuk memutus siklus."
      ]
    );
  }
}

// ============================================================
// 2. LOGIKA THRIPS (Thrips parvispinus)
// ============================================================
class ThripsLogic implements PestLogic {
  @override
  RiskAssessment? calculateRisk(FarmModel farm, WeatherModel weather, List<String> nearbyPlants) {
    double score = 0.2;
    List<String> reasons = [];

    // A. Cuaca (Suka Kering & Panas)
    if (weather.season == "Musim Kemarau" || !weather.condition.toLowerCase().contains("hujan")) {
      score += 0.4;
      reasons.add("Cuaca kering/kemarau memicu perkembangan pesat Thrips.");
    } else if (weather.condition.toLowerCase().contains("hujan")) {
      score -= 0.4; // Wash-out effect
      reasons.add("Hujan lebat mencuci hama dari daun.");
    }

    // B. Inang
    if (nearbyPlants.contains("Cabai Rawit")) {
      score += 0.2;
      reasons.add("Ada Cabai Rawit di sekitar sebagai inang alternatif.");
    }

    score = score.clamp(0.0, 0.99);
    return RiskAssessment(
      "Thrips (Daun Keriting)",
      score,
      _getLevel(score),
      reasons.join(" "),
      [
        "Gunakan Mulsa Perak untuk memantulkan cahaya.",
        "Tanam Kenikir Kuning sebagai tanaman perangkap.",
        "Cek pucuk daun muda, jika keriting segera tangani."
      ]
    );
  }
}

// ============================================================
// 3. LOGIKA KUTU KEBUL & KUTU DAUN (Vektor Virus)
// ============================================================
class AphidLogic implements PestLogic {
  @override
  RiskAssessment? calculateRisk(FarmModel farm, WeatherModel weather, List<String> nearbyPlants) {
    // Syarat: Lebih bahaya di fase muda
    bool isYoung = farm.currentPhase == "Bibit" || farm.currentPhase == "Vegetatif";
    
    double score = 0.2;
    List<String> reasons = [];

    if (isYoung) {
      score += 0.3;
      reasons.add("Tanaman fase muda kaya nutrisi yang disukai kutu.");
    }

    // A. Suhu (Optimum 32C)
    if (weather.temperature > 30) {
      score += 0.3;
      reasons.add("Suhu panas (>30°C) mempercepat siklus hidup kutu.");
    }

    // B. Inang
    if (nearbyPlants.any((p) => ["Melon", "Terong"].contains(p))) {
      score += 0.15;
      reasons.add("Ada Melon/Terong sebagai inang kutu.");
    }

    score = score.clamp(0.0, 0.99);
    return RiskAssessment(
      "Kutu Kebul & Kutu Daun",
      score,
      _getLevel(score),
      reasons.join(" "),
      [
        "Pasang Yellow Trap (Perangkap Kuning).",
        "Jaga populasi musuh alami (Kumbang Kura).",
        "Tumpangsari dengan Jagung sebagai penghalang."
      ]
    );
  }
}

// ============================================================
// 4. LOGIKA ANTRAKNOSA (Patek)
// ============================================================
class AnthracnoseLogic implements PestLogic {
  @override
  RiskAssessment? calculateRisk(FarmModel farm, WeatherModel weather, List<String> nearbyPlants) {
    double score = 0.1;
    List<String> reasons = [];

    // A. Kelembapan Tinggi (Kunci Utama)
    if (weather.humidity > 90) {
      score += 0.6;
      reasons.add("Kelembapan sangat tinggi (>90%) memicu spora jamur.");
    } else if (weather.humidity > 80) {
      score += 0.3;
      reasons.add("Kondisi lembap mendukung jamur.");
    }

    // B. Hujan (Penyebaran Spora)
    if (weather.condition.toLowerCase().contains("hujan")) {
      score += 0.2;
      reasons.add("Percikan air hujan menyebarkan spora.");
    }

    score = score.clamp(0.0, 0.99);
    return RiskAssessment(
      "Penyakit Antraknosa (Patek)",
      score,
      _getLevel(score),
      reasons.join(" "),
      [
        "Perbaiki drainase agar tidak menggenang.",
        "Jarak tanam jangan terlalu rapat.",
        "Petik dan musnahkan buah yang bergejala segera."
      ]
    );
  }
}

// ============================================================
// 5. LOGIKA ULAT GRAYAK
// ============================================================
class ArmywormLogic implements PestLogic {
  @override
  RiskAssessment? calculateRisk(FarmModel farm, WeatherModel weather, List<String> nearbyPlants) {
    double score = 0.2;
    List<String> reasons = [];

    // A. Mulsa & Kelembapan
    if (farm.isMulchUsed && weather.season.contains("Hujan")) {
      score += 0.4;
      reasons.add("Mulsa di musim hujan menciptakan iklim mikro lembap yang disukai ulat.");
    }

    // B. Suhu (Mati jika terlalu panas)
    if (weather.temperature < 30) {
      score += 0.2;
    } else if (weather.temperature > 35) {
      score -= 0.3;
      reasons.add("Suhu ekstrem panas menekan populasi ulat.");
    }

    score = score.clamp(0.0, 0.99);
    return RiskAssessment(
      "Ulat Grayak",
      score,
      _getLevel(score),
      reasons.join(" "),
      [
        "Cek lubang mulsa saat sore/malam hari.",
        "Bersihkan gulma di sekitar lubang tanam.",
        "Lakukan penggenangan sesaat."
      ]
    );
  }
}

// --- MAIN SERVICE ---
class PredictionService {
  final Random _rng = Random();

  // Daftar Logika yang akan dijalankan
  final List<PestLogic> _pestModels = [
    FruitFlyLogic(),
    ThripsLogic(),
    AphidLogic(),
    AnthracnoseLogic(),
    ArmywormLogic(),
  ];

  List<PredictionResult> analyzeRisk(FarmModel? farm, WeatherModel weather, List<String> nearbyPlants) {
    if (farm == null) return [];

    List<PredictionResult> results = [];

    for (var model in _pestModels) {
      RiskAssessment? assessment = model.calculateRisk(farm, weather, nearbyPlants);
      
      if (assessment != null && assessment.score > 0.25) { // Hanya tampilkan jika risiko > 25%
        // Tambahkan sedikit random factor (0-5%) agar terlihat dinamis
        double finalScore = (assessment.score + (_rng.nextDouble() * 0.05)).clamp(0.0, 0.99);
        
        results.add(PredictionResult(
          pestName: assessment.name,
          percentage: finalScore,
          riskLevel: assessment.level,
          description: assessment.reasoning,
          preventionSteps: assessment.mitigation,
        ));
      }
    }

    // Urutkan dari risiko tertinggi
    results.sort((a, b) => b.percentage.compareTo(a.percentage));
    return results;
  }
}

// Helper Global
RiskLevel _getLevel(double score) {
  if (score > 0.7) return RiskLevel.severe;
  if (score > 0.5) return RiskLevel.high;
  if (score > 0.3) return RiskLevel.moderate;
  return RiskLevel.low;
}