import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../models/farm_model.dart';
import '../models/weather_model.dart';
import '../models/prediction_result.dart';
import '../models/surrounding_pin_model.dart';
import '../services/weather_service.dart';
import '../services/prediction_service.dart';
import '../services/firestore_service.dart';

class PredictionController extends GetxController {
  final WeatherService _weatherService = WeatherService();
  final PredictionService _predictionService = PredictionService();
  final FirestoreService _firestoreService = FirestoreService();

  late FarmModel farm;
  var predictionResults = <PredictionResult>[].obs;
  var isAnalyzing = false.obs;

  var weatherData = Rxn<WeatherModel>(); // Cuaca Saat Ini
  var forecastData = Rxn<WeatherModel>(); // Ramalan Besok (BARU)

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is FarmModel) {
      farm = Get.arguments;
    }
  }

  Future<void> runAnalysis() async {
    isAnalyzing.value = true;
    predictionResults.clear();

    try {
      // 1. Ambil Cuaca Saat Ini & BESOK (Parallel biar cepat)
      var weatherFuture = _weatherService.getWeatherByLocation(
        farm.latitude,
        farm.longitude,
      );
      var forecastFuture = _weatherService.getForecastByLocation(
        farm.latitude,
        farm.longitude,
      );

      var results = await Future.wait([weatherFuture, forecastFuture]);

      WeatherModel currentWeather = results[0];
      WeatherModel tomorrowWeather = results[1];

      weatherData.value = currentWeather;
      forecastData.value = tomorrowWeather;

      // 2. Ambil Pin Tetangga (Filter Radius 1 KM)
      List<SurroundingPinModel> allPins = await _firestoreService.getAllPins();
      const Distance distance = Distance();
      List<String> nearbyPlants = [];

      for (var pin in allPins) {
        double km = distance.as(
          LengthUnit.Meter,
          LatLng(farm.latitude, farm.longitude),
          LatLng(pin.latitude, pin.longitude),
        );
        if (km <= 1000) {
          nearbyPlants.add(pin.plantType);
        }
      }

      // 3. Analisis (Pakai cuaca saat ini)
      List<PredictionResult> analysis = _predictionService.analyzeRisk(
        farm,
        currentWeather,
        nearbyPlants,
      );
      predictionResults.assignAll(analysis);
    } catch (e) {
      print("Error Analysis: $e");
    } finally {
      isAnalyzing.value = false;
    }
  }
}
