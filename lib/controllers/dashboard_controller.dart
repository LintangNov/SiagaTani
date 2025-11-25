import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/farm_model.dart';
import '../services/dummy_weather_service.dart';
import '../services/firestore_service.dart';
import 'dart:math';

class DashboardController extends GetxController {
  final DummyWeatherService _weatherService = DummyWeatherService();
  final FirestoreService _firestoreService = FirestoreService();

  var currentWeather = Rxn<WeatherModel>();
  var isLoadingWeather = true.obs;
  var greeting = "".obs;
  var dailyTips = <Map<String, dynamic>>[].obs;
  
  Stream<List<FarmModel>> get farmListStream => _firestoreService.getFarms();

  @override
  void onInit() {
    super.onInit();
    updateGreeting();
    fetchWeather();
    ever(currentWeather, (_) => generateSmartTips());
  }

  void updateGreeting() {
    var hour = DateTime.now().hour;
    greeting.value = (hour < 11) ? "Selamat Pagi, Pejuang Pangan!" : (hour < 15) ? "Selamat Siang, Semangat!" : (hour < 18) ? "Selamat Sore, Pak Tani!" : "Selamat Malam, Istirahatlah.";
  }

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
    var tips = <Map<String, dynamic>>[];

    if (w.temperature > 30) {
      tips.add({"title": "Cuaca Panas Terik", "body": "Suhu mencapai ${w.temperature}°C. Siram tanaman sore ini.", "icon": Icons.wb_sunny, "color": Colors.orange.shade100, "textColor": Colors.orange.shade900});
    }
    if (w.condition.toLowerCase().contains("hujan")) {
      tips.add({"title": "Potensi Hujan", "body": "Tunda pemupukan agar tidak hanyut.", "icon": Icons.water_drop, "color": Colors.blue.shade100, "textColor": Colors.blue.shade900});
    }
    if (w.humidity > 80) {
      tips.add({"title": "Kelembapan Tinggi", "body": "Waspada jamur pada daun.", "icon": Icons.cloud, "color": Colors.grey.shade200, "textColor": Colors.grey.shade800});
    }
    
    var generalTips = [
      {"title": "Info Pasar", "body": "Harga cabai rawit stabil Rp 45.000/kg.", "icon": Icons.monetization_on, "color": Colors.green.shade100, "textColor": Colors.green.shade900},
      {"title": "Tips Budidaya", "body": "Rotasi dengan jagung memutus siklus kutu.", "icon": Icons.lightbulb, "color": Colors.yellow.shade100, "textColor": Colors.yellow.shade900}
    ];
    tips.add(generalTips[Random().nextInt(generalTips.length)]);
    dailyTips.assignAll(tips);
  }
}