import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:siaga_tani/controllers/dashboard_controller.dart';
import 'package:siaga_tani/view/my_farm_screen.dart';
import 'package:siaga_tani/view/question.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchCurrentLocation(forceRefresh: true);
            controller.fetchUserData();
          },
          color: const Color(0xFF2C3312),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            "Hai, ${controller.userName.value} 👋",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3312),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                    // Notification
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.notifications_none,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => controller.handleLocationTap(),
                  child: Row(
                    children: [
                      Obx(
                        () => Icon(
                          Icons.location_on,
                          color:
                              controller.currentLocation.value.contains("Ketuk")
                              ? Colors.red
                              : const Color(0xFFE57373),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Obx(
                        () => SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            controller.currentLocation.value,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color:
                                  controller.currentLocation.value.contains(
                                    "Ketuk",
                                  )
                                  ? Colors.red
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              decoration:
                                  controller.currentLocation.value.contains(
                                    "Ketuk",
                                  )
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
                ),
                const SizedBox(height: 25),
                _buildWeatherSection(controller),
                const SizedBox(height: 25),
                _buildTipsSection(controller),
                const SizedBox(height: 30),
                _buildMenuSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherSection(DashboardController controller) {
    return Obx(() {
      var weather = controller.currentWeather.value;

      List<Color> gradientColors;
      Color textColor;
      Color iconColor;
      IconData weatherIcon;

      String condition = (weather?.condition ?? "").toLowerCase();

      if (condition.contains("hujan")) {
        gradientColors = [const Color(0xFF607D8B), const Color(0xFF90A4AE)];
        textColor = Colors.white;
        iconColor = Colors.white70;
        weatherIcon = Icons.thunderstorm;
      } else if (condition.contains("awan") || condition.contains("berawan")) {
        gradientColors = [const Color(0xFF42A5F5), const Color(0xFF90CAF9)];
        textColor = Colors.white;
        iconColor = Colors.white70;
        weatherIcon = Icons.cloud;
      } else {
        gradientColors = [const Color(0xFFFFB300), const Color(0xFFFFD54F)];
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
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: controller.isLoadingWeather.value
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${weather?.temperature.toStringAsFixed(0) ?? '--'}°C",
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            (weather?.condition ?? "Tidak ada data")
                                    .capitalizeFirst ??
                                "",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: textColor.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Icon(weatherIcon, size: 60, color: iconColor),
                    ],
                  ),
                  const SizedBox(height: 25),
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
            color: contentColor.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
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

  Widget _buildTipsSection(DashboardController controller) {
    return Obx(() {
      if (controller.dailyTips.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rekomendasi Hari Ini",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3312),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              itemCount: controller.dailyTips.length,
              itemBuilder: (context, index) {
                var tip = controller.dailyTips[index];
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: tip['color'],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
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
                          size: 30,
                          color: tip['textColor'],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tip['title'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: tip['textColor'],
                              ),
                            ),
                            const SizedBox(height: 4),
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

  Widget _buildMenuSection() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Kelola Lahanmu",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3312),
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.1,
          children: [
            _buildMenuCard(
              "Tambah Lahan",
              Icons.add_location_alt_rounded,
              Colors.green,
              onTap: () => Get.to(() => const QuestionnaireScreen()),
            ),
            _buildMenuCard(
              "Tanaman",
              Icons.grass,
              Colors.teal,
              onTap: () => Get.to(() => const MyFarmScreen()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    String title,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3312),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
