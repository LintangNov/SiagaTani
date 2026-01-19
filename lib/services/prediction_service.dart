// import 'dart:math';
import '../models/farm_model.dart';
import '../models/weather_model.dart';
import '../models/prediction_result.dart';

abstract class PestStrategy {
  PredictionResult? calculate(FarmModel farm, WeatherModel weather, List<String> nearbyPlants);
}

class ThripsStrategy implements PestStrategy {
  @override
  PredictionResult? calculate(FarmModel farm, WeatherModel weather, List<String> nearbyPlants) {
    double score = 0.3; 
    
    if (weather.rainfall24h > 15.0) {
      return _buildResult(
        "Thrips (Daun Keriting)", 
        0.1, 
        "Populasi tercuci oleh hujan lebat.",
        "Curah hujan >15mm dalam 24 jam terakhir secara mekanis menjatuhkan nimfa dan imago Thrips dari daun, menyebabkan kematian massal alami (Wash-out Effect).",
        ["Lakukan pemantauan 2 hari pasca hujan reda.", "Fokuskan pengamatan pada pucuk daun muda."]
      );
    }

    String detail = "Kondisi lingkungan saat ini sangat mendukung perkembangan Thrips karena:";
    if (weather.season == "Musim Kemarau") {
      score += 0.35;
      detail += "\n• Cuaca kering memperpendek siklus hidup dari telur ke dewasa menjadi hanya 14 hari.";
    }
    if (nearbyPlants.contains("Cabai Rawit")) {
      score += 0.2;
      detail += "\n• Adanya tanaman inang sejenis di sekitar menjadi sumber migrasi.";
    }
    
    if (farm.mulchType == MulchType.silver && farm.cropStage == CropStage.seedling) {
      score -= 0.25;
      detail += "\n• (Positif) Pantulan UV dari mulsa perak saat ini efektif membingungkan hama.";
    }

    return _buildResult(
      "Thrips (Daun Keriting)", 
      score, 
      "Cuaca kering memicu ledakan populasi.",
      detail,
      [
        "Rotasi Insektisida: Gunakan bahan aktif Abamectin (Gol. 6) selang-seling dengan Spinetoram (Gol. 5) untuk cegah resistensi.",
        "Mekanis: Pasang perangkap likat warna BIRU atau KUNING (40 buah/ha).",
        "Hayati: Semprotkan jamur Beauveria bassiana pada sore hari.",
        "Sanitasi: Potong pucuk daun yang keriting parah dan bakar."
      ]
    );
  }
}

class FruitFlyStrategy implements PestStrategy {
  @override
  PredictionResult? calculate(FarmModel farm, WeatherModel weather, List<String> nearbyPlants) {
    if (farm.cropStage != CropStage.fruiting && farm.cropStage != CropStage.harvesting) return null; 

    double score = 0.4;
    String detail = "Lalat buah menjadi ancaman serius karena:";

    if (weather.currentTemp >= 25 && weather.currentTemp <= 32) {
      score += 0.3; 
      detail += "\n• Suhu hangat (25-32°C) adalah rentang optimal untuk lalat kawin dan bertelur.";
    } else if (weather.currentTemp < 16.0) {
      score = 0.1;
      return _buildResult("Lalat Buah", 0.1, "Suhu dingin hambat aktivitas.", "Suhu <16°C membuat lalat pasif.", ["Pantau saja."]);
    }

    if (weather.humidity > 80 || weather.rainfall24h > 0) {
      score += 0.25;
      detail += "\n• Kelembapan tinggi membuat kulit buah menjadi lunak, memudahkan ovipositor lalat menusuk buah.";
    }

    bool hasFruitHost = nearbyPlants.any((p) => ["Mangga", "Jambu", "Jeruk", "Pepaya"].contains(p));
    if (hasFruitHost) {
      score += 0.15;
      detail += "\n• Tanaman buah di sekitar lahan berfungsi sebagai reservoir hama.";
    }

    return _buildResult(
      "Lalat Buah", 
      score, 
      "Fase berbuah + Lembap = Risiko Tinggi.",
      detail,
      [
        "Perangkap Jantan: Pasang atraktan Metil Eugenol (Petrogenol) sebanyak 20-24 titik/ha.",
        "Umpan Protein: Semprotkan umpan protein (gliserin) untuk memandulkan lalat betina.",
        "Sanitasi Ketat: Kubur buah jatuh sedalam 50cm untuk memutus siklus larva.",
        "Kultur Teknis: Pembungkusan buah (brongsong) jika populasi sangat tinggi."
      ]
    );
  }
}

class AnthracnoseStrategy implements PestStrategy {
  @override
  PredictionResult? calculate(FarmModel farm, WeatherModel weather, List<String> nearbyPlants) {
    double score = 0.15;
    String detail = "Analisis risiko infeksi jamur:";

    bool isWet = weather.wetHours > 4 || weather.humidity > 85.0;
    bool isWarm = weather.currentTemp >= 20.0 && weather.currentTemp <= 30.0;

    if (isWet && isWarm) {
      score += 0.65;
      detail += "\n• Kombinasi 'Basah' (>4 jam/hari) dan 'Hangat' memicu spora berkecambah dalam hitungan jam.";
    } else if (!isWet) {
      return _buildResult("Antraknosa (Patek)", 0.1, "Kondisi kering menghambat jamur.", "Spora membutuhkan lapisan air untuk berkecambah.", ["Jaga drainase."]);
    }

    if (weather.rainfall24h > 5.0) {
      score += 0.15;
      detail += "\n• Percikan air hujan adalah media utama penyebaran spora antar tanaman.";
    }

    return _buildResult(
      "Antraknosa (Patek)", 
      score, 
      "Kelembapan tinggi memicu spora jamur.",
      detail,
      [
        "Fungisida Protektif: Aplikasikan Mankozeb atau Propineb SEBELUM hujan turun.",
        "Fungisida Kuratif: Jika gejala muncul, gunakan Azoxystrobin atau Difenokonazol.",
        "Nutrisi: Tambahkan Kalsium (Ca) dan Boron (B) untuk mempertebal dinding sel buah.",
        "Sanitasi: Petik buah bergejala dan musnahkan jauh dari lahan."
      ]
    );
  }
}

