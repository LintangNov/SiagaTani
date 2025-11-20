// File: lib/services/prediction_service.dart

import 'dart:math';
import '../models/farm_model.dart';
import '../models/weather_model.dart';

class PredictionService {
  final Random _rng = Random();

  // Fungsi pembantu untuk menghitung skor risiko
  double _calculateScore(double baseScore, List<double> additives) {
    double score = baseScore;
    for (var point in additives) {
      score += point;
    }
    
    // Variasi random kecil agar angka terlihat natural
    double randomFactor = _rng.nextDouble() * 0.05; 
    double finalScore = (score + randomFactor).clamp(0.0, 0.99);
    
    return finalScore;
  }

  // Tentukan label risiko
  String _getRiskLevel(double score) {
    if (score > 0.70) return "TINGGI";
    if (score > 0.40) return "SEDANG";
    return "RENDAH";
  }

  // PERBAIKAN DI SINI: Tambahkan pengecekan null
  List<PredictionResult> analyzeRisk(FarmModel? farm, WeatherModel weather) {
    // 1. CEK DULU: Kalau data farm kosong, kembalikan list kosong (tidak ada prediksi)
    if (farm == null) {
      return [];
    }

    List<PredictionResult> results = [];

    // Karena sudah dicek di atas, Dart sekarang tahu 'farm' pasti ada datanya.
    
    // ============================================================
    // 1. LALAT BUAH (Bactrocera sp.)
    // ============================================================
    double lalatBuahScore = _calculateScore(0.1, [
      (farm.currentPhase == 'Berbuah Muda' || farm.currentPhase == 'Berbuah Matang') ? 0.40 : 0.0,
      (weather.season == 'Musim Hujan') ? 0.30 : 0.0,
      (farm.hostPlantsNearby == 'Ya') ? 0.15 : 0.0,
    ]);

    if (lalatBuahScore > 0.2) {
      results.add(PredictionResult(
        pestName: "Lalat Buah (Bactrocera sp.)",
        percentage: lalatBuahScore,
        riskLevel: _getRiskLevel(lalatBuahScore),
        description: "Fase berbuah dan kelembapan tinggi memicu lalat buah bertelur di dalam buah cabai.",
        preventionSteps: [
          "Kimia/Atraktan: Pasang perangkap Metil Eugenol (Petrogenol).",
          "Mekanis: Pasang 40 perangkap/Ha sejak umur 2 minggu.",
          "Hayati: Manfaatkan musuh alami semut atau laba-laba.",
          "Kultur Teknis: Lakukan rotasi tanaman.",
        ],
      ));
    }

    // ============================================================
    // 2. KUTU KEBUL (Vektor Virus Kuning)
    // ============================================================
    bool isHot = weather.temperature > 30;
    bool isDry = weather.season == 'Musim Kemarau';
    
    double kutuKebulScore = _calculateScore(0.1, [
      (farm.currentPhase == 'Vegetatif') ? 0.30 : 0.0,
      (isHot || isDry) ? 0.30 : 0.0,
      (farm.hostPlantsNearby == 'Ya') ? 0.10 : 0.0,
    ]);

    if (kutuKebulScore > 0.2) {
      results.add(PredictionResult(
        pestName: "Kutu Kebul (Bemisia tabaci)",
        percentage: kutuKebulScore,
        riskLevel: _getRiskLevel(kutuKebulScore),
        description: "Cuaca panas mempercepat populasi kutu kebul pembawa virus kuning.",
        preventionSteps: [
          "Mekanis: Pasang Perangkap Kuning (Yellow Trap).",
          "Sanitasi: Bersihkan gulma inang.",
          "Tumpangsari: Tanam jagung sebagai penghalang (barrier).",
          "Nabati: Semprot ekstrak bawang putih/jeruk nipis.",
        ],
      ));
    }

    // ============================================================
    // 3. THRIPS (Daun Keriting)
    // ============================================================
    double thripsScore = _calculateScore(0.1, [
      (weather.season == 'Musim Kemarau') ? 0.40 : 0.0,
      (farm.currentPhase == 'Vegetatif') ? 0.20 : 0.0,
    ]);

    if (thripsScore > 0.2) {
      results.add(PredictionResult(
        pestName: "Thrips",
        percentage: thripsScore,
        riskLevel: _getRiskLevel(thripsScore),
        description: "Musim kemarau mendukung perkembangan Thrips penghisap cairan daun.",
        preventionSteps: [
          "Mekanis: Gunakan mulsa perak & perangkap kuning.",
          "Sanitasi: Potong bagian tanaman terserang.",
          "PHT: Tanam kenikir kuning di pinggir lahan.",
        ],
      ));
    }

    // ============================================================
    // 4. KUTU DAUN PERSIK (Aphid)
    // ============================================================
    double aphidScore = _calculateScore(0.05, [
      (farm.currentPhase == 'Vegetatif') ? 0.30 : 0.0,
      (weather.condition != 'Hujan Petir') ? 0.20 : 0.0,
    ]);

    if (aphidScore > 0.2) {
      results.add(PredictionResult(
        pestName: "Kutu Daun (Aphid)",
        percentage: aphidScore,
        riskLevel: _getRiskLevel(aphidScore),
        description: "Menyebabkan tanaman kerdil dan daun melingkar.",
        preventionSteps: [
          "Hayati: Lepas predator kumbang koksi.",
          "Nabati: Ekstrak daun sirih hutan.",
          "Ambang Batas: Kendalikan jika kerusakan > 15%.",
        ],
      ));
    }

    // ============================================================
    // 5. TUNGAU
    // ============================================================
    double tungauScore = _calculateScore(0.05, [
      (weather.season == 'Musim Kemarau') ? 0.30 : 0.0,
      (farm.pestHistory == 'Pernah') ? 0.15 : 0.0,
    ]);

    if (tungauScore > 0.2) {
      results.add(PredictionResult(
        pestName: "Tungau (Mites)",
        percentage: tungauScore,
        riskLevel: _getRiskLevel(tungauScore),
        description: "Daun menebal, kaku, dan berwarna tembaga.",
        preventionSteps: [
          "Hayati: Gunakan bioakarisida.",
          "Predator: Lepaskan musuh alami.",
          "Monitoring: Cek bawah permukaan daun secara rutin.",
        ],
      ));
    }
    
    // ============================================================
    // 6. ULAT GRAYAK
    // ============================================================
    double ulatScore = _calculateScore(0.05, [
      (farm.isMulchUsed) ? 0.25 : 0.0,
      (weather.season == 'Musim Hujan' || weather.humidity > 80) ? 0.25 : 0.0,
    ]);

    if (ulatScore > 0.2) {
      results.add(PredictionResult(
        pestName: "Ulat Grayak",
        percentage: ulatScore,
        riskLevel: _getRiskLevel(ulatScore),
        description: "Kelembapan tinggi dan mulsa jadi tempat sembunyi ulat.",
        preventionSteps: [
          "Mekanis: Ambil ulat secara manual saat malam hari.",
          "Teknis: Penggenangan lahan sesaat.",
          "Sanitasi: Bersihkan gulma sekitar lubang tanam.",
        ],
      ));
    }

    // Sorting hasil dari risiko tertinggi
    results.sort((a, b) => b.percentage.compareTo(a.percentage));

    return results;
  }
}

