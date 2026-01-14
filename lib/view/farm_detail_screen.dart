import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/farm_model.dart';
import '../controllers/prediction_controller.dart';
import '../models/prediction_result.dart';
import '../models/weather_model.dart';
import '../services/firestore_service.dart';
import 'education_screen.dart';

class FarmDetailScreen extends StatelessWidget {
  const FarmDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FarmModel? farmArgs = Get.arguments as FarmModel?;
    if (farmArgs == null) {
      return const Scaffold(body: Center(child: Text("Data Error")));
    }

    final Rx<FarmModel> farm = farmArgs.obs;
    final PredictionController controller = Get.put(PredictionController());
    final FirestoreService firestoreService = FirestoreService();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.farm = farm.value;
      controller.runAnalysis();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: const Color(0xFF2C3312),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.black87,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        farm.value.latitude,
                        farm.value.longitude,
                      ),
                      initialZoom: 16.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.siaga_tani',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              farm.value.latitude,
                              farm.value.longitude,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoHeader(context, farm, firestoreService),
                  const SizedBox(height: 25),
                  Text(
                    "Kondisi Lingkungan",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3312),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.isAnalyzing.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4CAF50),
                        ),
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _buildWeatherCard(
                            controller.weatherData.value,
                            isForecast: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildWeatherCard(
                            controller.forecastData.value,
                            isForecast: true,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 25),
                  Text(
                    "Analisis Risiko Hama",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3312),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.isAnalyzing.value) return const SizedBox.shrink();

                    if (controller.predictionResults.isEmpty) {
                      return _buildSafeCard();
                    } else {
                      return Column(
                        children: controller.predictionResults
                            .map((result) => _buildExpandablePestCard(result))
                            .toList(),
                      );
                    }
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoHeader(
    BuildContext context,
    Rx<FarmModel> farm,
    FirestoreService service,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  farm.value.farmName,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3312),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () => _showEditNameDialog(context, farm, service),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(92, 107, 214, 111),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 18,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          Text(
            farm.value.address,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem("Tanaman", farm.value.variety, Icons.grass),
              _buildDetailItem("Fase", farm.value.currentPhase, Icons.timeline),
              _buildDetailItem("Luas", farm.value.landSize, Icons.aspect_ratio),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color.fromARGB(92, 149, 236, 152),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Color(0xFF4CAF50)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildWeatherCard(WeatherModel? weather, {required bool isForecast}) {
    if (weather == null) return const SizedBox();

    Color bgColors;
    Color textColors;
    IconData icon;
    String condition = weather.condition.toLowerCase();

    if (condition.contains("hujan")) {
      bgColors = const Color(0xFFCFD8DC);
      textColors = const Color.fromARGB(255, 55, 87, 103);
      icon = Icons.cloudy_snowing;
    } else if (condition.contains("awan") || condition.contains("berawan")) {
      bgColors = const Color(0xFFE0F7FA);
      textColors = const Color.fromARGB(255, 47, 167, 242);
      icon = Icons.cloud_queue;
    } else {
      bgColors = const Color(0xFFFFF8E1);
      textColors = const Color.fromARGB(255, 230, 222, 0);
      icon = Icons.wb_sunny_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColors,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColors.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: textColors, size: 24),
              Text(
                isForecast ? "Besok" : "Saat Ini",
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: textColors.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${weather.temperature.toStringAsFixed(0)}°C",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColors,
            ),
          ),
          Text(
            weather.condition,
            style: GoogleFonts.poppins(fontSize: 12, color: textColors),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandablePestCard(PredictionResult result) {
    Color baseColor;
    Color bgColor;

    switch (result.riskLevel) {
      case RiskLevel.severe:
        baseColor = Colors.red;
        bgColor = Colors.red.shade50;
        break;
      case RiskLevel.high:
        baseColor = Colors.orange;
        bgColor = Colors.orange.shade50;
        break;
      case RiskLevel.moderate:
        baseColor = Colors.amber.shade800;
        bgColor = Colors.amber.shade50;
        break;
      default:
        baseColor = Colors.green;
        bgColor = Colors.green.shade50;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: baseColor.withOpacity(0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: bgColor,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: Border.all(color: Colors.transparent),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 18,
          child: Icon(Icons.bug_report_rounded, color: baseColor, size: 20),
        ),
        title: Text(
          result.pestName,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3312),
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          result.shortDescription,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            result.formattedPercentage,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          result.shortDescription,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Analisis Penyebab:",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  result.detailedAnalysis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Rekomendasi Tindakan:",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: baseColor,
                  ),
                ),
                ...result.preventionSteps.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "• ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            step,
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.to(() => const EducationScreen());
                    },
                    icon: const Icon(Icons.menu_book_rounded, size: 18),
                    label: Text(
                      "Pelajari Solusi Lengkap",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2C3312),
                      side: const BorderSide(color: Color(0xFF2C3312)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_rounded,
            color: Colors.green,
            size: 30,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "Tidak ada risiko hama yang signifikan saat ini. Lahan aman!",
              style: GoogleFonts.poppins(
                color: Colors.green[900],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(
    BuildContext context,
    Rx<FarmModel> farmRx,
    FirestoreService service,
  ) {
    final TextEditingController nameCtrl = TextEditingController(
      text: farmRx.value.farmName,
    );
    Get.defaultDialog(
      title: "Ubah Nama",
      content: Padding(
        padding: const EdgeInsets.all(10),
        child: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Nama Baru",
          ),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          if (nameCtrl.text.isNotEmpty && farmRx.value.id != null) {
            await service.updateFarmName(farmRx.value.id!, nameCtrl.text);
            farmRx.value = FarmModel(
              id: farmRx.value.id,
              farmName: nameCtrl.text,
              address: farmRx.value.address,
              latitude: farmRx.value.latitude,
              longitude: farmRx.value.longitude,
              landSize: farmRx.value.landSize,
              variety: farmRx.value.variety,
              cropStage: farmRx.value.cropStage,
              mulchType: farmRx.value.mulchType,
              lastPesticideTime: farmRx.value.lastPesticideTime,
              hostPlantsNearby: farmRx.value.hostPlantsNearby,
              isMulchUsed: farmRx.value.isMulchUsed,
              plantingPattern: farmRx.value.plantingPattern,
              pestHistory: farmRx.value.pestHistory,
              currentPhase: farmRx.value.currentPhase,
              recentlySprayedPesticide: farmRx.value.recentlySprayedPesticide,
              wateringIntensity: farmRx.value.wateringIntensity,
            );
            Get.back();
            Get.snackbar(
              "Sukses",
              "Nama berhasil diubah!",
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C3312),
        ),
        child: const Text("Simpan", style: TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Batal"),
      ),
    );
  }
}