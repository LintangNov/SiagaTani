import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/prediction_controller.dart';
import '../core/theme/app_theme.dart';
import '../data/models/weather_model.dart';
import 'weather_card.dart';

/// Kartu "Cuaca di Lahan Ini": cuaca di koordinat lahan (bukan lokasi HP)
/// dan satu kalimat sebab-akibat dari aturan hama yang benar-benar dipakai.
class FarmWeatherCard extends StatelessWidget {
  const FarmWeatherCard({super.key, required this.controller});

  final PredictionController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final weather = controller.weatherData.value;
      final loading = weather == null && controller.isAnalyzing.value;
      if (weather == null && !loading) return const SizedBox.shrink();

      final sky = weather == null ? WeatherSky.neutral : skyOfWeather(weather);
      final risks = controller.predictionResults;
      final cause = risks.isEmpty ? null : _causeOf(risks.first.detailedAnalysis, risks.first.shortDescription);

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpace.lg),
        decoration: sky.decoration.copyWith(boxShadow: AppShadow.card),
        child: weather == null
            ? const _Skeleton()
            : _Content(weather: weather, sky: sky, cause: cause),
      );
    });
  }

  /// Kalimat sebab pertama dari analisis detail; jatuh ke alasan singkat.
  static String _causeOf(String detail, String fallback) {
    for (final line in detail.split('\n')) {
      final t = line.trim();
      if (t.startsWith('•') && !t.contains('di sekitar')) {
        return t.substring(1).trim();
      }
    }
    return fallback;
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.weather, required this.sky, this.cause});

  final WeatherModel weather;
  final WeatherSky sky;
  final String? cause;

  @override
  Widget build(BuildContext context) {
    final fg = sky.foreground;
    final tile = fg.withValues(alpha: 0.16);
    final rainPerHour = weather.rainfall24h / 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuaca di Lahan Ini',
          style: AppText.body(
            size: 13,
            weight: FontWeight.w600,
            color: fg,
            height: 1.3,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.toStringAsFixed(0)}°C',
                    style: AppText.heading(size: 36, color: fg, height: 1.1),
                  ),
                  Text(
                    weather.condition.capitalizeFirst ?? weather.condition,
                    style: AppText.body(
                      size: 16,
                      weight: FontWeight.w500,
                      color: fg,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(sky.icon, size: 56, color: fg),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            Expanded(
              child: _Tile(
                color: tile,
                fg: fg,
                icon: Icons.water_drop_outlined,
                label: 'Kelembapan',
                value: '${weather.humidity.toStringAsFixed(0)}%',
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: _Tile(
                color: tile,
                fg: fg,
                icon: Icons.air,
                label: 'Angin',
                value: '${weather.windSpeed.toStringAsFixed(0)} km/jam',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        Row(
          children: [
            Expanded(
              child: _Tile(
                color: tile,
                fg: fg,
                icon: Icons.umbrella_outlined,
                label: 'Hujan',
                value: '${rainPerHour.toStringAsFixed(1)} mm/jam',
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: _Tile(
                color: tile,
                fg: fg,
                icon: Icons.calendar_month_outlined,
                label: 'Musim',
                value: weather.season.replaceFirst('Musim ', ''),
              ),
            ),
          ],
        ),
        if (cause != null) ...[
          const SizedBox(height: AppSpace.md),
          Text(
            cause!,
            style: AppText.body(size: 14, color: fg, height: 1.4),
          ),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.color,
    required this.fg,
    required this.icon,
    required this.label,
    required this.value,
  });

  final Color color;
  final Color fg;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.sm,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: AppSpace.xs),
              Flexible(
                child: Text(
                  label,
                  style: AppText.body(
                    size: 13,
                    weight: FontWeight.w500,
                    color: fg,
                    height: 1.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppText.body(
              size: 16,
              weight: FontWeight.w700,
              color: fg,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.onAccent.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Semantics(
      label: 'Memuat cuaca lahan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(120, 14),
          const SizedBox(height: AppSpace.sm),
          bar(84, 38),
          const SizedBox(height: AppSpace.xs),
          bar(140, 18),
          const SizedBox(height: AppSpace.md),
          bar(double.infinity, 56),
          const SizedBox(height: AppSpace.sm),
          bar(double.infinity, 56),
        ],
      ),
    );
  }
}
