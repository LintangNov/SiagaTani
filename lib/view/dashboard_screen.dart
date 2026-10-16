import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/dashboard_controller.dart';
import '../core/theme/app_theme.dart';
import '../data/models/farm_risk_status.dart';
import '../widgets/common/app_button.dart';
import '../widgets/farm_overview_card.dart';
import '../widgets/weather_card.dart';
import 'question.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.onSeeAllFarms});

  /// Dipanggil saat "Lihat Semua" diketuk; biasanya pindah ke tab Lahan Saya.
  final VoidCallback? onSeeAllFarms;

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AppColors.surfacePrimary,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshAll,
          color: AppColors.accentPrimary,
          backgroundColor: AppColors.surfaceCard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              top: AppSpace.lg,
              bottom: AppSpace.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _padded(_Greeting(controller: controller)),
                _LocationBannerSection(controller: controller),
                const SizedBox(height: AppSpace.md),
                _padded(WeatherCard(controller: controller)),
                const SizedBox(height: AppSpace.lg),
                _FarmsSection(controller: controller, onSeeAll: onSeeAllFarms),
                _padded(_TipsSection(controller: controller)),
                _AddFarmButton(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _padded(Widget child) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
  child: child,
);

// ── Sapaan + lokasi ─────────────────────────────────────────

class _Greeting extends StatelessWidget {
  const _Greeting({required this.controller});

  final DashboardController controller;

  static String _salutation(int hour) {
    if (hour >= 5 && hour <= 10) return 'Selamat pagi,';
    if (hour >= 11 && hour <= 14) return 'Selamat siang,';
    if (hour >= 15 && hour <= 17) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = DateFormat('EEEE', 'id_ID').format(now);
    final date = DateFormat('d MMM y', 'id_ID').format(now);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _salutation(now.hour),
                style: AppText.body(size: 16, height: 1.3),
              ),
              Obx(
                () => Text(
                  controller.userName.value,
                  style: AppText.heading(size: 24),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppSpace.xs),
              _LocationLine(controller: controller),
            ],
          ),
        ),
        const SizedBox(width: AppSpace.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              weekday,
              style: AppText.body(
                size: 14,
                weight: FontWeight.w600,
                color: AppColors.foregroundPrimary,
                height: 1.3,
              ),
            ),
            Text(date, style: AppText.body(size: 13, height: 1.3)),
          ],
        ),
      ],
    );
  }
}

/// Lokasi saat ini: teks biasa, tidak bisa diketuk (muat ulang lewat tarik).
class _LocationLine extends StatelessWidget {
  const _LocationLine({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.locationStatus.value;
      if (status != LocationStatus.ok && status != LocationStatus.loading) {
        return const SizedBox.shrink();
      }
      return Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 18,
            color: AppColors.accentPrimary,
          ),
          const SizedBox(width: AppSpace.xs),
          Expanded(
            child: Text(
              controller.currentLocation.value,
              style: AppText.body(
                size: 14,
                weight: FontWeight.w500,
                color: AppColors.foregroundPrimary,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    });
  }
}

/// Banner hanya muncul saat lokasi bermasalah, karena perbaikannya
/// (nyalakan GPS, beri izin) tidak bisa dilakukan lewat tarik-untuk-muat-ulang.
class _LocationBannerSection extends StatelessWidget {
  const _LocationBannerSection({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.locationStatus.value;
      if (status == LocationStatus.ok || status == LocationStatus.loading) {
        return const SizedBox.shrink();
      }

      final (String message, String action) = switch (status) {
        LocationStatus.gpsOff => (
          'GPS di HP Anda mati, jadi cuaca lokasi Anda belum bisa ditampilkan.',
          'Nyalakan GPS',
        ),
        LocationStatus.denied => (
          'SiagaTani butuh izin lokasi untuk menampilkan cuaca di sekitar Anda.',
          'Beri Izin',
        ),
        LocationStatus.blocked => (
          'Izin lokasi dimatikan. Buka Pengaturan untuk mengaktifkannya lagi.',
          'Buka Pengaturan',
        ),
        _ => (
          'Lokasi belum ditemukan. Coba lagi di tempat terbuka.',
          'Coba Lagi',
        ),
      };
      return Padding(
        padding: const EdgeInsets.only(top: AppSpace.md),
        child: _padded(
          _LocationBanner(
            message: message,
            actionLabel: action,
            onAction: controller.handleLocationAction,
          ),
        ),
      );
    });
  }
}

