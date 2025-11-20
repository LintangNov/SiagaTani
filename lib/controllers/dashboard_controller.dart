import 'package:get/get.dart';
import '../models/weather_model.dart';
import '../models/farm_model.dart';
import '../services/dummy_weather_service.dart';
import '../services/firestore_service.dart';

class DashboardController extends GetxController {
  final DummyWeatherService _weatherService = DummyWeatherService();
  final FirestoreService _firestoreService = FirestoreService();

  // Observable variables
  var currentWeather = Rxn<WeatherModel>(); // Bisa null di awal
  var isLoadingWeather = true.obs;
  var greeting = "".obs;
  
  // Stream list lahan (otomatis update jika ada perubahan di Firestore)
  Stream<List<FarmModel>> get farmListStream => _firestoreService.getFarms();

  @override
  void onInit() {
    super.onInit();
    updateGreeting();
    fetchWeather();
  }

  // 1. Logika Sapaan (Pagi/Siang/Sore)
  void updateGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 11) {
      greeting.value = "Selamat Pagi, Pejuang Pangan!";
    } else if (hour < 15) {
      greeting.value = "Selamat Siang, Semangat!";
    } else if (hour < 18) {
      greeting.value = "Selamat Sore, Pak Tani!";
    } else {
      greeting.value = "Selamat Malam, Istirahatlah.";
    }
  }

  // 2. Ambil Data Cuaca Dummy
  void fetchWeather() async {
    isLoadingWeather.value = true;
    try {
      var weather = await _weatherService.getCurrentWeather();
      currentWeather.value = weather;
    } finally {
      isLoadingWeather.value = false;
    }
  }
}