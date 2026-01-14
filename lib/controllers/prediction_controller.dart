import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../models/farm_model.dart';
import '../models/weather_model.dart';
import '../models/prediction_result.dart';
import '../services/weather_service.dart';
import '../services/prediction_service.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';

class PredictionController extends GetxController {
  final WeatherService _weatherService = WeatherService();
  final PredictionService _predictionService = PredictionService();
  final FirestoreService _firestoreService = FirestoreService();
  final AIService _aiService = AIService();

  FarmModel? farm; 
  final predictionResults = <PredictionResult>[].obs;
  final isAnalyzing = false.obs;
  
  final weatherData = Rxn<WeatherModel>();
  final forecastData = Rxn<WeatherModel>();

  var aiAdvice = "".obs;
  var isLoadingAI = false.obs;

  @override
  void onInit() {
    super.onInit();
   
    if (Get.arguments != null && Get.arguments is FarmModel) {
      farm = Get.arguments;
      runAnalysis(); 
    } else {
      Get.snackbar("Error", "Data lahan tidak ditemukan atau tidak valid");
    }
  }

  Future<void> runAnalysis() async {
    final currentFarm = farm;
    if (currentFarm == null) return; 
    
    isAnalyzing.value = true;
    predictionResults.clear();
    aiAdvice.value = ""; 

    try {
      final results = await Future.wait([
        _weatherService.getWeatherByLocation(currentFarm.latitude, currentFarm.longitude),
        _weatherService.getForecastByLocation(currentFarm.latitude, currentFarm.longitude),
      ]);

      if (results[0] != null) {
        weatherData.value = results[0];
        forecastData.value = results[1];
        
        final allPins = await _firestoreService.getAllPins();
        const distance = Distance();
        final nearbyPlants = <String>[];

        for (var pin in allPins) {
          final double meters = distance.as(
            LengthUnit.Meter,
            LatLng(currentFarm.latitude, currentFarm.longitude),
            LatLng(pin.latitude, pin.longitude),
          );
          
          if (meters <= 1000) { 
            nearbyPlants.add(pin.plantType);
          }
        }

        final analysis = _predictionService.analyzeRisk(
          currentFarm,
          weatherData.value!,
          nearbyPlants,
        );
        
        predictionResults.assignAll(analysis);

        if (predictionResults.isNotEmpty) {
          fetchAISuggestion();
        }
      }
    } catch (e) {
      print("Error Analysis: $e");
      Get.snackbar("Kesalahan", "Gagal memproses analisis risiko hama.");
    } finally {
      isAnalyzing.value = false;
    }
  }

  Future<void> fetchAISuggestion() async {
    if (predictionResults.isEmpty || weatherData.value == null || farm == null) return;
    
    isLoadingAI.value = true;
    
    try {
      final advice = await _aiService.generateSmartAdvice(
        weather: weatherData.value!,
        farm: farm!, 
        risks: predictionResults, 
      );
      aiAdvice.value = advice;
    } catch (e) {
      print("AI Error: $e");
      aiAdvice.value = "Saran dari asisten AI gagal dimuat.";
    } finally {
      isLoadingAI.value = false;
    }
  }
}