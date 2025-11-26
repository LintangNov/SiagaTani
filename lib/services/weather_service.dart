import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import ini
import '../models/weather_model.dart';

class WeatherService {
  // Panggil dari .env. Jika tidak ada, kembalikan string kosong (biar gak error null)
  final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? ''; 
  
  final String baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  Future<WeatherModel> getWeatherByLocation(double lat, double lng) async {
    // Validasi kecil biar dev tau kalau lupa bikin .env
    if (apiKey.isEmpty) {
      throw Exception("API Key tidak ditemukan. Pastikan file .env sudah dibuat!");
    }

    final Uri url = Uri.parse('$baseUrl?lat=$lat&lon=$lng&appid=$apiKey&units=metric&lang=id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception("Gagal ambil data cuaca: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error koneksi: $e");
    }
  }
}