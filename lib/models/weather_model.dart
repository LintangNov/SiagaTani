// File: lib/models/weather_model.dart

class WeatherModel {
  final double temperature; // Suhu saat ini
  final double humidity;    // Kelembapan (%)
  final String condition;   // Kondisi ("Hujan", "Cerah")
  final String season;      // ("Musim Hujan", "Musim Kemarau")
  final double windSpeed;   // Kecepatan angin (km/h)
  
  final double rainfall24h; // Total hujan 24 jam (mm)
  final double maxTemp;     // Suhu maksimum hari ini
  final int wetHours;       // Estimasi jam daun basah (Penting untuk Antraknosa)
  
  // Getter alias untuk kompatibilitas dengan kode PredictionService
  double get currentTemp => temperature;
  double get maxTemp24h => maxTemp; // Alias agar maxTemp24h terbaca

  WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.season,
    required this.windSpeed,
    this.rainfall24h = 0.0, 
    this.maxTemp = 30.0,
    this.wetHours = 0, // Default 0
  });
}