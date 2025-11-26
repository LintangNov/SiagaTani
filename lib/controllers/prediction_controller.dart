import 'package:get/get.dart';
import '../models/farm_model.dart';
import '../models/weather_model.dart';
import '../models/prediction_result.dart';
import '../models/surrounding_pin_model.dart';
import '../services/weather_service.dart'; // Pakai API Asli
import '../services/prediction_service.dart';
import '../services/firestore_service.dart';
import '../utils/ui_utils.dart';

class PredictionController extends GetxController {
  // Ganti Dummy dengan Real Service
  final WeatherService _weatherService = WeatherService(); 
  final PredictionService _predictionService = PredictionService();
  final FirestoreService _firestoreService = FirestoreService();

  late FarmModel farm;
  var predictionResults = <PredictionResult>[].obs;
  var isAnalyzing = false.obs;
  var weatherData = Rxn<WeatherModel>();

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
      // 1. Ambil Data Cuaca REAL-TIME berdasarkan LOKASI LAHAN
      // (Menggunakan farm.latitude dan farm.longitude)
      WeatherModel weather = await _weatherService.getWeatherByLocation(
        farm.latitude, 
        farm.longitude
      );
      
      weatherData.value = weather;

      // 2. Ambil Data Tanaman Sekitar dari Database
      List<SurroundingPinModel> pins = await _firestoreService.getAllPins();
      List<String> nearbyPlants = pins.map((e) => e.plantType).toList();

      // 3. Jalankan Analisis Algoritma
      List<PredictionResult> results = _predictionService.analyzeRisk(
        farm,
        weather,
        nearbyPlants,
      );
      predictionResults.assignAll(results);
      
    } catch (e) {
      UiUtils.showError("Gagal analisis: $e");
      print("Error Analysis: $e");
    } finally {
      isAnalyzing.value = false;
    }
  }
}