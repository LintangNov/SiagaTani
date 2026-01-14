import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  final String baseUrl = "https://api.openweathermap.org/data/2.5";

  Future<WeatherModel> getWeatherByLocation(double lat, double lng) async {
    if (apiKey.isEmpty) throw Exception("API Key kosong. Cek .env!");
    
    final Uri url = Uri.parse('$baseUrl/weather?lat=$lat&lon=$lng&appid=$apiKey&units=metric&lang=id');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Gagal load cuaca");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<WeatherModel> getForecastByLocation(double lat, double lng) async {
    if (apiKey.isEmpty) throw Exception("API Key kosong. Cek .env!");
    
    final Uri url = Uri.parse('$baseUrl/forecast?lat=$lat&lon=$lng&appid=$apiKey&units=metric&lang=id');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var forecastData = data['list'][8]; 
        
        return WeatherModel(
          temperature: (forecastData['main']['temp'] as num).toDouble(),
          humidity: (forecastData['main']['humidity'] as num).toDouble(),
          condition: forecastData['weather'][0]['description'],
          season: "Unknown",
          windSpeed: (forecastData['wind']['speed'] as num).toDouble(),
          rainfall24h: 0, 
          maxTemp: 0,
        );
      } else {
        throw Exception("Gagal load forecast");
      }
    } catch (e) {
      throw Exception("Error Forecast: $e");
    }
  }
}