import '../models/weather_model.dart';

class DummyWeatherService {
  // Simulasi ambil data cuaca
  Future<WeatherModel> getCurrentWeather() async {
    await Future.delayed(Duration(milliseconds: 800)); // pura-puranya loading

    
    return WeatherModel(
      // temperature: 28.5,      // Suhu (C)
      // humidity: 85.0,         // Kelembapan (%)
      // condition: "Hujan Ringan", 
      // season: "Musim Hujan",  
      // windSpeed: 15.0,        // km/h

      
      temperature: 30.3,      // Suhu (C)
      humidity: 48.2,         // Kelembapan (%)
      condition: "Berawan", 
      season: "Musim Kemarau",  // Penting untuk logika
      windSpeed: 15.0,        // km/h
    
      /* 
      temperature: 32.5,      // Suhu (C)
      humidity: 60.2,         // Kelembapan (%)
      condition: "Cerah", 
      season: "Musim Kemarau",  // Penting untuk logika
      windSpeed: 17.0,        // km/h
      */
    );
  }
}