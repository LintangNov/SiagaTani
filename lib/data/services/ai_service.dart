import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';
import '../models/farm_model.dart';
import '../models/prediction_result.dart';

class AIService {
  static final String _apiKey = dotenv.env['GOOGLE_GEMINI_API_KEY'] ?? '';
  final GenerativeModel _model;

  AIService()
    : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);

  Future<String> generateSmartAdvice({
    required WeatherModel weather,
    required FarmModel farm,
    required List<PredictionResult> risks,
  }) async {
    final String riskString = risks
        .map(
          (r) =>
              '- ${r.pestName} (${(r.percentage * 100).toInt()}%): ${r.shortDescription}',
        )
        .join('\n');

    final prompt =
        '''
      Anda adalah asisten ahli pertanian cerdas untuk aplikasi "Siaga Tani".
      
      KONDISI SAAT INI:
      - Cuaca: ${weather.condition}, Suhu ${weather.temperature}°C, Kelembapan ${weather.humidity}%
      - Lahan: Varietas ${farm.variety}, Fase ${farm.currentPhase}, Mulsa ${farm.mulchType}
      
      HASIL PREDIKSI RISIKO HAMA:
      $riskString
      
      TUGAS:
      Berikan 1 paragraf saran aksi singkat (maksimal 3 kalimat) yang sangat praktis bagi petani hari ini. 
      Jika ada risiko tinggi, prioritaskan pencegahannya. Gunakan bahasa yang santai namun profesional seperti seorang penyuluh pertanian lapangan.
      Jangan gunakan format Markdown (seperti **bold** atau #).
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Tetap pantau kondisi lahan secara rutin!';
    } catch (e) {
      debugPrint('AIService error: $e');
      return 'Gagal terhubung dengan asisten AI. Pastikan koneksi internet tersedia.';
    }
  }
}
