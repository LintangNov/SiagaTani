class WeatherModel {
  final double temperature;
  final double humidity;
  final String condition; // "Hujan", "Cerah", "Berawan"
  final String season;    // "Musim Hujan", "Musim Kemarau"
  final double windSpeed;

  WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.season,
    required this.windSpeed,
  });
}