import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/prediction_controller.dart';
import '../core/theme/app_theme.dart';
import '../data/models/farm_model.dart';
import '../data/models/prediction_result.dart';
import '../widgets/common/app_back_button.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/icon_circle_button.dart';
import '../widgets/common/sheet_container.dart';
import '../widgets/farm_dialogs.dart';
import '../widgets/farm_weather_card.dart';
import 'risk_detail_screen.dart';

class FarmDetailScreen extends StatefulWidget {
  const FarmDetailScreen({super.key});

  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  static const _maxRisks = 3;

  late final String _tag = 'farm-detail-${identityHashCode(this)}';
  late final PredictionController c = Get.put(
    PredictionController(),
    tag: _tag,
  );
  bool _showAllRisks = false;

  @override
  void dispose() {
    Get.delete<PredictionController>(tag: _tag);
    super.dispose();
  }

  double _toastOffset(BuildContext context) =>
      AppSpace.xl + AppSize.touch + AppSpace.xl + MediaQuery.of(context).padding.bottom + AppSpace.sm;

  // ── Aksi ─────────────────────────────────────────────────────

  Future<void> _openMenu() async {
    final action = await showFarmMenuSheet();
    final farm = c.farm;
    if (action == null || farm == null || !mounted) return;
    final offset = _toastOffset(context);

    if (action == FarmMenuAction.rename) {
      final name = await showRenameDialog(farm.farmName);
      if (name == null || name == farm.farmName) return;
      final ok = await c.renameFarm(name);
      showAppToast(
        ok ? 'Nama lahan diperbarui' : 'Nama lahan belum bisa diubah.',
        icon: ok ? Icons.check_circle_outline : Icons.error_outline,
        bottomOffset: offset,
      );
    } else {
      if (!await showDeleteDialog(farm.farmName)) return;
      if (await deleteFarmWithUndo(farm)) Get.back();
    }
  }

  Future<void> _changePhase() async {
    final farm = c.farm;
    if (farm == null) return;
    final phase = await showPhaseSheet(farm.cropStage);
    if (phase == null || phase.stage == farm.cropStage || !mounted) return;

    final previous = FarmPhase.all.firstWhere(
      (p) => p.stage == farm.cropStage,
      orElse: () => FarmPhase.all[1],
    );
    final offset = _toastOffset(context);
    final ok = await c.changePhase(phase.label, phase.stage);
    showAppToast(
      ok ? 'Fase diubah ke ${phase.label}' : 'Fase belum bisa diubah.',
      icon: ok ? Icons.check_circle_outline : Icons.error_outline,
      actionLabel: ok ? 'Urungkan' : null,
      onAction: () => c.changePhase(previous.label, previous.stage),
      bottomOffset: offset,
    );
  }

  Future<bool> _recordSpray() async {
    final value = await showSpraySheet();
    if (value == null) return false;
    final offset = mounted ? _toastOffset(context) : AppSpace.xl;
    final ok = await c.recordSpray(value);
    showAppToast(
      ok ? 'Penyemprotan dicatat' : 'Penyemprotan belum bisa dicatat.',
      icon: ok ? Icons.check_circle_outline : Icons.error_outline,
      bottomOffset: offset,
    );
    return ok;
  }

  void _openRisk(PredictionResult risk) {
    Get.to(
      () => RiskDetailScreen(
        result: risk,
        farmName: c.farm?.farmName ?? '',
        recentlySprayed: c.recentlySprayed,
        onRecordSpray: _recordSpray,
      ),
    );
  }

  // ── Tampilan ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final farm = c.farm;
      if (farm == null) return const _NotFound();

