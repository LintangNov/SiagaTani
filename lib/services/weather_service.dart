import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  // ⚠️ PENTING: Ganti dengan API Key asli kamu dari OpenWeatherMap
  final String apiKey = "be1b98742e8451e566f9e11d69bf974a"; 
  
  final String baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  Future<WeatherModel> getWeatherByLocation(double lat, double lng) async {
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