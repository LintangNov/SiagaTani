import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/prediction_controller.dart';
import '../models/prediction_result.dart';
import '../utils/farm_constants.dart';

class FarmDetailScreen extends StatelessWidget {
  final PredictionController controller = Get.put(PredictionController());

  FarmDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          controller.farm?.farmName ?? "Detail Lahan", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: controller.farm == null 
        ? const Center(child: Text("Data lahan tidak ditemukan")) 
        : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFarmInfoCard(),
              const SizedBox(height: 24),
              _buildSectionTitle("Analisis Risiko Hama"),
              const SizedBox(height: 16),
              _buildPredictionResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFarmInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.eco, "Varietas", controller.farm?.variety ?? "-"),
          const Divider(),
          _buildInfoRow(Icons.layers, "Mulsa", controller.farm?.mulchType.name.capitalizeFirst ?? "-"),
          const Divider(),
          _buildInfoRow(Icons.calendar_today, "Fase", controller.farm?.currentPhase ?? "-"),
          const Divider(),
          _buildInfoRow(Icons.pest_control, "Semprot Terakhir", controller.farm?.lastPesticideTime ?? "-"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
          const Spacer(),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _buildPredictionResults() {
    return Obx(() {
      if (controller.isAnalyzing.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.predictionResults.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              "Tidak ada risiko hama yang signifikan terdeteksi berdasarkan cuaca saat ini.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.black54),
            ),
          ),
        );
      }

      return Column(
        children: [
          Obx(() {
            if (controller.isLoadingAI.value) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Asisten AI sedang menyusun saran...",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue.shade800),
                    ),
                  ],
                ),
              );
            }

            if (controller.aiAdvice.isEmpty) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Saran Pencegahan AI",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.aiAdvice.value,
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            );
          }),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.predictionResults.length,
            itemBuilder: (context, index) {
              final result = controller.predictionResults[index];
              return _buildExpandablePestCard(result);
            },
          ),
        ],
      );
    });
  }

  Widget _buildExpandablePestCard(PredictionResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getSeverityColor(result.percentage).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            "${(result.percentage * 100).toInt()}%",
            style: TextStyle(
              color: _getSeverityColor(result.percentage),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          result.pestName,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            result.shortDescription,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardDetailSection("Kenapa Waspada?", result.detailedAnalysis),
                const SizedBox(height: 12),
                _buildCardDetailSection("Langkah Pencegahan", ""),
                ...result.preventionSteps.map((step) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              step,
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green.shade800),
        ),
        if (content.isNotEmpty)
          Text(
            content,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          ),
      ],
    );
  }

  Color _getSeverityColor(double percentage) {
    if (percentage > 0.7) return Colors.red;
    if (percentage > 0.4) return Colors.orange;
    return Colors.blue;
  }
}