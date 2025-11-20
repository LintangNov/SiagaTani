import 'package:get/get.dart';
import '../models/farm_model.dart';
import '../models/weather_model.dart';
import '../models/prediction_result.dart';
import '../models/surrounding_pin_model.dart'; // Import model pin
import '../services/dummy_weather_service.dart';
import '../services/prediction_service.dart';
import '../services/firestore_service.dart'; // Import firestore service

class PredictionController extends GetxController {
  final DummyWeatherService _weatherService = DummyWeatherService();
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
      // 1. Ambil Data Cuaca
      WeatherModel weather = await _weatherService.getCurrentWeather();
      weatherData.value = weather;

      // 2. Ambil Data Tanaman Sekitar (Untuk Cek Inang)
      // Kita ambil semua pin di sekitar (logika filter jarak 1km bisa dilakukan di service/controller ini)
      List<SurroundingPinModel> pins = await _firestoreService.getAllPins();
      
      // Konversi ke list String nama tanaman untuk mempermudah service
      // (Di aplikasi real, tambahkan logika filter jarak latitude/longitude di sini)
      List<String> nearbyPlants = pins.map((e) => e.plantType).toList();

      // 3. Jalankan Analisis dengan Data Lengkap
      List<PredictionResult> results = _predictionService.analyzeRisk(
        farm, 
        weather, 
        nearbyPlants
      );
      
      predictionResults.assignAll(results);
      
    } catch (e) {
      Get.snackbar("Error", "Gagal analisis: $e");
    } finally {
      isAnalyzing.value = false;
    }
  }
}