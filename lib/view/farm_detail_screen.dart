import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/farm_model.dart';
import '../controllers/prediction_controller.dart';
import '../models/prediction_result.dart';

class FarmDetailScreen extends StatelessWidget {
  const FarmDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil data dari arguments
    final FarmModel? farmArgs = Get.arguments as FarmModel?;
    if (farmArgs == null) {
      return const Scaffold(
        body: Center(child: Text("Data Lahan Tidak Ditemukan")),
      );
    }
    final FarmModel farm = farmArgs;

    final PredictionController predictionController = Get.put(
      PredictionController(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      predictionController.farm = farm;
      predictionController.runAnalysis();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // ... (properti appbar sama) ...
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // PETA STATIS (Background)
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(farm.latitude, farm.longitude),
                      initialZoom: 16.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        // TAMBAHKAN BARIS INI JUGA
                        userAgentPackageName: 'com.example.siaga_tani',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(farm.latitude, farm.longitude),
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
                  // Gradient Shadow agar status bar terlihat
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
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

          // 2. KONTEN UTAMA
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER INFO LAHAN (Simpel) ---
                  _buildInfoCard(farm),

                  const SizedBox(height: 25),

                  // --- JUDUL BAGIAN ANALISIS ---
                  Row(
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        color: Color(0xFF2C3312),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Analisis Risiko Hama",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3312),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // --- CONTENT ANALISIS ---
                  Obx(() {
                    if (predictionController.isAnalyzing.value) {
                      return Container(
                        height: 150,
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF4CAF50)),
                            SizedBox(height: 10),
                            Text("Sedang menganalisis lahan..."),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Kartu Cuaca Mini
                        _buildWeatherMiniCard(
                          predictionController.weatherData.value,
                        ),
                        const SizedBox(height: 15),

                        // Kartu Hama (Jika kosong = Aman)
                        if (predictionController.predictionResults.isEmpty)
                          _buildSafeCard()
                        else
                          ...predictionController.predictionResults.map(
                            (result) => _buildExpandablePestCard(result),
                          ),
                      ],
                    );
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

  // --- WIDGET: INFO LAHAN (Pengganti Crop Health yang rumit) ---
  Widget _buildInfoCard(FarmModel farm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Lahan
          Text(
            farm.farmName,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3312),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  farm.address,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const Divider(height: 30, thickness: 1),

          // Detail Grid Sederhana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Tanaman", farm.variety, Icons.grass),
              _buildInfoColumn("Fase", farm.currentPhase, Icons.timeline),
              _buildInfoColumn("Luas", farm.landSize, Icons.aspect_ratio),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: const Color(0xFF558B2F)),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  // --- WIDGET: EXPANDABLE CARD (HAMA) ---
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
        side: BorderSide(color: baseColor.withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(Icons.bug_report_rounded, color: baseColor),
        ),
        title: Text(
          result.pestName,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3312),
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
              fontSize: 12,
            ),
          ),
        ),

        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Text(
                  "Analisis:",
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
                const SizedBox(height: 10),
                Text(
                  "Saran Pencegahan:",
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: CUACA MINI ---
  Widget _buildWeatherMiniCard(weather) {
    if (weather == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_queue, color: Colors.blue, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cuaca Saat Ini",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.blueGrey,
                  ),
                ),
                Text(
                  "${weather.temperature}°C - ${weather.condition}",
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: AMAN ---
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
              "Tidak ada risiko hama yang terdeteksi saat ini.",
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
}