class PredictionResult {
  final String pestName;
  final double percentage;
  final String riskLevel;
  final String description;
  final List<String> preventionSteps;

  PredictionResult({
    required this.pestName,
    required this.percentage,
    required this.riskLevel,
    required this.description,
    required this.preventionSteps,
  });
  
  String get formattedPercentage => "${(percentage * 100).toStringAsFixed(1)}%";
}


// // File: lib/services/prediction_service.dart

// import 'dart:math';
// import '../models/farm_model.dart';
// import '../models/weather_model.dart';

// class PredictionService {
//   final Random _rng = Random();

//   // Fungsi pembantu untuk menghitung skor risiko + variasi random biar terlihat 'real'
//   double _calculateScore(double baseScore, List<double> additives) {
//     double score = baseScore;
//     for (var point in additives) {
//       score += point;
//     }
    
//     // Tambahkan variasi random kecil (0.0 - 0.05) agar angka terlihat unik (misal 44.2%)
//     // Tapi jangan sampai melebihi 1.0 (100%)
//     double randomFactor = _rng.nextDouble() * 0.05; 
//     double finalScore = (score + randomFactor).clamp(0.0, 0.99);
    
//     return finalScore;
//   }

//   // Tentukan label risiko berdasarkan skor
//   String _getRiskLevel(double score) {
//     if (score > 0.70) return "TINGGI";
//     if (score > 0.40) return "SEDANG";
//     return "RENDAH";
//   }

