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
  final predictionResults = <PredictionResult>[].obs;
  final isAnalyzing = false.obs;

  final weatherData = Rxn<WeatherModel>(); 
  final forecastData = Rxn<WeatherModel>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is FarmModel) {
      farm = Get.arguments;
    }
  }

  Future<void> runAnalysis() async {
    isAnalyzing.value = true;
    predictionResults.clear();

    try {
      final results = await Future.wait([
        _weatherService.getWeatherByLocation(farm.latitude, farm.longitude),
        _weatherService.getForecastByLocation(farm.latitude, farm.longitude),
      ]);

      weatherData.value = results[0];
      forecastData.value = results[1];

      final allPins = await _firestoreService.getAllPins();
      const distance = Distance();
      final nearbyPlants = <String>[];

      for (var pin in allPins) {
        final double meters = distance.as(
          LengthUnit.Meter,
          LatLng(farm.latitude, farm.longitude),
          LatLng(pin.latitude, pin.longitude),
        );
        
        if (meters <= 1000) {
          nearbyPlants.add(pin.plantType);
        }
      }

      final analysis = _predictionService.analyzeRisk(
        farm,
        weatherData.value!,
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