import 'package:get/get.dart';
import '../models/farm_model.dart';
import '../models/weather_model.dart';
import '../services/dummy_weather_service.dart';
import '../services/prediction_service.dart';

class PredictionController extends GetxController {
  final DummyWeatherService _weatherService = DummyWeatherService();
  final PredictionService _predictionService = PredictionService();

  // Data Lahan yang sedang dilihat (di-pass dari Dashboard)
  late FarmModel farm;

  // State
  var predictionResults = <PredictionResult>[].obs;
  var isAnalyzing = false.obs;
  var weatherData = Rxn<WeatherModel>(); // Cuaca spesifik saat analisis

  @override
  void onInit() {
    super.onInit();
    // Ambil data Farm yang dikirim via arguments Get.toNamed
    if (Get.arguments != null && Get.arguments is FarmModel) {
      farm = Get.arguments;
    }
  }

  // Fungsi Utama: Jalankan Analisis
  Future<void> runAnalysis() async {
    isAnalyzing.value = true;
    predictionResults.clear(); // Reset hasil lama

    try {
      // 1. Ambil data parameter cuaca (Dummy)
      // Di aplikasi nyata, ini bisa ambil API cuaca berdasarkan koordinat farm.latitude
      WeatherModel weather = await _weatherService.getCurrentWeather();
      weatherData.value = weather;

      // 2. Jalankan Algoritma Prediksi
      // Menggabungkan Data Lahan (Input User) + Data Cuaca (Dummy)
      List<PredictionResult> results = _predictionService.analyzeRisk(farm, weather);
      
      // 3. Update UI
      predictionResults.assignAll(results);
      
    } catch (e) {
      Get.snackbar("Error", "Gagal melakukan analisis: $e");
    } finally {
      isAnalyzing.value = false;
    }
  }
}