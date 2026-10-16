import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../data/models/farm_model.dart';
import '../data/models/weather_model.dart';
import '../data/models/prediction_result.dart';
import '../data/services/weather_service.dart';
import '../data/services/prediction_service.dart';
import '../data/services/firestore_service.dart';
import '../data/services/ai_service.dart';

class PredictionController extends GetxController {
  final WeatherService _weatherService = WeatherService();
  final PredictionService _predictionService = PredictionService();
  final FirestoreService _firestoreService = FirestoreService();
  final AIService _aiService = AIService();

  final farmRx = Rxn<FarmModel>();
  FarmModel? get farm => farmRx.value;

  final predictionResults = <PredictionResult>[].obs;
  final isAnalyzing = false.obs;
  final analysisFailed = false.obs;
  final analyzedAt = Rxn<DateTime>();

  final weatherData = Rxn<WeatherModel>();
  final forecastData = Rxn<WeatherModel>();

  final aiSteps = <String>[].obs;
  final isLoadingAI = false.obs;
  final aiFailed = false.obs;

  /// Penyemprotan terakhir kurang dari 3 hari (risiko diturunkan oleh aturan).
  bool get recentlySprayed => farm?.lastPesticideTime.contains('< 3 hari') ?? false;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments is FarmModel) {
      farmRx.value = Get.arguments;
      runAnalysis();
    } else {
      Get.snackbar('Error', 'Data lahan tidak ditemukan atau tidak valid');
    }
  }

  Future<void> runAnalysis() async {
    final currentFarm = farm;
    if (currentFarm == null) return;

    isAnalyzing.value = true;
    analysisFailed.value = false;
    predictionResults.clear();
    aiSteps.clear();
    aiFailed.value = false;

    try {
      final results = await Future.wait([
        _weatherService.getWeatherByLocation(
          currentFarm.latitude,
          currentFarm.longitude,
        ),
        _weatherService.getForecastByLocation(
          currentFarm.latitude,
          currentFarm.longitude,
        ),
      ]);

      weatherData.value = results[0];
      forecastData.value = results[1];

      final allPins = await _firestoreService.getAllPins();
      const distance = Distance();
      final nearbyPlants = <String>[];

      for (final pin in allPins) {
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
      analyzedAt.value = DateTime.now();

      if (predictionResults.isNotEmpty) {
        fetchAISuggestion();
      }
    } catch (e) {
      debugPrint('Error Analysis: $e');
      analysisFailed.value = true;
    } finally {
      isAnalyzing.value = false;
    }
  }

  Future<void> fetchAISuggestion() async {
    if (predictionResults.isEmpty ||
        weatherData.value == null ||
        farm == null) {
      return;
    }

    isLoadingAI.value = true;
    aiFailed.value = false;

    try {
      final steps = await _aiService.generateSmartSteps(
        weather: weatherData.value!,
        farm: farm!,
        risks: predictionResults,
      );
      aiSteps.assignAll(steps);
    } catch (e) {
      debugPrint('AI Error: $e');
      aiFailed.value = true;
    } finally {
      isLoadingAI.value = false;
    }
  }

  // ── Aksi lahan ──────────────────────────────────────────────

  Future<bool> changePhase(String label, CropStage stage) async {
    final current = farm;
    if (current?.id == null) return false;
    try {
      await _firestoreService.updateFarmPhase(
        current!.id!,
        label,
        stage.toString(),
      );
      farmRx.value = current.copyWith(currentPhase: label, cropStage: stage);
      runAnalysis();
      return true;
    } catch (e) {
      debugPrint('changePhase error: $e');
      return false;
    }
  }

  Future<bool> renameFarm(String name) async {
    final current = farm;
    if (current?.id == null) return false;
    try {
      await _firestoreService.updateFarmName(current!.id!, name);
      farmRx.value = current.copyWith(farmName: name);
      return true;
    } catch (e) {
      debugPrint('renameFarm error: $e');
      return false;
    }
  }

  Future<bool> recordSpray(String lastPesticideTime) async {
    final current = farm;
    if (current?.id == null) return false;
    final sprayedRecently = lastPesticideTime.contains('Baru');
    try {
      await _firestoreService.updateFarmSpray(
        current!.id!,
        lastPesticideTime,
        sprayedRecently,
      );
      farmRx.value = current.copyWith(
        lastPesticideTime: lastPesticideTime,
        recentlySprayedPesticide: sprayedRecently,
      );
      runAnalysis();
      return true;
    } catch (e) {
      debugPrint('recordSpray error: $e');
      return false;
    }
  }
}