class _LocationBanner extends StatelessWidget {
  const _LocationBanner({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: AppRadius.cardBorder,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_off_outlined,
                  size: 20,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    message,
                    style: AppText.body(
                      size: 14,
                      color: AppColors.foregroundPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            AppButton(label: actionLabel, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}

// ── Lahan (geser horizontal) ────────────────────────────────

class _FarmsSection extends StatelessWidget {
  const _FarmsSection({required this.controller, required this.onSeeAll});

  final DashboardController controller;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final farms = controller.farms.toList();
      final loading = controller.farmsLoading.value;
      final failed = controller.farmsFailed.value;
      final hasLink = farms.isNotEmpty && onSeeAll != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _padded(
            Row(
              children: [
                Expanded(
                  child: Text('Lahan Anda', style: AppText.heading(size: 18)),
                ),
                if (hasLink)
                  TextButton(
                    onPressed: onSeeAll,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(AppSize.touch, AppSize.touch),
                      padding: const EdgeInsets.only(left: AppSpace.md),
                    ),
                    child: Text(
                      'Lihat Semua',
                      style: AppText.body(
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.accentPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!hasLink) const SizedBox(height: AppSpace.sm),
          if (loading)
            const _FarmSkeletonRow()
          else if (failed)
            _padded(
              _MessageCard(
                icon: Icons.cloud_off_outlined,
                message: 'Data lahan belum bisa dimuat.',
                actionLabel: 'Coba Lagi',
                onAction: controller.retryFarms,
              ),
            )
          else if (farms.isEmpty)
            _padded(
              _MessageCard(
                icon: Icons.eco_outlined,
                title: 'Belum ada lahan',
                message:
                    'Tambahkan lahan pertama Anda untuk mendapat saran cuaca dan hama.',
                actionLabel: 'Tambah Lahan Pertama',
                onAction: () => Get.to(() => const QuestionnaireScreen()),
              ),
            )
          else
            _FarmCarousel(controller: controller),
          const SizedBox(height: AppSpace.lg),
        ],
      );
    });
  }
}

/// Ruang vertikal untuk bayangan kartu di dalam daftar geser (yang memotong isi).
const double _shadowTop = 4;
const double _shadowBottom = 10;

class _FarmCarousel extends StatelessWidget {
  const _FarmCarousel({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.4);
    final farms = controller.farms.toList();
    final single = farms.length == 1;
    final width = single
        ? MediaQuery.sizeOf(context).width - AppSpace.screen * 2
        : FarmOverviewCard.defaultWidth;

    return SizedBox(
      height: FarmOverviewCard.height * scale + _shadowTop + _shadowBottom,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpace.screen,
          _shadowTop,
          AppSpace.screen,
          _shadowBottom,
        ),
        itemCount: farms.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpace.md),
        itemBuilder: (context, i) {
          final farm = farms[i];
          return Obx(
            () => FarmOverviewCard(
              farm: farm,
              width: width,
              risk:
                  controller.farmRisks[farm.id] ??
                  const FarmRiskStatus.loading(),
            ),
          );
        },
      ),
    );
  }
}

class _FarmSkeletonRow extends StatelessWidget {
  const _FarmSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat lahan',
      child: SizedBox(
        height: FarmOverviewCard.height + _shadowTop + _shadowBottom,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpace.screen,
            _shadowTop,
            AppSpace.screen,
            _shadowBottom,
          ),
          itemCount: 2,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpace.md),
          itemBuilder: (_, __) => Container(
            width: FarmOverviewCard.defaultWidth,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary.withValues(alpha: 0.5),
              borderRadius: AppRadius.cardBorder,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.title,
  });

  final IconData icon;
  final String? title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

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
        children: [
          Icon(icon, size: 32, color: AppColors.accentPrimary),
          const SizedBox(height: AppSpace.sm),
          if (title != null) ...[
            Text(
              title!,
              style: AppText.heading(size: 18, weight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpace.xs),
          ],
          Text(
            message,
            style: AppText.body(size: 15, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.md),
          AppButton(label: actionLabel, onPressed: onAction),
        ],
      ),
    );
  }
}

// ── Saran Hari Ini ──────────────────────────────────────────

class _TipsSection extends StatelessWidget {
  const _TipsSection({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tips = controller.dailyTips.toList();
      if (tips.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saran Hari Ini', style: AppText.heading(size: 18)),
          const SizedBox(height: AppSpace.sm),
          for (var i = 0; i < tips.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpace.sm),
            _TipCard(tip: tips[i]),
          ],
          const SizedBox(height: AppSpace.lg),
        ],
      );
    });
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final DailyTip tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.cardBorder,
        boxShadow: AppShadow.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surfaceSecondary,
              shape: BoxShape.circle,
            ),
            child: Icon(tip.icon, size: 22, color: AppColors.foregroundPrimary),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: AppText.heading(size: 16, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(tip.body, style: AppText.body(size: 15, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tombol utama ────────────────────────────────────────────

class _AddFarmButton extends StatelessWidget {
  const _AddFarmButton({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Saat belum ada lahan, CTA sudah ada di kartu kosong.
      final showButton =
          controller.farmsLoading.value ||
          controller.farmsFailed.value ||
          controller.farms.isNotEmpty;
      if (!showButton) return const SizedBox.shrink();

      return _padded(
        AppButton(
          label: 'Tambah Lahan',
          icon: Icons.add,
          onPressed: () => Get.to(() => const QuestionnaireScreen()),
        ),
      );
    });
  }
}
