import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../controllers/prediction_controller.dart';
import '../data/models/farm_model.dart';
import '../widgets/phase_timeline.dart';
import '../widgets/ai_insight_card.dart';

class FarmDetailScreen extends StatelessWidget {
  final PredictionController controller = Get.put(PredictionController());

  FarmDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Builder(
        builder: (context) {
          if (controller.farm == null) {
            return const Center(child: Text("Data lahan tidak ditemukan"));
          }

          return CustomScrollView(
            slivers: [
              // ── Simple AppBar ──
              SliverAppBar(
                pinned: true,
                backgroundColor: colorScheme.primary,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
                title: Text(
                  "Farm Details",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (value) {
                        if (value == 'photo') _showImagePicker(context);
                        if (value == 'edit') _showEditDialog(context);
                        if (value == 'delete') _showDeleteDialog(context);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'photo',
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                color: colorScheme.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Ubah Foto',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.edit,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Edit Lahan',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 20,
                              ),
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
              ),

              // ── Body ──
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // ── Circle Avatar Header ──
                    _buildProfileHeader(context),

                    // ── Content with padding ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Stats Row ──
                          _buildStatsRow(context),
                          const SizedBox(height: 28),

                          // ── Growth Timeline ──
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: PhaseTimeline(
                              currentPhase: controller.farm!.currentPhase,
                              cropStage: controller.farm!.cropStage,
                              dayCount: _calculateDayCount(),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── AI Insights ──
                          AiInsightCard(controller: controller),
                          const SizedBox(height: 28),

                          // ── Map Section ──
                          _buildMapSection(context),

                          const SizedBox(height: 100), // Space for FAB
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // ── Extended FAB ──
      floatingActionButton: controller.farm == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.update_rounded),
              label: const Text("Update Phase"),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  CIRCLE AVATAR HEADER (mockup: centered avatar + name + badge)
  // ═══════════════════════════════════════════════════════════
  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasImage = controller.farm!.imageUrl != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Circle Avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: hasImage
                  ? Image.network(
                      controller.farm!.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.primaryContainer,
                          child: Icon(
                            Icons.eco_rounded,
                            size: 42,
                            color: colorScheme.primary,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.eco_rounded,
                        size: 42,
                        color: colorScheme.primary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Farm Name
          Text(
            controller.farm!.farmName,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          // Variety subtitle
          Text(
            controller.farm!.variety,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),

          // Phase Badge (green pill)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF81C784),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  controller.farm!.currentPhase,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  STATS ROW (mockup: Planted / Area / Health)
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final plantedDate = DateFormat(
      'MMM dd',
    ).format(DateTime.now().subtract(const Duration(days: 45)));

    return Row(
      children: [
        _buildStatCard(
          context,
          icon: Icons.calendar_today_rounded,
          label: "Planted",
          value: plantedDate,
          iconColor: colorScheme.primary,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          context,
          icon: Icons.crop_square_rounded,
          label: "Area",
          value: controller.farm!.landSize,
          iconColor: colorScheme.secondary,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          context,
          icon: Icons.favorite_rounded,
          label: "Health",
          value: "Good",
          iconColor: const Color(0xFF4CAF50),
          valueColor: const Color(0xFF4CAF50),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor ?? colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  MAP SECTION
  // ═══════════════════════════════════════════════════════════
  Widget _buildMapSection(BuildContext context) {
    if (controller.farm == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.map_rounded, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              "Lokasi Lahan",
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
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
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════
  int _calculateDayCount() {
    // Approximate day count based on crop stage
    switch (controller.farm!.cropStage) {
      case CropStage.seedling:
        return 15;
      case CropStage.vegetative:
        return 45;
      case CropStage.flowering:
        return 70;
      case CropStage.fruiting:
        return 95;
      case CropStage.harvesting:
        return 120;
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  PLACEHOLDER ACTIONS (unchanged logic)
  // ═══════════════════════════════════════════════════════════
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