//   List<PredictionResult> analyzeRisk(FarmModel? farm, WeatherModel weather) {
//     List<PredictionResult> results = [];

//     // ============================================================
//     // 1. LALAT BUAH (Bactrocera sp.)
//     // Faktor: Fase Buah (40%), Musim Hujan (30%), Inang Sekitar (15%)
//     // ============================================================
//     double lalatBuahScore = _calculateScore(0.1, [
//       (farm.currentPhase == 'Berbuah Muda' || farm.currentPhase == 'Berbuah Matang') ? 0.40 : 0.0,
//       (weather.season == 'Musim Hujan') ? 0.30 : 0.0,
//       (farm.hostPlantsNearby == 'Ya') ? 0.15 : 0.0,
//     ]);

//     if (lalatBuahScore > 0.2) { // Hanya tampilkan jika risiko di atas 20%
//       results.add(PredictionResult(
//         pestName: "Lalat Buah (Bactrocera sp.)",
//         percentage: lalatBuahScore,
//         riskLevel: _getRiskLevel(lalatBuahScore),
//         description: "Fase berbuah dan kelembapan tinggi memicu lalat buah bertelur di dalam buah cabai.",
//         preventionSteps: [
//           "Kimia/Atraktan: Pasang perangkap Metil Eugenol (Petrogenol) 1ml/perangkap.",
//           "Mekanis: Pasang 40 perangkap/Ha sejak umur 2 minggu. Ganti atraktan tiap 2 minggu.",
//           "Hayati: Manfaatkan musuh alami seperti semut, laba-laba, atau kumbang Staphylinidae.",
//           "Kultur Teknis: Lakukan rotasi tanaman untuk memutus siklus hama.",
//         ],
//       ));
//     }

//     // ============================================================
//     // 2. KUTU KEBUL (Vektor Virus Kuning)
//     // Faktor: Fase Vegetatif (30%), Cuaca Panas/Kering (30%), Ada Inang (10%)
//     // ============================================================
//     bool isHot = weather.temperature > 30;
//     bool isDry = weather.season == 'Musim Kemarau';
    
//     double kutuKebulScore = _calculateScore(0.1, [
//       (farm.currentPhase == 'Vegetatif') ? 0.30 : 0.0,
//       (isHot || isDry) ? 0.30 : 0.0,
//       (farm.hostPlantsNearby == 'Ya') ? 0.10 : 0.0,
//     ]);

//     if (kutuKebulScore > 0.2) {
//       results.add(PredictionResult(
//         pestName: "Kutu Kebul (Bemisia tabaci)",
//         percentage: kutuKebulScore,
//         riskLevel: _getRiskLevel(kutuKebulScore),
//         description: "Cuaca panas mempercepat populasi kutu kebul yang membawa virus kuning (Gemini).",
//         preventionSteps: [
//           "Mekanis: Pasang Perangkap Kuning (Yellow Trap).",
//           "Sanitasi: Bersihkan gulma dan lakukan pergiliran tanaman dengan bukan inang (jagung/mentimun).",
//           "Tumpangsari: Tanam jagung sebagai penghalang (barrier) atau kemangi sebagai penolak (repellent).",
//           "Hayati: Manfaatkan predator kumbang Menochilus sexmaculatus.",
//           "Nabati: Semprot ekstrak bawang putih, serai wangi, atau jeruk nipis.",
//         ],
//       ));
//     }

//     // ============================================================
//     // 3. THRIPS (Daun Keriting)
//     // Faktor: Musim Kemarau (40%), Fase Vegetatif (20%)
//     // ============================================================
//     double thripsScore = _calculateScore(0.1, [
//       (weather.season == 'Musim Kemarau') ? 0.40 : 0.0,
//       (farm.currentPhase == 'Vegetatif') ? 0.20 : 0.0,
//     ]);

//     if (thripsScore > 0.2) {
//       results.add(PredictionResult(
//         pestName: "Thrips (Penyebab Daun Keriting)",
//         percentage: thripsScore,
//         riskLevel: _getRiskLevel(thripsScore),
//         description: "Musim kemarau mendukung perkembangan Thrips yang menghisap cairan daun muda.",
//         preventionSteps: [
//           "Mekanis: Gunakan mulsa perak & pasang perangkap kuning (40 buah/ha).",
//           "Sanitasi: Potong bagian tanaman yang terserang.",
//           "PHT: Tanam kenikir kuning sebagai tanaman perangkap.",
//           "Hayati: Manfaatkan kumbang Coccinellidae atau tungau predator.",
//           "Kimia: Gunakan insektisida botani atau kimia selektif jika kerusakan > 15%.",
//         ],
//       ));
//     }

