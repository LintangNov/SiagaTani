import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/dashboard_controller.dart';
import '../core/theme/app_theme.dart';
import '../data/models/weather_model.dart';

enum WeatherSky { clear, hot, cloudy, rain, neutral }

WeatherSky skyOfWeather(WeatherModel w) {
  final c = w.condition.toLowerCase();
  if (c.contains('hujan') ||
      c.contains('gerimis') ||
      c.contains('badai') ||
      c.contains('petir')) {
    return WeatherSky.rain;
  }
  final cloudy =
      c.contains('awan') ||
      c.contains('berawan') ||
      c.contains('mendung') ||
      c.contains('kabut') ||
      c.contains('asap');
  if (cloudy && !c.contains('sedikit')) return WeatherSky.cloudy;
  return w.temperature >= 32 ? WeatherSky.hot : WeatherSky.clear;
}

extension WeatherSkyStyle on WeatherSky {
  Color get foreground =>
      this == WeatherSky.hot ? AppColors.foregroundPrimary : AppColors.onAccent;

  BoxDecoration get decoration {
    switch (this) {
      case WeatherSky.clear:
        return BoxDecoration(
          color: AppColors.weatherClear,
          borderRadius: AppRadius.cardBorder,
        );
      case WeatherSky.hot:
        return BoxDecoration(
          color: AppColors.weatherHot,
          borderRadius: AppRadius.cardBorder,
        );
      case WeatherSky.cloudy:
        return BoxDecoration(
          color: AppColors.weatherCloudy,
          borderRadius: AppRadius.cardBorder,
        );
      case WeatherSky.rain:
        return BoxDecoration(
          color: AppColors.weatherRain,
          borderRadius: AppRadius.cardBorder,
        );
      case WeatherSky.neutral:
        return BoxDecoration(
          gradient: AppColors.mainCardGradient,
          borderRadius: AppRadius.cardBorder,
        );
    }
  }

  IconData get icon {
    switch (this) {
      case WeatherSky.rain:
        return Icons.thunderstorm_outlined;
      case WeatherSky.cloudy:
        return Icons.cloud_outlined;
      case WeatherSky.hot:
      case WeatherSky.clear:
      case WeatherSky.neutral:
        return Icons.wb_sunny_outlined;
    }
  }
}

/// Kartu cuaca Beranda: tanggal, suhu, kondisi, dan tiga metrik.
/// Warna latar mengikuti kondisi cuaca; pembaruan lewat tarik-untuk-muat-ulang.
class WeatherCard extends StatelessWidget {
  final DashboardController controller;

  const WeatherCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final weather = controller.currentWeather.value;
      final loading = controller.isLoadingWeather.value && weather == null;
      final failed = weather == null && controller.weatherFailed.value;
      final sky = weather == null ? WeatherSky.neutral : skyOfWeather(weather);

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpace.lg),
        decoration: sky.decoration.copyWith(boxShadow: AppShadow.card),
        child: loading
            ? const _Skeleton()
            : (failed || weather == null)
            ? _ErrorState(onRetry: controller.refreshWeather)
            : _Content(controller: controller, weather: weather, sky: sky),
      );
    });
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.controller,
    required this.weather,
    required this.sky,
  });

  final DashboardController controller;
  final WeatherModel weather;
  final WeatherSky sky;

  @override
  Widget build(BuildContext context) {
    final fg = sky.foreground;
    final updated = controller.weatherUpdatedAt.value;
    final label = controller.weatherLabel.value;
    final rainPerHour = weather.rainfall24h / 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppText.body(
                  size: 13,
                  weight: FontWeight.w600,
                  color: fg,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (updated != null) ...[
              const SizedBox(width: AppSpace.sm),
              Text(
                'Diperbarui ${DateFormat('HH.mm').format(updated)}',
                style: AppText.body(size: 12, color: fg, height: 1.3),
              ),
            ],
          ],
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
            Icon(sky.icon, size: 60, color: fg),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            _Metric(
              icon: Icons.water_drop_outlined,
              label: 'Lembap',
              value: '${weather.humidity.toStringAsFixed(0)}%',
              color: fg,
            ),
            _Metric(
              icon: Icons.air,
              label: 'Angin',
              value: '${weather.windSpeed.toStringAsFixed(0)} km/j',
              color: fg,
            ),
            _Metric(
              icon: Icons.umbrella_outlined,
              label: 'Hujan',
              value: '${rainPerHour.toStringAsFixed(1)} mm/j',
              color: fg,
            ),
          ],
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpace.xs),
              Flexible(
                child: Text(
                  label,
                  style: AppText.body(
                    size: 13,
                    weight: FontWeight.w500,
                    color: color,
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
              color: color,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.cloud_off_outlined, color: AppColors.onAccent),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Text(
                'Cuaca belum bisa dimuat.',
                style: AppText.body(
                  size: 16,
                  weight: FontWeight.w600,
                  color: AppColors.onAccent,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        TextButton.icon(
          onPressed: onRetry,
          style: TextButton.styleFrom(
            backgroundColor: AppColors.onAccent,
            foregroundColor: AppColors.accentPrimary,
            minimumSize: const Size(AppSize.touch, AppSize.touch),
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonBorder),
          ),
          icon: const Icon(Icons.refresh, size: 22),
          label: Text(
            'Coba Lagi',
            style: AppText.body(
              size: 16,
              weight: FontWeight.w600,
              color: AppColors.accentPrimary,
              height: 1.2,
            ),
          ),
        ),
      ],
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
      label: 'Memuat cuaca',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(140, 14),
          const SizedBox(height: AppSpace.sm),
          bar(84, 38),
          const SizedBox(height: AppSpace.xs),
          bar(140, 18),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              Expanded(child: bar(double.infinity, 36)),
              const SizedBox(width: AppSpace.md),
              Expanded(child: bar(double.infinity, 36)),
              const SizedBox(width: AppSpace.md),
              Expanded(child: bar(double.infinity, 36)),
            ],
          ),
        ],
      ),
    );
  }
}
