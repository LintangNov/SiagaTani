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
    final FarmModel farm = Get.arguments as FarmModel;
    final PredictionController predictionController = Get.put(PredictionController());
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      predictionController.runAnalysis(); 
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // 1. APP BAR GAMBAR/PETA (Sesuai referensi)
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF2C3312),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Tampilkan Peta Statis sebagai background
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(farm.latitude, farm.longitude),
                      initialZoom: 16.0,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), // Map diam
                    ),
                    children: [
                      TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                      MarkerLayer(markers: [
                        Marker(
                          point: LatLng(farm.latitude, farm.longitude),
                          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                        )
                      ])
                    ],
                  ),
                  // Gradient gelap biar teks kelihatan
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(farm.farmName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
              centerTitle: false,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ),
          ),

          // 2. KONTEN DASHBOARD
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildStatusCard(farm) -> Pastikan kode ini ada dari file lama
                  _buildStatusCard(farm), 
                  const SizedBox(height: 20),
                  
                  Text("Analisis Risiko Hama", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  Obx(() {
                    if (predictionController.isAnalyzing.value) {
                      return const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    return Column(
                      children: [
                        // Weather Mini Card (Tetap sama)
                        _buildWeatherMiniCard(predictionController.weatherData.value),
                        const SizedBox(height: 15),
                        
                        if (predictionController.predictionResults.isEmpty)
                          _buildSafeCard()
                        else
                          // GENERATE EXPANDABLE CARDS
                          ...predictionController.predictionResults.map((result) => _buildExpandablePestCard(result))
                      ],
                    );
                  }),
                  
                  const SizedBox(height: 20),
                  
                  // --- GROWTH MONITORING (DUMMY CHART) ---
                  Text("Growth Monitoring", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    height: 150,
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Center(child: Text("Chart Grafik Pertumbuhan\n(Placeholder)", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.grey))),
                  ),
                  
                  // const SizedBox(height: 30),
                  // // Tombol Ask AI
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 55,
                  //   child: ElevatedButton.icon(
                  //     onPressed: (){}, 
                  //     icon: const Icon(Icons.smart_toy, color: Colors.white),
                  //     label: Text("Tanya Siaga AI", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                  //     style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                  //   ),
                  // )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildExpandablePestCard(PredictionResult result) {
    Color baseColor;
    Color deepColor;
    Color bgColor;

    switch (result.riskLevel) {
      case RiskLevel.severe: // BAHAYA
        baseColor = Colors.red;
        deepColor = Colors.red.shade900;
        bgColor = Colors.red.shade50;
        break;
      case RiskLevel.high: // TINGGI
        baseColor = Colors.orange;
        deepColor = Colors.deepOrange.shade900;
        bgColor = Colors.orange.shade50;
        break;
      case RiskLevel.moderate: // SEDANG
        baseColor = Colors.amber;
        deepColor = Colors.brown;
        bgColor = Colors.amber.shade50;
        break;
      default: // RENDAH
        baseColor = Colors.green;
        deepColor = Colors.green.shade900;
        bgColor = Colors.green.shade50;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: Colors.white,
          collapsedBackgroundColor: bgColor,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          
          // --- HEADER SAAT TERTUTUP ---
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.bug_report, color: baseColor),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(result.pestName, 
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF2C3312))
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text(result.formattedPercentage, 
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)
                ),
              )
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(result.shortDescription, // Alasan singkat
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // --- CONTENT SAAT DIBUKA ---
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian Analisis
                  Text("Mengapa Berisiko?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: baseColor)),
                  const SizedBox(height: 5),
                  Text(result.detailedAnalysis, 
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, height: 1.5)
                  ),
                  
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Bagian Pencegahan
                  Text("Langkah Pencegahan & Pengendalian:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green[800])),
                  const SizedBox(height: 8),
                  ...result.preventionSteps.map((step) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(step, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87))),
                      ],
                    ),
                  )).toList()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  // WIDGET: Status Grid
  Widget _buildStatusCard(FarmModel farm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Crop Health", style: GoogleFonts.poppins(color: Colors.grey)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
              child: Text("Good", style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.bold)),
            )
          ]),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem("Varietas", farm.variety),
              _buildDetailItem("Fase", farm.currentPhase),
              _buildDetailItem("Panen", "~2 Bulan"), // Estimasi Dummy
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String val) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      Text(val, style: GoogleFonts.poppins(fontWeight: FontWeight.w600))
    ]);
  }

  // WIDGET: Weather Mini
  Widget _buildWeatherMiniCard(weather) {
    if (weather == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)]),
        borderRadius: BorderRadius.circular(16)
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud, color: Colors.white, size: 40),
          const SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("${weather.temperature}°C - ${weather.condition}", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
            Text("Kelembapan: ${weather.humidity}%", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
          ])
        ],
      ),
    );
  }

  // WIDGET: Pest Analysis Card (Merah jika Tinggi)
  Widget _buildPestCard(PredictionResult result) {
    // Logika Warna Baru menggunakan Enum
    Color cardColor;
    Color textColor;

    switch (result.riskLevel) {
      case RiskLevel.severe: // BAHAYA
        cardColor = Colors.red.shade50;
        textColor = Colors.red.shade900;
        break;
      case RiskLevel.high: // TINGGI
        cardColor = Colors.orange.shade50;
        textColor = Colors.deepOrange.shade800;
        break;
      case RiskLevel.moderate: // SEDANG
        cardColor = Colors.yellow.shade50;
        textColor = Colors.orange.shade900;
        break;
      default: // RENDAH
        cardColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.warning_amber_rounded, color: textColor),
            const SizedBox(width: 10),
            Expanded(child: Text(result.pestName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: textColor))),
            Text(result.formattedPercentage, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: textColor)),
          ]),
          const SizedBox(height: 8),
          Text(result.shortDescription, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
          const SizedBox(height: 8),
          // Tampilkan 1 saran pencegahan utama
          if (result.preventionSteps.isNotEmpty)
             Text("Saran: ${result.preventionSteps.first}", style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic, color: textColor)),
        ],
      ),
    );
  }
  
  Widget _buildSafeCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Icon(Icons.check_circle, color: Colors.green),
        const SizedBox(width: 10),
        Text("Risiko Hama Rendah", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green)),
      ]),
    );
  }
}