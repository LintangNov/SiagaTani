import '../models/farm_model.dart';
import '../models/weather_model.dart';

class PredictionResult {
  final String pestName;
  final String riskLevel; // "TINGGI", "SEDANG", "WASPADA"
  final String description;
  final String preventionAdvice;

  PredictionResult({
    required this.pestName,
    required this.riskLevel,
    required this.description,
    required this.preventionAdvice,
  });
}

class PredictionService {
  
  List<PredictionResult> analyzeRisk(FarmModel farm, WeatherModel weather) {
    List<PredictionResult> results = [];

    // 1. LOGIKA LALAT BUAH (Bactrocera sp.)
    // Pemicu: Fase Buah Matang + Musim Hujan + Inang di sekitar
    if ((farm.currentPhase == 'Berbuah Muda' || farm.currentPhase == 'Berbuah Matang') &&
        weather.season == 'Musim Hujan') {
      
      results.add(PredictionResult(
        pestName: "Lalat Buah",
        riskLevel: "TINGGI",
        description: "Fase berbuah di musim hujan memicu kulit buah lunak yang disukai lalat buah untuk bertelur.",
        preventionAdvice: "Pasang perangkap feromon (petrogenol) sekarang. Bungkus buah jika memungkinkan. Sanitasi buah yang jatuh busuk.",
      ));
    }

    // 2. LOGIKA KUTU DAUN & KUTU KEBUL (Virus)
    // Pemicu: Fase Vegetatif (Muda) + Cuaca Kering/Panas + Suhu > 30
    bool isHotAndDry = (weather.season == 'Musim Kemarau' || weather.temperature > 30);
    if (farm.currentPhase == 'Vegetatif' && isHotAndDry) {
      
      results.add(PredictionResult(
        pestName: "Kutu Daun & Kutu Kebul (Vektor Virus)",
        riskLevel: "TINGGI",
        description: "Suhu panas (${weather.temperature}°C) dan fase vegetatif memicu ledakan populasi kutu penghisap cairan.",
        preventionAdvice: "Pasang Yellow Trap (Perangkap Kuning). Semprot insektisida berbahan aktif Imidakloprid jika populasi tinggi. Jaga kelembapan tanah.",
      ));
    }

    // 3. LOGIKA THRIPS
    // Pemicu: Musim Kemarau (Hujan mencuci Thrips, Kemarau menyuburkan)
    if (weather.season == 'Musim Kemarau') {
      results.add(PredictionResult(
        pestName: "Hama Thrips",
        riskLevel: "WASPADA",
        description: "Cuaca kering mendukung perkembangan Thrips yang menyebabkan daun keriting ke atas.",
        preventionAdvice: "Lakukan penyiraman (sprinkler) untuk mencuci hama dari daun. Monitor punggung daun muda.",
      ));
    }

    // 4. LOGIKA ULAT GRAYAK
    // Pemicu: Lahan Lembab + Pakai Mulsa + Musim Hujan
    if (farm.isMulchUsed && weather.season == 'Musim Hujan') {
      results.add(PredictionResult(
        pestName: "Ulat Grayak",
        riskLevel: "SEDANG",
        description: "Penggunaan mulsa di musim hujan menciptakan iklim mikro lembap yang disukai ulat grayak untuk bersembunyi.",
        preventionAdvice: "Cek lubang tanam pada mulsa saat sore/malam hari. Lakukan penggenangan sesaat jika serangan parah.",
      ));
    }
    
    // Jika tidak ada deteksi
    if (results.isEmpty) {
      results.add(PredictionResult(
        pestName: "Kondisi Aman",
        riskLevel: "AMAN",
        description: "Tidak terdeteksi risiko hama mayor berdasarkan parameter saat ini.",
        preventionAdvice: "Tetap lakukan monitoring rutin harian.",
      ));
    }

    return results;
  }
}