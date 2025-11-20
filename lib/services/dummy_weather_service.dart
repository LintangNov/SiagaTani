import '../models/weather_model.dart';

class DummyWeatherService {
  // Simulasi ambil data cuaca
  Future<WeatherModel> getCurrentWeather() async {
    await Future.delayed(Duration(milliseconds: 800)); // Pura-pura loading

    // --- UBAH DATA DI SINI UNTUK TEST SKENARIO ---
    return WeatherModel(
      temperature: 28.5,      // Suhu (C)
      humidity: 85.0,         // Kelembapan (%)
      condition: "Hujan Ringan", 
      season: "Musim Hujan",  // Penting untuk logika
      windSpeed: 15.0,        // km/h
    );
  }
}