      return Scaffold(
        backgroundColor: AppColors.surfacePrimary,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBar(onMenu: _openMenu),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: c.runAnalysis,
                  color: AppColors.accentPrimary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.screen,
                      AppSpace.sm,
                      AppSpace.screen,
                      AppSpace.lg,
                    ),
                    children: [
                      Text(farm.farmName, style: AppText.heading(size: 24)),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        _subtitle(farm),
                        style: AppText.body(size: 14, height: 1.3),
                      ),
                      const SizedBox(height: AppSpace.md),
                      _buildStatusCard(),
                      ..._buildRiskSection(),
                      const SizedBox(height: AppSpace.lg),
                      FarmWeatherCard(controller: c),
                      const SizedBox(height: AppSpace.lg),
                      _InfoCard(farm: farm, onPhaseTap: _changePhase),
                      const SizedBox(height: AppSpace.lg),
                      _FarmMap(farm: farm),
                    ],
                  ),
                ),
              ),
              SheetContainer(
                shadow: true,
                child: AppButton(
                  label: 'Catat Penyemprotan',
                  icon: Icons.edit_note,
                  onPressed: _recordSpray,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _subtitle(FarmModel farm) {
    final parts = [
      if (farm.variety.isNotEmpty) farm.variety,
      if (farm.currentPhase.isNotEmpty) farm.currentPhase,
    ];
    return parts.join(' · ');
  }

  Widget _buildStatusCard() {
    return Obx(() {
      if (c.analysisFailed.value) {
        return _ErrorCard(onRetry: c.runAnalysis);
      }
      final updated = c.analyzedAt.value;
      if (c.isAnalyzing.value || updated == null) {
        return const _StatusSkeleton();
      }

      final risks = c.predictionResults;
      final _StatusView view;
      if (risks.isEmpty && c.recentlySprayed) {
        view = const _StatusView(
          icon: Icons.shield_outlined,
          title: 'Terlindungi sementara',
          message:
              'Anda baru menyemprot, jadi risiko diturunkan sementara. Tetap periksa tanaman.',
          color: AppColors.accentPrimary,
          background: AppColors.surfaceCard,
        );
      } else if (risks.isEmpty) {
        view = const _StatusView(
          icon: Icons.check_circle,
          title: 'Lahan Aman',
          message:
              'Tidak ada ancaman hama yang menonjol hari ini. Tetap periksa tanaman setiap hari.',
          color: AppColors.success,
          background: AppColors.successBg,
        );
      } else if (risks.first.riskLevel == RiskLevel.severe) {
        view = _StatusView(
          icon: Icons.error,
          title: 'Bahaya',
          message:
              'Ada ${risks.length} ancaman hama yang perlu ditangani hari ini.',
          color: AppColors.danger,
          background: AppColors.dangerBg,
        );
      } else {
        view = _StatusView(
          icon: Icons.warning_rounded,
          title: 'Waspada',
          message:
              'Ada ${risks.length} ancaman hama yang perlu diperhatikan hari ini.',
          color: AppColors.warning,
          background: AppColors.warningBg,
        );
      }

      return _StatusCard(view: view, updated: updated);
    });
  }

  List<Widget> _buildRiskSection() {
    final risks = c.predictionResults;
    if (c.analysisFailed.value || risks.isEmpty) return const [];

    final visible = _showAllRisks ? risks.toList() : risks.take(_maxRisks).toList();

    return [
      const SizedBox(height: AppSpace.lg),
      Text('Ancaman Hari Ini', style: AppText.heading(size: 18)),
      const SizedBox(height: AppSpace.sm),
      for (final risk in visible)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.sm),
          child: _RiskRow(risk: risk, onTap: () => _openRisk(risk)),
        ),
      if (risks.length > _maxRisks)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() => _showAllRisks = !_showAllRisks),
            style: TextButton.styleFrom(
              minimumSize: const Size(AppSize.touch, 48),
              foregroundColor: AppColors.accentPrimary,
            ),
            child: Text(
              _showAllRisks ? 'Tampilkan lebih sedikit' : 'Lihat semua (${risks.length})',
              style: AppText.body(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.accentPrimary,
                height: 1.2,
              ),
            ),
          ),
        ),
      _ActionCard(controller: c),
    ];
  }
}