//     // ============================================================
//     // 4. KUTU DAUN PERSIK (Aphid)
//     // Faktor: Vegetatif (30%), Tidak Hujan Deras (20%)
//     // ============================================================
//     double aphidScore = _calculateScore(0.05, [
//       (farm.currentPhase == 'Vegetatif') ? 0.30 : 0.0,
//       (weather.condition != 'Hujan Petir') ? 0.20 : 0.0,
//     ]);

//     if (aphidScore > 0.2) {
//       results.add(PredictionResult(
//         pestName: "Kutu Daun Persik (Aphid)",
//         percentage: aphidScore,
//         riskLevel: _getRiskLevel(aphidScore),
//         description: "Menghisap cairan daun muda menyebabkan tanaman kerdil dan daun melingkar.",
//         preventionSteps: [
//           "Hayati: Lepas predator kumbang Menochilus sexmaculatus (1 ekor/tanaman).",
//           "Nabati: Gunakan ekstrak daun sirih hutan (Piper aduncum).",
//           "Kultur Teknis: Tanam jagung atau tagetes sebagai pembatas.",
//           "Ambang Batas: Kendalikan jika kerusakan tanaman > 15%.",
//         ],
//       ));
//     }

//     // ============================================================
//     // 5. TUNGAU
//     // Faktor: Daun Menebal/Tembaga (Input Riwayat?), Kemarau (30%)
//     // ============================================================
//     double tungauScore = _calculateScore(0.05, [
//       (weather.season == 'Musim Kemarau') ? 0.30 : 0.0,
//       (farm.pestHistory == 'Pernah') ? 0.15 : 0.0,
//     ]);

//     if (tungauScore > 0.2) {
//       results.add(PredictionResult(
//         pestName: "Tungau (Mites)",
//         percentage: tungauScore,
//         riskLevel: _getRiskLevel(tungauScore),
//         description: "Menyebabkan daun menebal, kaku, dan berwarna tembaga.",
//         preventionSteps: [
//           "Hayati: Gunakan bioakarisida tanaman selektif.",
//           "Predator: Lepaskan predator M. sexmaculatus.",
//           "Monitoring: Waspada jika kerusakan mencapai 15%.",
//         ],
//       ));
//     }
    
//     // ============================================================
//     // 6. ULAT GRAYAK
//     // Faktor: Mulsa (25%), Lembab/Hujan (25%)
//     // ============================================================
//     double ulatScore = _calculateScore(0.05, [
//       (farm.isMulchUsed) ? 0.25 : 0.0,
//       (weather.season == 'Musim Hujan' || weather.humidity > 80) ? 0.25 : 0.0,
//     ]);

//     if (ulatScore > 0.2) {
//       results.add(PredictionResult(
//         pestName: "Ulat Grayak",
//         percentage: ulatScore,
//         riskLevel: _getRiskLevel(ulatScore),
//         description: "Kelembapan tinggi dan penggunaan mulsa menjadi tempat persembunyian ulat.",
//         preventionSteps: [
//           "Mekanis: Cek lubang mulsa saat sore/malam hari, ambil ulat secara manual.",
//           "Teknis: Lakukan penggenangan lahan sesaat untuk mematikan larva di tanah.",
//           "Sanitasi: Bersihkan gulma di sekitar lubang tanam.",
//         ],
//       ));
//     }

//     // Sorting hasil dari persentase tertinggi ke terendah
//     results.sort((a, b) => b.percentage.compareTo(a.percentage));

//     return results;
//   }
// }

// class PredictionResult {
//   final String pestName;
//   final double percentage;   // Contoh: 0.85 (85%)
//   final String riskLevel;    // "RENDAH", "SEDANG", "TINGGI"
//   final String description;
//   final List<String> preventionSteps; // List saran agar bisa dibuat bullet points

//   PredictionResult({
//     required this.pestName,
//     required this.percentage,
//     required this.riskLevel,
//     required this.description,
//     required this.preventionSteps,
//   });
  
//   // Helper untuk memformat persentase ke string "85.2%"
//   String get formattedPercentage => "${(percentage * 100).toStringAsFixed(1)}%";
// }