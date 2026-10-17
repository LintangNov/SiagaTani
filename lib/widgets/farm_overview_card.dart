import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/app_theme.dart';
import '../data/models/farm_model.dart';
import '../data/models/farm_risk_status.dart';
import '../view/farm_detail_screen.dart';

/// Kartu lahan ringkas untuk daftar geser horizontal di Beranda.
/// Struktur: [info lahan putih] + [status bar bawah berwarna] — identik
/// dengan gaya kartu di MyFarmScreen (pojok atas kotak, pojok bawah rounded).
class FarmOverviewCard extends StatelessWidget {
  static const double defaultWidth = 264;
  // Tinggi disesuaikan agar muat info + status bar
  static const double height = 128;

  final FarmModel farm;
  final FarmRiskStatus risk;
  final double width;

  const FarmOverviewCard({
    super.key,
    required this.farm,
    required this.risk,
    this.width = defaultWidth,
  });

  // ── Warna status bar (identik my_farm_screen.dart) ─────────────
  static const _safeBar = Color(0xFF28543B);
  static const _watchBar = Color(0xFFFDE6BD);
  static const _dangerBar = Color(0xFFFCE4E2);
  static const _neutralBar = Color(0xFFF0EDE8);

  static const _safeFg = Colors.white;
  static const _watchFg = Color(0xFF8B5E34);
  static const _dangerFg = Color(0xFFB3261E);
  static const _neutralFg = AppColors.foregroundSecondary;

  @override
  Widget build(BuildContext context) {
    final (
      IconData icon,
      Color barBg,
      Color barFg,
      String label,
    ) = switch (risk.state) {
      FarmRiskState.safe => (
        Icons.check_circle_outline_rounded,
        _safeBar,
        _safeFg,
        'Aman hari ini',
      ),
      FarmRiskState.watch => (
        Icons.warning_amber_rounded,
        _watchBar,
        _watchFg,
        risk.pestName != null
            ? 'Waspada: ${risk.pestName} ${risk.percentText ?? ''}'
            : 'Waspada',
      ),
      FarmRiskState.danger => (
        Icons.error_outline_rounded,
        _dangerBar,
        _dangerFg,
        risk.pestName != null
            ? 'Bahaya: ${risk.pestName} ${risk.percentText ?? ''}'
            : 'Bahaya',
      ),
      FarmRiskState.loading => (
        Icons.hourglass_empty_rounded,
        _neutralBar,
        _neutralFg,
        'Memeriksa...',
      ),
      FarmRiskState.error => (
        Icons.cloud_off_outlined,
        _neutralBar,
        _neutralFg,
        'Belum bisa dicek',
      ),
    };

    return Semantics(
      button: true,
      label: '${farm.farmName}, ${_phaseLabel(farm.cropStage)}, $label',
      excludeSemantics: true,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          // Outer container berwarna netral — pojok rounded penuh
          // BoxShadow harus di sini (bukan di ClipRRect) agar bayangan tampil
          color: barBg,
          borderRadius: AppRadius.cardBorder,
          boxShadow: AppShadow.card,
        ),
        child: ClipRRect(
          // ClipRRect memastikan sudut section putih terpotong rapi
          // sesuai rounded corner luar — tidak kaku/kotak
          borderRadius: AppRadius.cardBorder,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: AppRadius.cardBorder,
              onTap: () =>
                  Get.to(() => const FarmDetailScreen(), arguments: farm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Bagian putih (info lahan) ─────────────────────
                  // Tidak perlu borderRadius — ClipRRect luar sudah
                  // memotong sudut atas maupun bawah seluruh card.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
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
                            weight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpace.md),
                        Wrap(
                          spacing: AppSpace.sm,
                          runSpacing: AppSpace.sm,
                          children: [
                            if (farm.variety.isNotEmpty)
                              _Chip(
                                label: farm.variety,
                                background: AppColors.surfaceSecondary,
                              ),
                            _Chip(
                              label: _phaseLabel(farm.cropStage),
                              background: AppColors.surfacePrimary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  // ── Status bar bawah (warna outer container) ─────
                  // Sudut bawah dihandle ClipRRect, tidak perlu radius sendiri.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 3,
                    ),
                    color: barBg,
                    child: Row(
                      children: [
                        Icon(icon, size: 16, color: barFg),
                        const SizedBox(width: AppSpace.xs),
                        Expanded(
                          child: Text(
                            label,
                            style: AppText.body(
                              size: 12,
                              weight: FontWeight.w600,
                              color: barFg,
                              height: 1.25,
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
        ),
      ),
    );
  }

  static String _phaseLabel(CropStage stage) {
    switch (stage) {
      case CropStage.seedling:
        return 'Bibit';
      case CropStage.vegetative:
        return 'Vegetatif';
      case CropStage.flowering:
        return 'Berbunga';
      case CropStage.fruiting:
        return 'Berbuah';
      case CropStage.harvesting:
        return 'Panen';
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.background});

  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppText.body(
          size: 12,
          weight: FontWeight.w500,
          color: AppColors.foregroundPrimary,
          height: 1.3,
        ),
      ),
    );
  }
}
