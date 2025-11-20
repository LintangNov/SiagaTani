import 'package:get/get.dart';
import '../models/weather_model.dart';
import '../models/farm_model.dart';
import '../services/dummy_weather_service.dart';
import '../services/firestore_service.dart';
import 'dart:math';

class DashboardController extends GetxController {
  final DummyWeatherService _weatherService = DummyWeatherService();
  final FirestoreService _firestoreService = FirestoreService();

  // Observable variables
  var currentWeather = Rxn<WeatherModel>(); // Bisa null di awal
  var isLoadingWeather = true.obs;
  var greeting = "".obs;
  
  // Stream list lahan (otomatis update jika ada perubahan di Firestore)
  Stream<List<FarmModel>> get farmListStream => _firestoreService.getFarms();
  var dailyTips = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    updateGreeting();
    fetchWeather();
    ever(currentWeather, (_) => generateSmartTips());
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

  void generateSmartTips() {
    if (currentWeather.value == null) return;

    var w = currentWeather.value!;
    var tips = <Map<String, String>>[];

    // 1. Logika Berdasarkan Cuaca
    if (w.temperature > 30) {
      tips.add({
        "title": "Cuaca Panas Terik",
        "body": "Hindari penyemprotan pestisida siang hari agar tidak menguap. Siram lahan saat sore.",
        "type": "warning" // untuk warna icon
      });
    } else if (w.condition.toLowerCase().contains("hujan")) {
      tips.add({
        "title": "Potensi Hujan Turun",
        "body": "Tunda pemupukan tabur agar tidak hanyut terbawa air. Cek saluran irigasi.",
        "type": "info"
      });
    }

    // 2. Logika Berdasarkan Musim
    if (w.season == "Musim Kemarau") {
      tips.add({
        "title": "Waspada Kutu Daun",
        "body": "Cuaca kering memicu ledakan populasi Kutu. Pasang perangkap kuning sekarang.",
        "type": "alert"
      });
    }

    // 3. Logika Umum (Randomizer biar tidak kosong)
    var generalTips = [
      {"title": "Info Pasar", "body": "Harga cabai rawit stabil di Rp 45.000/kg hari ini.", "type": "success"},
      {"title": "Tips Hemat", "body": "Gunakan air cucian beras untuk pupuk cair tambahan.", "type": "info"},
    ];
    tips.add(generalTips[Random().nextInt(generalTips.length)]);

    dailyTips.assignAll(tips);
  }
}