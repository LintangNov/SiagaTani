import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/app_theme.dart';
import '../data/models/prediction_result.dart';
import '../widgets/common/app_back_button.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/sheet_container.dart';

/// Detail satu risiko hama: tingkat, sebab, langkah, dan catatan keselamatan.
class RiskDetailScreen extends StatelessWidget {
  const RiskDetailScreen({
    super.key,
    required this.result,
    required this.farmName,
    required this.recentlySprayed,
    required this.onRecordSpray,
  });

  final PredictionResult result;
  final String farmName;
  final bool recentlySprayed;

  /// Membuka alur "Catat Penyemprotan"; true bila berhasil disimpan.
  final Future<bool> Function() onRecordSpray;

  bool get _mentionsSpray =>
      result.preventionSteps.any((s) => s.toLowerCase().contains('semprot'));

  @override
  Widget build(BuildContext context) {
    final style = RiskLevelStyle.of(result.riskLevel);
    final (opening, bullets) = _parseAnalysis(result.detailedAnalysis);

    return Scaffold(
      backgroundColor: AppColors.surfacePrimary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
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
                  Text('Detail Risiko', style: AppText.heading(size: 18)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.screen,
                  AppSpace.sm,
                  AppSpace.screen,
                  AppSpace.lg,
                ),
                children: [
                  Text(result.pestName, style: AppText.heading(size: 24)),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    farmName,
                    style: AppText.body(size: 14, height: 1.3),
                  ),
                  const SizedBox(height: AppSpace.md),
                  _LevelCard(result: result, style: style),
                  if (recentlySprayed) ...[
                    const SizedBox(height: AppSpace.md),
                    const _InfoBox(
                      icon: Icons.shield_outlined,
                      background: AppColors.successBg,
                      color: AppColors.success,
                      text:
                          'Anda baru menyemprot (kurang dari 3 hari lalu), jadi risiko diturunkan sementara. Tetap pantau tanaman.',
                    ),
                  ],
                  const SizedBox(height: AppSpace.lg),
                  Text(
                    'Mengapa ini terjadi di lahan Anda?',
                    style: AppText.heading(size: 18),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    opening,
                    style: AppText.body(size: 15, height: 1.45),
                  ),
                  for (final b in bullets)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpace.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: AppSpace.xs,
                              right: AppSpace.sm,
                            ),
                            child: Text(
                              '•',
                              style: AppText.body(
                                size: 15,
                                weight: FontWeight.w700,
                                color: AppColors.foregroundPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              b,
                              style: AppText.body(size: 15, height: 1.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpace.lg),
                  Text(
                    'Apa yang bisa Anda lakukan',
                    style: AppText.heading(size: 18),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  for (var i = 0; i < result.preventionSteps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.sm),
                      child: _StepCard(
                        number: i + 1,
                        text: result.preventionSteps[i],
                      ),
                    ),
                  const _InfoBox(
                    icon: Icons.warning_amber_rounded,
                    background: AppColors.warningBg,
                    color: AppColors.warning,
                    text:
                        'Baca label kemasan pestisida dan ikuti dosis yang tertera. Gunakan pelindung diri. Jangan menyemprot saat angin kencang.',
                  ),
                  const SizedBox(height: AppSpace.md),
                  Text(
                    'Ini perkiraan berdasarkan cuaca dan data lahan Anda, bukan diagnosis pasti. Periksa tanaman Anda secara langsung. Bila gejala berat, tanyakan ke penyuluh pertanian setempat.',
                    style: AppText.body(
                      size: 12,
                      color: AppColors.foregroundTertiary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SheetContainer(
              shadow: true,
              child: AppButton(
                label: _mentionsSpray ? 'Catat Penyemprotan' : 'Kembali ke Lahan',
                icon: _mentionsSpray ? Icons.edit_note : null,
                onPressed: () async {
                  if (!_mentionsSpray) {
                    Get.back();
                    return;
                  }
                  final saved = await onRecordSpray();
                  if (saved) Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Memisahkan kalimat pembuka dan butir "•". Butir yang menyebut tanaman
  /// di sekitar dibuang karena datanya tidak selalu akurat.
  static (String, List<String>) _parseAnalysis(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final opening = lines.where((l) => !l.startsWith('•')).join(' ');
    final bullets = lines
        .where((l) => l.startsWith('•') && !l.contains('di sekitar'))
        .map((l) => l.substring(1).trim())
        .toList();
    return (opening, bullets);
  }
}

class RiskLevelStyle {
  const RiskLevelStyle(this.color, this.background, this.icon, this.message);

  final Color color;
  final Color background;
  final IconData icon;
  final String message;

  static RiskLevelStyle of(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return const RiskLevelStyle(
          AppColors.success,
          AppColors.successBg,
          Icons.check_circle,
          'Kondisi belum mendukung hama ini.',
        );
      case RiskLevel.moderate:
        return const RiskLevelStyle(
          AppColors.warning,
          AppColors.warningBg,
          Icons.info,
          'Ada tanda-tanda yang perlu diawasi.',
        );
      case RiskLevel.high:
        return const RiskLevelStyle(
          AppColors.warning,
          AppColors.warningBg,
          Icons.warning_rounded,
          'Kondisi mendukung hama. Segera lakukan pencegahan.',
        );
      case RiskLevel.severe:
        return const RiskLevelStyle(
          AppColors.danger,
          AppColors.dangerBg,
          Icons.error,
          'Risiko serangan sangat besar. Lakukan tindakan hari ini.',
        );
    }
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.result, required this.style});

  final PredictionResult result;
  final RiskLevelStyle style;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Tingkat risiko ${result.riskLevelString.toLowerCase()}, ${(result.percentage * 100).round()} persen. ${style.message}',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpace.lg),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: AppRadius.cardBorder,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(style.icon, size: 28, color: style.color),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    result.riskLevelString,
                    style: AppText.heading(size: 22, color: style.color),
                  ),
                ),
                Text(
                  result.formattedPercentage,
                  style: AppText.heading(size: 22, color: style.color),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: result.percentage.clamp(0.0, 1.0),
                minHeight: 10,
                color: style.color,
                backgroundColor: AppColors.surfaceCard.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              style.message,
              style: AppText.body(
                size: 14,
                weight: FontWeight.w500,
                color: style.color,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.background,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color background;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.cardBorder,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              text,
              style: AppText.body(
                size: 14,
                weight: FontWeight.w500,
                color: color,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatefulWidget {
  const _StepCard({required this.number, required this.text});

  final int number;
  final String text;

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.cardBorder,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.lg,
              AppSpace.md,
              AppSpace.lg,
              0,
            ),
            child: Semantics(
              label: 'Langkah ${widget.number}. ${widget.text}',
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
                      '${widget.number}',
                      style: AppText.heading(size: 14, letterSpacing: 0),
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Text(
                      widget.text,
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
          Semantics(
            checked: _done,
            label: 'Sudah dikerjakan',
            excludeSemantics: true,
            child: InkWell(
              borderRadius: AppRadius.cardBorder,
              onTap: () => setState(() => _done = !_done),
              child: SizedBox(
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
                  child: Row(
                    children: [
                      Icon(
                        _done ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 24,
                        color: AppColors.accentPrimary,
                      ),
                      const SizedBox(width: AppSpace.md),
                      Text(
                        'Sudah dikerjakan',
                        style: AppText.body(
                          size: 14,
                          weight: FontWeight.w600,
                          color: AppColors.accentPrimary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