class ArmywormStrategy implements PestStrategy {
  @override
  PredictionResult? calculate(FarmModel farm, WeatherModel weather, List<String> nearbyPlants) {
    double score = 0.2;
    String detail = "Faktor pendukung Ulat Grayak:";

    if (farm.mulchType == MulchType.black) {
      score += 0.25;
      detail += "\n• Mulsa hitam menjaga tanah tetap hangat dan lembap, tempat ideal bagi pupa ulat bersembunyi siang hari.";
    }

    if (weather.currentTemp < 28.0) {
      score += 0.2;
      detail += "\n• Suhu sejuk (<28°C) meningkatkan nafsu makan larva.";
    } else if (weather.currentTemp > 35.0) {
      score -= 0.2; 
    }

    return _buildResult(
      "Ulat Grayak", 
      score, 
      "Iklim mikro lembap mendukung siklus hidup.",
      detail,
      [
        "Pemantauan Malam: Ulat aktif di malam hari. Lakukan pengumpulan manual saat malam.",
        "Jebakan: Pasang perangkap Feromon Exi (untuk S. exigua) atau Litone (S. litura).",
        "Sanitasi: Bersihkan gulma di parit yang sering menjadi tempat bertelur.",
        "Insektisida: Gunakan bahan aktif Emamectin Benzoate atau Chlorantraniliprole."
      ]
    );
  }
}

class AphidStrategy implements PestStrategy {
  @override
  PredictionResult? calculate(FarmModel farm, WeatherModel weather, List<String> nearbyPlants) {
    double score = 0.2;
    String detail = "Potensi ledakan populasi Kutu Kebul:";

    if (farm.cropStage == CropStage.seedling || farm.cropStage == CropStage.vegetative) {
      score += 0.35;
      detail += "\n• Tanaman muda memiliki jaringan lunak dan kaya nitrogen yang sangat disukai kutu.";
    }

    if (weather.currentTemp > 30.0) {
      score += 0.3;
      detail += "\n• Suhu panas (>30°C) mempercepat siklus hidup dari 30 hari menjadi <20 hari.";
    }

    if (nearbyPlants.any((p) => ["Terong", "Melon", "Semangka"].contains(p))) {
      score += 0.15;
      detail += "\n• Terdeteksi inang Solanaceae/Cucurbitaceae lain di sekitar.";
    }

    return _buildResult(
      "Kutu Kebul (Virus Kuning)", 
      score, 
      "Panas & Tunas muda memicu ledakan populasi.",
      detail,
      [
        "Monitoring: Pasang Yellow Sticky Trap (Perangkap Kuning) 40 titik/ha untuk pantau populasi.",
        "Barier: Tanam Jagung di keliling lahan sebagai tanaman penghadang.",
        "Insektisida: Gunakan Imidakloprid (sistemik) atau Abamectin (kontak), rotasi wajib.",
        "Nutrisi: Hindari penggunaan Urea (N) berlebih agar daun tidak terlalu sukulen."
      ]
    );
  }
}

class PredictionService {
  final List<PestStrategy> _strategies = [
    ThripsStrategy(), FruitFlyStrategy(), AnthracnoseStrategy(), ArmywormStrategy(), AphidStrategy()
  ];

  List<PredictionResult> analyzeRisk(FarmModel? farm, WeatherModel weather, List<String> nearbyPlants) {
    if (farm == null) return [];
    List<PredictionResult> results = [];

    for (var strategy in _strategies) {
      var result = strategy.calculate(farm, weather, nearbyPlants);
      if (result != null) {
        if (farm.lastPesticideTime.contains("< 3 hari")) {
           double newPercentage = result.percentage * 0.2;
           result = _buildResult(
             result.pestName, 
             newPercentage, 
             "Risiko terkendali (Pasca Semprot).", 
             "Tanaman masih dilindungi oleh residu pestisida yang diaplikasikan < 3 hari lalu.", 
             ["Lanjutkan jadwal monitoring rutin."]
           );
        }
        if (result.percentage > 0.40) results.add(result); 
      }
    }
    results.sort((a, b) => b.percentage.compareTo(a.percentage));
    return results;
  }
}

PredictionResult _buildResult(String name, double score, String shortReason, String detailReason, List<String> steps) {
  score = score.clamp(0.0, 0.99);
  return PredictionResult(
    pestName: name, percentage: score, riskLevel: _getLevel(score),
    shortDescription: shortReason,
    detailedAnalysis: detailReason,
    preventionSteps: steps,
  );
}

RiskLevel _getLevel(double score) {
  if (score > 0.7) return RiskLevel.severe;
  if (score > 0.5) return RiskLevel.high;
  if (score > 0.3) return RiskLevel.moderate;
  return RiskLevel.low;
}