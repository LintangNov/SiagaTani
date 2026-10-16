import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/dashboard_controller.dart';
import '../core/theme/app_theme.dart';
import '../data/models/farm_model.dart';
import '../data/models/farm_risk_status.dart';
import '../data/services/firestore_service.dart';
import 'farm_detail_screen.dart';
import 'question.dart';

class MyFarmScreen extends StatefulWidget {
  const MyFarmScreen({super.key});

  @override
  State<MyFarmScreen> createState() => _MyFarmScreenState();
}

class _MyFarmScreenState extends State<MyFarmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimController;
  late Animation<double> _expandAnimation;
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      value: _isFabOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _fabAnimController,
    );
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabAnimController.forward();
      } else {
        _fabAnimController.reverse();
      }
    });
  }

  void _closeFab() {
    if (_isFabOpen) {
      setState(() {
        _isFabOpen = false;
        _fabAnimController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController controller =
        Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.surfacePrimary,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header "Lahan Saya" (Margin horizontal 24 sama rata dengan dashboard) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.screen,
                    AppSpace.lg,
                    AppSpace.screen,
                    AppSpace.sm,
                  ),
                  child: Text(
                    'Lahan Saya',
                    style: AppText.heading(
                      size: 24,
                      weight: FontWeight.w700,
                      color: AppColors.foregroundPrimary,
                    ),
                  ),
                ),

                // ── Daftar Kartu Lahan (Padding horizontal 24) ────────
                Expanded(
                  child: StreamBuilder<List<FarmModel>>(
                    stream: firestoreService.getFarms(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accentPrimary,
                            strokeWidth: 2.5,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Gagal memuat data lahan.',
                            style: AppText.body(
                              size: 14,
                              color: AppColors.foregroundSecondary,
                            ),
                          ),
                        );
                      }

                      final farms = snapshot.data ?? [];

                      if (farms.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.screen,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: const BoxDecoration(
                                    color: AppColors.surfaceSecondary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.spa_outlined,
                                    size: 42,
                                    color: AppColors.accentPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada lahan',
                                  style: AppText.heading(
                                    size: 16,
                                    weight: FontWeight.w700,
                                    color: AppColors.foregroundPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tekan tombol + di pojok kanan bawah untuk menambah lahan.',
                                  textAlign: TextAlign.center,
                                  style: AppText.body(
                                    size: 13,
                                    color: AppColors.foregroundSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpace.screen,
                          AppSpace.xs,
                          AppSpace.screen,
                          80,
                        ),
                        itemCount: farms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final farm = farms[index];
                          return Obx(() {
                            final risk =
                                controller.farmRisks[farm.id] ??
                                const FarmRiskStatus.safe();
                            return _buildFarmCard(context, farm, risk);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Backdrop gelap saat Speed-Dial terbuka ─────────────────
          if (_isFabOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeFab,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.black.withValues(alpha: 0.25)),
              ),
            ),

          // ── Floating Action Button (Right 24 agar sejajar dengan kartu) ──
          Positioned(
            right: AppSpace.screen,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Menu Pop-up ke atas
                ScaleTransition(
                  scale: _expandAnimation,
                  alignment: Alignment.bottomRight,
                  child: FadeTransition(
                    opacity: _expandAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white,
                        shadowColor: Colors.black.withValues(alpha: 0.2),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            _closeFab();
                            Get.to(() => const QuestionnaireScreen());
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.add_location_alt_outlined,
                                  size: 18,
                                  color: AppColors.accentPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tambah Lahan Baru',
                                  style: AppText.body(
                                    size: 13,
                                    weight: FontWeight.w700,
                                    color: AppColors.foregroundPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Tombol Bulat Kecil Utama (Plus Icon)
                Material(
                  elevation: 4,
                  shape: const CircleBorder(),
                  color: AppColors.accentPrimary,
                  shadowColor: Colors.black.withValues(alpha: 0.25),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _toggleFab,
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      child: AnimatedRotation(
                        turns: _isFabOpen ? 0.125 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
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

  // ── Kartu Lahan Hemat Tempat (Pojok atas bar kotak, bawah rounded) ──
  Widget _buildFarmCard(
    BuildContext context,
    FarmModel farm,
    FarmRiskStatus risk,
  ) {
    final (
      Color bannerBgColor,
      Color statusFgColor,
      IconData statusIcon,
      String statusText,
    ) = switch (risk.state) {
      FarmRiskState.safe => (
        const Color(0xFF28543B),
        Colors.white,
        Icons.check_circle_outline_rounded,
        'Aman hari ini',
      ),
      FarmRiskState.watch => (
        const Color(0xFFFDE6BD),
        const Color(0xFF8B5E34),
        Icons.warning_amber_rounded,
        risk.pestName != null
            ? 'Waspada: ${risk.pestName} ${risk.percentText ?? ''}'
            : 'Waspada: Thrips 45%',
      ),
      FarmRiskState.danger => (
        const Color(0xFFFCE4E2),
        const Color(0xFFB3261E),
        Icons.error_outline_rounded,
        risk.pestName != null
            ? 'Bahaya: ${risk.pestName} ${risk.percentText ?? ''}'
            : 'Bahaya',
      ),
      FarmRiskState.loading => (
        const Color(0xFF28543B),
        Colors.white,
        Icons.hourglass_empty_rounded,
        'Memeriksa...',
      ),
      FarmRiskState.error => (
        const Color(0xFFFDE6BD),
        const Color(0xFF8B5E34),
        Icons.cloud_off_rounded,
        'Belum bisa dicek',
      ),
    };

    return Container(
      decoration: BoxDecoration(
        color: bannerBgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadow.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => const FarmDetailScreen(), arguments: farm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Peta / Visual Lokasi (Top: rounded 16)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: _buildMapPreview(farm),
              ),

              // 2. Info Lahan (Putih dengan sudut bawah rounded 16)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm.farmName,
                      style: AppText.heading(
                        size: 18,
                        weight: FontWeight.w700,
                        color: AppColors.foregroundPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (farm.variety.isNotEmpty) _buildChip(farm.variety),
                        _buildChip(
                          _formatCropStage(farm.cropStage, farm.currentPhase),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Baris Status / Warning (Pojok atas KOTAK, pojok bawah ROUNDED 16)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: bannerBgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, size: 18, color: statusFgColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        statusText,
                        style: AppText.body(
                          size: 13,
                          weight: FontWeight.w700,
                          color: statusFgColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Pratinjau Peta Ringkas ─────────────────────────────────────
  Widget _buildMapPreview(FarmModel farm) {
    final hasCoords = farm.latitude != 0.0 && farm.longitude != 0.0;

    return Container(
      height: 120,
      width: double.infinity,
      color: const Color(0xFFDBE5D4),
      child: Stack(
        children: [
          if (hasCoords)
            Opacity(
              opacity: 0.55,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(farm.latitude, farm.longitude),
                  initialZoom: 14.5,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.siaga_tani',
                  ),
                ],
              ),
            ),
          const Center(
            child: Icon(
              Icons.location_on_outlined,
              color: Color(0xFF1B3A28),
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  // ── Chip Varietas / Fase Tanam Compact ─────────────────────────
  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFC8DBBC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: AppText.body(
          size: 12,
          weight: FontWeight.w600,
          color: const Color(0xFF1B3A28),
          height: 1.2,
        ),
      ),
    );
  }

  String _formatCropStage(CropStage stage, String currentPhase) {
    if (currentPhase.trim().isNotEmpty) {
      if (currentPhase.toLowerCase() == 'vegetatif') return 'Tumbuh Daun';
      return currentPhase;
    }
    switch (stage) {
      case CropStage.seedling:
        return 'Bibit';
      case CropStage.vegetative:
        return 'Tumbuh Daun';
      case CropStage.flowering:
        return 'Berbunga';
      case CropStage.fruiting:
        return 'Berbuah';
      case CropStage.harvesting:
        return 'Panen';
    }
  }
}
