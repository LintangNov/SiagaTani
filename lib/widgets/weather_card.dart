import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';

/// Compact, stylized weather widget for the dashboard.
/// Displays temperature, condition, and key metrics in a gradient card.
class WeatherCard extends StatelessWidget {
  final DashboardController controller;

  const WeatherCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final weather = controller.currentWeather.value;

      List<Color> gradientColors;
      Color textColor;
      Color iconColor;
      IconData weatherIcon;

      final condition = (weather?.condition ?? "").toLowerCase();

      if (condition.contains("hujan")) {
        gradientColors = [const Color(0xFF546E7A), const Color(0xFF78909C)];
        textColor = Colors.white;
        iconColor = Colors.white70;
        weatherIcon = Icons.thunderstorm_rounded;
      } else if (condition.contains("awan") || condition.contains("berawan")) {
        gradientColors = [const Color(0xFF42A5F5), const Color(0xFF90CAF9)];
        textColor = Colors.white;
        iconColor = Colors.white70;
        weatherIcon = Icons.cloud_rounded;
      } else {
        gradientColors = [const Color(0xFFFF8F00), const Color(0xFFFFCA28)];
        textColor = const Color(0xFF4E342E);
        iconColor = Colors.white54;
        weatherIcon = Icons.wb_sunny_rounded;
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: controller.isLoadingWeather.value
            ? const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${weather?.temperature.toStringAsFixed(0) ?? '--'}°C",
                              style: GoogleFonts.poppins(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (weather?.condition ?? "Tidak ada data")
                                      .capitalizeFirst ??
                                  "",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: textColor.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(weatherIcon, size: 56, color: iconColor),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWeatherInfo(
                        "Kelembapan",
                        "${weather?.humidity.toStringAsFixed(0) ?? '-'}%",
                        textColor,
                      ),
                      _buildWeatherInfo(
                        "Angin",
                        "${weather?.windSpeed.toStringAsFixed(1) ?? '-'} km/h",
                        textColor,
                      ),
                      _buildWeatherInfo(
                        "Curah Hujan",
                        (weather?.rainfall24h ?? 0) > 0
                            ? "${weather!.rainfall24h.toStringAsFixed(1)} mm"
                            : "0 mm",
                        textColor,
                      ),
                    ],
                  ),
                ],
              ),
      );
    });
  }

  Widget _buildWeatherInfo(String label, String value, Color contentColor) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: contentColor.withOpacity(0.75),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: contentColor,
            ),
          ),
        ),
      ],
    );
  }
}