// ── Bagian layar ─────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenu});

  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        AppSpace.sm,
        AppSpace.screen,
        AppSpace.sm,
      ),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: AppSpace.md),
          Expanded(child: Text('Detail Lahan', style: AppText.heading(size: 18))),
          IconCircleButton(
            icon: Icons.more_vert,
            semanticLabel: 'Menu lahan',
            onPressed: onMenu,
          ),
        ],
      ),
    );
  }
}

class _StatusView {
  const _StatusView({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final Color background;
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.view, required this.updated});

  final _StatusView view;
  final DateTime updated;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${view.title}. ${view.message}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpace.lg),
        decoration: BoxDecoration(
          color: view.background,
          borderRadius: AppRadius.cardBorder,
          boxShadow: AppShadow.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(view.icon, size: 32, color: view.color),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    view.title,
                    style: AppText.heading(size: 22, color: view.color),
                  ),
                ),
                Text(
                  DateFormat('HH.mm').format(updated),
                  style: AppText.body(
                    size: 12,
                    color: AppColors.foregroundSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              view.message,
              style: AppText.body(
                size: 15,
                color: AppColors.foregroundPrimary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusSkeleton extends StatelessWidget {
  const _StatusSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Semantics(
      label: 'Memeriksa risiko hama',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpace.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.cardBorder,
          boxShadow: AppShadow.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                bar(32, 32),
                const SizedBox(width: AppSpace.sm),
                bar(140, 22),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            bar(double.infinity, 15),
            const SizedBox(height: AppSpace.sm),
            bar(200, 15),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.cardBorder,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_off_outlined, size: 32, color: AppColors.danger),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Text(
                  'Risiko hama belum bisa dihitung. Periksa internet Anda.',
                  style: AppText.body(
                    size: 15,
                    weight: FontWeight.w600,
                    color: AppColors.foregroundPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          AppButton(label: 'Coba Lagi', icon: Icons.refresh, onPressed: onRetry),
        ],
      ),
    );
  }
}

class _RiskRow extends StatelessWidget {
  const _RiskRow({required this.risk, required this.onTap});

  final PredictionResult risk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = RiskLevelStyle.of(risk.riskLevel);
    return Semantics(
      button: true,
      label:
          '${risk.pestName}, tingkat ${risk.riskLevelString.toLowerCase()}. ${risk.shortDescription}',
      excludeSemantics: true,
      child: Material(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.cardBorder,
        child: InkWell(
          borderRadius: AppRadius.cardBorder,
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardBorder,
              boxShadow: AppShadow.card,
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpace.lg,
              AppSpace.md,
              AppSpace.md,
              AppSpace.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              risk.pestName,
                              style: AppText.heading(size: 16, height: 1.3),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpace.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: style.background,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(style.icon, size: 14, color: style.color),
                                const SizedBox(width: AppSpace.xs),
                                Text(
                                  risk.riskLevelString,
                                  style: AppText.body(
                                    size: 12,
                                    weight: FontWeight.w700,
                                    color: style.color,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        risk.shortDescription,
                        style: AppText.body(size: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: AppColors.foregroundTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.controller});

  final PredictionController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final steps = controller.aiSteps;
      final loading = controller.isLoadingAI.value;
      final failed = controller.aiFailed.value;

      final Widget body;
      if (loading) {
        body = Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.accentPrimary,
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Text(
                'Asisten sedang menyusun saran...',
                style: AppText.body(size: 14, height: 1.4),
              ),
            ),
          ],
        );
      } else if (failed || steps.isEmpty) {
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saran belum tersedia. Langkah penanganan tetap ada di halaman risiko.',
              style: AppText.body(size: 14, height: 1.4),
            ),
            const SizedBox(height: AppSpace.sm),
            TextButton.icon(
              onPressed: controller.fetchAISuggestion,
              style: TextButton.styleFrom(
                minimumSize: const Size(AppSize.touch, 48),
                foregroundColor: AppColors.accentPrimary,
              ),
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(
                'Coba Lagi',
                style: AppText.body(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.accentPrimary,
                  height: 1.2,
                ),
              ),
            ),
          ],
        );
      } else {
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.sm),
                child: Semantics(
                  label: 'Langkah ${i + 1}. ${steps[i]}',
                  excludeSemantics: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: AppText.heading(size: 14, letterSpacing: 0),
                        ),
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: Text(
                          steps[i],
                          style: AppText.body(
                            size: 15,
                            color: AppColors.foregroundPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Text(
              'Saran dari asisten AI. Hanya panduan, tanyakan penyuluh pertanian bila ragu.',
              style: AppText.body(
                size: 12,
                color: AppColors.foregroundTertiary,
                height: 1.4,
              ),
            ),
          ],
        );
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpace.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.cardBorder,
          boxShadow: AppShadow.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yang Perlu Dilakukan Hari Ini',
              style: AppText.heading(size: 16),
            ),
            const SizedBox(height: AppSpace.md),
            body,
          ],
        ),
      );
    });
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.farm, required this.onPhaseTap});

  final FarmModel farm;
  final VoidCallback onPhaseTap;

  static String _spray(String stored) {
    if (stored.contains('< 3 hari')) return 'Kurang dari 3 hari lalu';
    if (stored.contains('Seminggu')) return 'Sekitar seminggu lalu';
    if (stored.contains('Belum')) return 'Belum pernah';
    return 'Belum dicatat';
  }

  static String _mulch(MulchType type) {
    switch (type) {
      case MulchType.black:
        return 'Plastik hitam';
      case MulchType.silver:
        return 'Plastik perak';
      case MulchType.none:
        return 'Tidak memakai';
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = farm.currentPhase.isEmpty ? '-' : farm.currentPhase;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.cardBorder,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.xs),
            child: Text('Info Lahan', style: AppText.heading(size: 16)),
          ),
          _InfoRow(
            label: 'Fase tanam',
            value: phase,
            trailing: const Icon(
              Icons.arrow_drop_down,
              size: 24,
              color: AppColors.accentPrimary,
            ),
            onTap: onPhaseTap,
          ),
          _InfoRow(label: 'Semprot terakhir', value: _spray(farm.lastPesticideTime)),
          _InfoRow(label: 'Mulsa', value: _mulch(farm.mulchType)),
          _InfoRow(label: 'Alamat', value: farm.address),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          Text(label, style: AppText.body(size: 14, height: 1.3)),
          const SizedBox(width: AppSpace.lg),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppText.body(
                size: 14,
                weight: FontWeight.w600,
                color: onTap == null
                    ? AppColors.foregroundPrimary
                    : AppColors.accentPrimary,
                height: 1.3,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );

    if (onTap == null) return row;
    return Semantics(
      button: true,
      label: '$label: $value. Ketuk untuk mengubah.',
      excludeSemantics: true,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

class _FarmMap extends StatelessWidget {
  const _FarmMap({required this.farm});

  final FarmModel farm;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(farm.latitude, farm.longitude);

    return Semantics(
      label: 'Peta lokasi lahan',
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: AppRadius.cardBorder,
          boxShadow: AppShadow.card,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.cardBorder,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: point,
              initialZoom: 15,
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
                    point: point,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.location_on,
                      size: 44,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
              const SimpleAttributionWidget(
                source: Text('© OpenStreetMap'),
                backgroundColor: Color(0xCCFFFFFF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfacePrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.screen),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off,
                size: 72,
                color: AppColors.foregroundTertiary,
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                'Data lahan tidak ditemukan',
                style: AppText.heading(size: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpace.xl),
              AppButton(label: 'Kembali', onPressed: () => Get.back()),
            ],
          ),
        ),
      ),
    );
  }
}
