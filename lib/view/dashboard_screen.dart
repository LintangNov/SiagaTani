import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:siaga_tani/controllers/dashboard_controller.dart';
import 'package:siaga_tani/view/my_farm_screen.dart';
import 'package:siaga_tani/view/question.dart';
import 'package:siaga_tani/widgets/weather_card.dart';
import 'package:siaga_tani/widgets/farm_overview_card.dart';
import '../data/models/farm_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchCurrentLocation(forceRefresh: true);
            controller.fetchUserData();
          },
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: Greeting + Date + Notification ──
                _buildHeader(context, controller),
                const SizedBox(height: 6),
                // ── Location ──
                _buildLocationRow(context, controller),
                const SizedBox(height: 24),
                // ── Weather Card ──
                WeatherCard(controller: controller),
                const SizedBox(height: 28),
                // ── Farm Overview ──
                _buildFarmOverviewSection(context, controller),
                const SizedBox(height: 28),
                // ── Daily Tips ──
                _buildTipsSection(context, controller),
                const SizedBox(height: 28),
                // ── Quick Actions ──
                _buildMenuSection(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  HEADER
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, DashboardController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM y', 'id_ID').format(now);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
              const SizedBox(height: 2),
              Obx(
                () => Text(
                  "Hai, ${controller.userName.value} 👋",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  LOCATION ROW
  // ═══════════════════════════════════════════════════════════
  Widget _buildLocationRow(
    BuildContext context,
    DashboardController controller,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => controller.handleLocationTap(),
      child: Row(
        children: [
          Obx(
            () => Icon(
              Icons.location_on,
              color: controller.currentLocation.value.contains("Ketuk")
                  ? Colors.red
                  : const Color(0xFFE57373),
              size: 16,
            ),
          ),
          const SizedBox(width: 4),
          Obx(
            () => Flexible(
              child: Text(
                controller.currentLocation.value,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: controller.currentLocation.value.contains("Ketuk")
                      ? Colors.red
                      : theme.colorScheme.onSurface.withOpacity(0.55),
                  decoration: controller.currentLocation.value.contains("Ketuk")
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  FARM OVERVIEW SECTION
  // ═══════════════════════════════════════════════════════════
  Widget _buildFarmOverviewSection(
    BuildContext context,
    DashboardController controller,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Lahan Aktif",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => const MyFarmScreen()),
              child: Text(
                "Lihat Semua",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: StreamBuilder<List<FarmModel>>(
            stream: controller.farmListStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                    strokeWidth: 2,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.eco_outlined,
                        size: 36,
                        color: colorScheme.primary.withOpacity(0.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Belum ada lahan",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final farms = snapshot.data!;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: farms.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return FarmOverviewCard(farm: farms[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  TIPS SECTION
  // ═══════════════════════════════════════════════════════════
  Widget _buildTipsSection(
    BuildContext context,
    DashboardController controller,
  ) {
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.dailyTips.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rekomendasi Hari Ini",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.92),
              itemCount: controller.dailyTips.length,
              itemBuilder: (context, index) {
                final tip = controller.dailyTips[index];
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: tip['color'],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          tip['icon'],
                          size: 26,
                          color: tip['textColor'],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tip['title'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: tip['textColor'],
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              tip['body'],
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  //  QUICK ACTIONS / MENU
  // ═══════════════════════════════════════════════════════════
  Widget _buildMenuSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Kelola Lahanmu",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.15,
          children: [
            _buildMenuCard(
              context,
              "Tambah Lahan",
              Icons.add_location_alt_rounded,
              colorScheme.primary,
              onTap: () => Get.to(() => const QuestionnaireScreen()),
            ),
            _buildMenuCard(
              context,
              "Tanaman",
              Icons.grass_rounded,
              colorScheme.secondary,
              onTap: () => Get.to(() => const MyFarmScreen()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
