class WeatherModel {
  final double temperature;
  final double humidity;
  final String condition;
  final String season;
  final double windSpeed;
  final double rainfall24h;
  final double maxTemp;
  final int wetHours;

  double get currentTemp => temperature;
  double get maxTemp24h => maxTemp;

  WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.season,
    required this.windSpeed,
    this.rainfall24h = 0.0,
    this.maxTemp = 30.0,
    this.wetHours = 0,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    var main = json['main'];
    var weather = json['weather'][0];
    var wind = json['wind'];
    
    double rain = 0.0;
    if (json['rain'] != null && json['rain']['1h'] != null) {
      rain = (json['rain']['1h'] as num).toDouble() * 24;
    }

    int month = DateTime.now().month;
    String currentSeason = (month >= 4 && month <= 9) ? "Musim Kemarau" : "Musim Hujan";

    return WeatherModel(
      temperature: (main['temp'] as num).toDouble(),
      humidity: (main['humidity'] as num).toDouble(),
      condition: weather['description'],
      season: currentSeason,
      windSpeed: (wind['speed'] as num).toDouble() * 3.6,
      rainfall24h: rain,
      maxTemp: (main['temp_max'] as num).toDouble(),
      wetHours: (rain > 0 || (main['humidity'] as num) > 90) ? 12 : 0,
    );
  }
}