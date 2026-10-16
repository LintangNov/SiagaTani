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

  /// Mengembalikan maksimal 3 langkah singkat. Melempar galat bila AI gagal
  /// atau jawabannya kosong, supaya UI bisa menampilkan state gagal.
  Future<List<String>> generateSmartSteps({
    required WeatherModel weather,
    required FarmModel farm,
    required List<PredictionResult> risks,
  }) async {
    final String riskString = risks
        .map((r) => '- ${r.pestName}: ${r.shortDescription}')
        .join('\n');

    final prompt =
        '''
      Anda adalah asisten pertanian untuk aplikasi "Siaga Tani", pengguna Anda petani cabai berusia lanjut.

      KONDISI SAAT INI:
      - Cuaca: ${weather.condition}, suhu ${weather.temperature}°C, kelembapan ${weather.humidity}%
      - Lahan: varietas ${farm.variety}, fase ${farm.currentPhase}

      RISIKO HAMA HARI INI:
      $riskString

      TUGAS:
      Tulis 3 langkah tindakan paling penting untuk hari ini. Satu langkah per baris,
      maksimal 18 kata, kalimat perintah yang mudah dipahami.
      Jangan beri nomor, jangan pakai format Markdown.
      DILARANG menyebut dosis, takaran, atau merek dagang. Sebut tindakan umum saja.
    ''';

    final response = await _model.generateContent([Content.text(prompt)]);
    final steps = (response.text ?? '')
        .split('\n')
        .map((l) => l.replaceFirst(RegExp(r'^\s*(\d+[.)]|[-•*])\s*'), '').trim())
        .where((l) => l.isNotEmpty)
        .take(3)
        .toList();

    if (steps.isEmpty) throw StateError('Jawaban AI kosong');
    return steps;
  }
}
