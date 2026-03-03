import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../controllers/prediction_controller.dart';
import '../models/prediction_result.dart';
import '../models/weather_model.dart';
// import '../utils/farm_constants.dart';
import '../utils/app_theme.dart';

class FarmDetailScreen extends StatelessWidget {
  final PredictionController controller = Get.put(PredictionController());

  FarmDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Obx(() {
        if (controller.farm == null) {
          return const Center(child: Text("Data lahan tidak ditemukan"));
        }

        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeatherCard(),
                    const SizedBox(height: 24),
                    _buildFarmInfoGrid(),
                    // Tampilkan peta di body HANYA jika header menampilkan gambar
                    if (controller.farm!.imageUrl != null) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle("Lokasi Lahan"),
                      const SizedBox(height: 12),
                      _buildMapSection(),
                    ],
                    const SizedBox(height: 24),
                    _buildSectionTitle("Analisis Risiko Hama"),
                    const SizedBox(height: 12),
                    _buildPredictionResults(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    bool hasImage = controller.farm!.imageUrl != null;

    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColors.secondary,
      title: Text(
        controller.farm!.farmName,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: false, // Title aligns to start when collapsed
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            onSelected: (value) {
              if (value == 'photo') _showImagePicker(context);
              if (value == 'edit') _showEditDialog(context);
              if (value == 'delete') _showDeleteDialog(context);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'photo',
                child: Row(
                  children: [
                    const Icon(Icons.add_a_photo, color: Colors.blue, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Ubah Foto Header',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.orange, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Ubah Data Lahan',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Hapus Lahan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: hasImage ? _buildHeaderImage() : _buildHeaderMap(),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          controller.farm!.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: AppColors.secondary);
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderMap() {
    // Fallback: Use FlutterMap if no image
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(
          controller.farm!.latitude,
          controller.farm!.longitude,
        ),
        initialZoom: 15.0,
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
                controller.farm!.latitude,
                controller.farm!.longitude,
              ),
              child: const Icon(Icons.location_on, color: Colors.red, size: 35),
            ),
          ],
        ),
        // Overlay tipis agar teks tetap terbaca jika collapsed transisi
        Container(color: Colors.black.withOpacity(0.1)),
      ],
    );
  }

  Widget _buildWeatherCard() {
    // Current date formatting
    final now = DateTime.now();
    final dateStr = DateFormat('d MMMM y', 'id_ID').format(
      now,
    ); // Requires initializeDateFormatting usually, but default en works if locale unavailable

    // Safety check for weather data
    final temp = controller.weatherData.value?.temperature.round() ?? 0;
    final rawCondition = controller.weatherData.value?.condition ?? "Cerah";
    final condition = _formatCondition(rawCondition);

    // Choose icon based on condition (Basic logic)
    IconData weatherIcon = Icons.wb_sunny_rounded;
    if (condition.contains("Hujan")) {
      weatherIcon = Icons.thunderstorm;
    } else if (condition.contains("Berawan")) {
      weatherIcon = Icons.cloud;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Informasi Cuaca",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 20),
          // Main Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$temp",
                        style: GoogleFonts.poppins(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        "°C",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      condition,
                      style: GoogleFonts.poppins(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              // Big Icon
              Icon(weatherIcon, size: 90, color: AppColors.tertiary),
            ],
          ),
          const SizedBox(height: 30),
          Divider(height: 1, color: AppColors.primaryLight),
          const SizedBox(height: 20),
          Text(
            "Cuaca Hari Ini",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 15),
          // Hourly Forecast List (Mocked)
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                // Mocking time starting from now
                final time = now.add(Duration(hours: index + 1));
                final timeStr = DateFormat('HH:00').format(time);
                // Varies temp slightly
                final mockTemp = temp + (index % 2 == 0 ? 1 : -1);

                return Column(
                  children: [
                    Text(
                      timeStr,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      index == 2
                          ? Icons.cloud
                          : Icons.wb_sunny_rounded, // Random mix
                      color: index == 2 ? Colors.grey : Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$mockTemp°",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatCondition(String raw) {
    String lower = raw.toLowerCase();
    if (lower.contains("hujan") || lower.contains("rain"))
      return "Hujan Ringan";
    if (lower.contains("awan") ||
        lower.contains("cloud") ||
        lower.contains("mendung"))
      return "Berawan";
    if (lower.contains("cerah") ||
        lower.contains("clear") ||
        lower.contains("sunny"))
      return "Cerah";
    return raw.capitalizeFirst ?? raw;
  }

  Widget _buildFarmInfoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Informasi Tanaman"),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildGridItem(Icons.eco, "Varietas", controller.farm!.variety),
            _buildGridItem(
              Icons.layers,
              "Mulsa",
              controller.farm!.mulchType.name.capitalizeFirst ?? "-",
            ),
            _buildGridItem(
              Icons.calendar_today,
              "Fase",
              controller.farm!.currentPhase,
            ),
            _buildGridItem(
              Icons.pest_control,
              "Pestisida",
              controller.farm!.lastPesticideTime,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    // Standard FlutterMap implementation in a card
    if (controller.farm == null) return const SizedBox.shrink();

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(
              controller.farm!.latitude,
              controller.farm!.longitude,
            ),
            initialZoom: 15.0,
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
                    controller.farm!.latitude,
                    controller.farm!.longitude,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 35,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
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
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryLight),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: AppColors.tertiary,
              ),
              const SizedBox(height: 12),
              Text(
                "Lahan Aman",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Tidak ada risiko hama signifikan.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // AI Advice Section
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
                      "AI sedang menyusun saran...",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                      ),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Saran Cerdas (AI)",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.aiAdvice.value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
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
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
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
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              result.shortDescription,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 10),
                  _buildCardDetailSection(
                    "Kenapa Waspada?",
                    result.detailedAnalysis,
                  ),
                  const SizedBox(height: 12),
                  _buildCardDetailSection("Langkah Pencegahan", ""),
                  ...result.preventionSteps.map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "• ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              step,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
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
      ),
    );
  }

  Widget _buildCardDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3312),
          ),
        ),
        if (content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              content,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
            ),
          ),
      ],
    );
  }

  Color _getSeverityColor(double percentage) {
    if (percentage > 0.7) return Colors.red;
    if (percentage > 0.4) return Colors.orange;
    return Colors.blue;
  }

  // PLACEHOLER ACTIONS
  void _showImagePicker(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fitur Upload Foto akan segera hadir!")),
    );
  }

  void _showEditDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dialog Edit Data Lahan (Placeholder)")),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dialog Hapus Lahan (Placeholder)")),
    );
  }
}
