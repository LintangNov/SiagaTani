import 'dart:math';
import '../models/farm_model.dart';
import '../models/weather_model.dart';
import '../models/prediction_result.dart';
// Pastikan import model SurroundingPinModel atau terima list String tanaman sekitar

class PredictionService {
  final Random _rng = Random();

  double _calculateScore(double baseScore, List<double> additives) {
    double score = baseScore;
    for (var point in additives) score += point;
    // Variasi random kecil (0-5%) agar angka terlihat natural
    return (score + (_rng.nextDouble() * 0.05)).clamp(0.0, 0.99);
  }

  String _getRiskLevel(double score) {
    if (score > 0.70) return "TINGGI";
    if (score > 0.40) return "SEDANG";
    return "RENDAH";
  }

  // NOTE: Tambahkan parameter 'nearbyPlants' (List jenis tanaman di sekitar radius 1km)
  List<PredictionResult> analyzeRisk(FarmModel? farm, WeatherModel weather, List<String> nearbyPlants) {
    if (farm == null) return [];

    List<PredictionResult> results = [];

    // --- DEFINISI VARIABEL PEMBANTU ---
    bool isRaining = weather.condition.toLowerCase().contains("hujan");
    bool isDrySeason = weather.season.toLowerCase().contains("kemarau");
    bool isHot = weather.temperature > 28.0; 
    bool isVeryHot = weather.temperature > 32.0;
    bool isHumid = weather.humidity > 80.0;
    bool isVeryHumid = weather.humidity > 90.0; // Pemicu Antraknosa

    // Cek Inang Spesifik
    bool hasFruitFlyHost = nearbyPlants.any((p) => ["Mangga", "Jambu", "Jeruk", "Pepaya", "Pisang", "Nangka", "Mentimun", "Terong"].contains(p));
    bool hasAphidHost = nearbyPlants.any((p) => ["Melon", "Terong"].contains(p));
    bool hasThripsHost = nearbyPlants.contains("Cabai Rawit"); 

    // ============================================================
    // 1. LALAT BUAH (Bactrocera spp.)
    // ============================================================
    // Pemicu: Fase Generatif (Berbuah), Hujan/Lembap, Inang Alternatif
    double lalatScore = _calculateScore(0.05, [
      (farm.currentPhase.contains("Berbuah")) ? 0.40 : 0.0,
      (isRaining || weather.season.contains("Hujan")) ? 0.30 : 0.0,
      (hasFruitFlyHost) ? 0.20 : 0.0, // Inang sangat berpengaruh
    ]);

    if (lalatScore > 0.25) {
      results.add(PredictionResult(
        pestName: "Lalat Buah (Bactrocera spp.)",
        percentage: lalatScore,
        riskLevel: _getRiskLevel(lalatScore),
        description: "Fase berbuah ditambah kondisi basah memicu lalat buah menusuk kulit buah yang lunak.",
        preventionSteps: [
          "Mekanis: Pasang perangkap Metil Eugenol (40 buah/Ha).",
          "Sanitasi: Kubur buah yang jatuh agar larva mati.",
          "Pupuk: Tambah unsur Kalium (K) agar kulit buah lebih keras.",
          "Ambang: Waspada jika >13 ekor/perangkap.",
        ],
      ));
    }

    // ============================================================
    // 2. KUTU DAUN PERSIK & KUTU KEBUL (Vektor Virus)
    // ============================================================
    // Pemicu: Fase Vegetatif (Tunas Muda), Cuaca Panas/Kering (Optimum 32°C)
    double kutuScore = _calculateScore(0.05, [
      (farm.currentPhase == "Vegetatif" || farm.currentPhase == "Bibit") ? 0.35 : 0.0,
      (isDrySeason || isVeryHot) ? 0.35 : 0.0, // Suhu 32°C ideal
      (hasAphidHost) ? 0.15 : 0.0,
    ]);

    if (kutuScore > 0.25) {
      results.add(PredictionResult(
        pestName: "Kutu Kebul & Kutu Daun",
        percentage: kutuScore,
        riskLevel: _getRiskLevel(kutuScore),
        description: "Cuaca panas (>30°C) dan tunas muda memicu ledakan populasi kutu pembawa virus kuning.",
        preventionSteps: [
          "Mekanis: Pasang Yellow Trap (Perangkap Kuning) 100-200 ekor/trap.",
          "Musuh Alami: Jaga populasi Kumbang Kura (Menochilus).",
          "Tumpangsari: Tanam Jagung sebagai barier (penghalang).",
          "Hindari N berlebih: Agar tanaman tidak terlalu sukulen (lunak).",
        ],
      ));
    }

    // ============================================================
    // 3. PENYAKIT ANTRAKNOSA (Patek) - HIGH PRIORITY
    // ============================================================
    // Pemicu: Kelembapan Sangat Tinggi (>90%), Suhu < 32°C
    double antraknosaScore = _calculateScore(0.05, [
      (isVeryHumid) ? 0.50 : (isHumid ? 0.30 : 0.0),
      (weather.temperature < 32) ? 0.20 : 0.0,
      (farm.currentPhase.contains("Berbuah")) ? 0.20 : 0.0,
    ]);

    if (antraknosaScore > 0.3) {
      results.add(PredictionResult(
        pestName: "Penyakit Antraknosa (Jamur)",
        percentage: antraknosaScore,
        riskLevel: _getRiskLevel(antraknosaScore),
        description: "Kelembapan tinggi (>90%) memicu spora jamur Colletotrichum berkembang pesat pada buah.",
        preventionSteps: [
          "Sanitasi: Segera petik dan musnahkan buah yang ada bercak.",
          "Drainase: Pastikan air tidak menggenang di lahan.",
          "Jarak Tanam: Jangan terlalu rapat agar sirkulasi udara lancar.",
          "Fungisida: Gunakan jika serangan meluas.",
        ],
      ));
    }

    // ============================================================
    // 4. ULAT GRAYAK (Spodoptera litura)
    // ============================================================
    // Pemicu: Lahan Lembab (terutama Mulsa), Suhu < 28°C (tidak aktif jika panas terik)
    double ulatScore = _calculateScore(0.05, [
      (farm.isMulchUsed) ? 0.35 : 0.0, // Mulsa bikin lembab bawahnya
      (isHumid) ? 0.25 : 0.0,
      (!isVeryHot) ? 0.20 : 0.0, // Mati di suhu >38°C
    ]);

    if (ulatScore > 0.25) {
      results.add(PredictionResult(
        pestName: "Ulat Grayak",
        percentage: ulatScore,
        riskLevel: _getRiskLevel(ulatScore),
        description: "Penggunaan mulsa menciptakan iklim mikro lembap yang disukai ulat.",
        preventionSteps: [
          "Mekanis: Cek lubang mulsa saat malam/sore hari, ambil ulat.",
          "Sanitasi: Bersihkan gulma di sekitar lubang tanam.",
          "Teknis: Penggenangan sesaat untuk mematikan larva di tanah.",
        ],
      ));
    }

    // ============================================================
    // 5. THRIPS
    // ============================================================
    // Pemicu: Kemarau (Hujan mencuci mereka), Inang Cabai Rawit
    double thripsScore = _calculateScore(0.05, [
      (isDrySeason) ? 0.45 : 0.0,
      (hasThripsHost) ? 0.25 : 0.0,
    ]);

    if (thripsScore > 0.25) {
      results.add(PredictionResult(
        pestName: "Thrips (Daun Keriting)",
        percentage: thripsScore,
        riskLevel: _getRiskLevel(thripsScore),
        description: "Cuaca kering mendukung Thrips. Hujan lebat biasanya mencuci hama ini.",
        preventionSteps: [
          "Mekanis: Gunakan Mulsa Perak (pantulan cahaya tidak disukai Thrips).",
          "PHT: Tanam Kenikir Kuning sebagai tanaman perangkap.",
          "Monitoring: Cek pucuk daun muda jika keriting.",
        ],
      ));
    }

    // Sort dari risiko tertinggi
    results.sort((a, b) => b.percentage.compareTo(a.percentage));
    return results;
  }
}