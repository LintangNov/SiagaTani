import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:siaga_tani/controllers/dashboard_controller.dart';
import 'package:siaga_tani/view/question.dart'; // Import Questionnaire

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER LOKASI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Lokasi Anda", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFFE57373), size: 18),
                          const SizedBox(width: 5),
                          Text("Sleman, Yogyakarta", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2C3312))),
                        ],
                      )
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.notifications_none, color: Colors.black54),
                  )
                ],
              ),

              const SizedBox(height: 25),

              // 2. WEATHER WIDGET
              Obx(() {
                var weather = controller.currentWeather.value;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD54F), Color(0xFFFFB74D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: controller.isLoadingWeather.value 
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${weather?.temperature ?? '--'}°C", style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF4E342E))),
                                Text(weather?.condition ?? "Cerah", style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF5D4037))),
                              ],
                            ),
                            const Icon(Icons.wb_sunny_rounded, size: 60, color: Colors.white54),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildWeatherInfo("Kelembapan", "${weather?.humidity ?? '-'}%", "Baik"),
                            _buildWeatherInfo("Angin", "${weather?.windSpeed ?? '-'}km/h", "Normal"),
                            _buildWeatherInfo("Hujan", "Rendah", "Low"),
                          ],
                        )
                      ],
                    ),
                );
              }),

              const SizedBox(height: 30),

              // 3. MENU GRID
              Center(
                child: Column(
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 10),
                    Text("Manage your fields", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF2C3312))),
                  ],
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
                  // TOMBOL MY FARM -> Mengarah ke Questionnaire (Tambah Lahan)
                  _buildMenuCard(
                    "Tambah Lahan", 
                    Icons.add_location_alt_rounded, 
                    Colors.green,
                    onTap: () {
                      // NAVIGASI KE QUESTIONNAIRE
                      Get.to(() => const QuestionnaireScreen());
                    }
                  ),
                  _buildMenuCard("Tanaman", Icons.grass, Colors.teal, onTap: (){}),
                  _buildMenuCard("Inventaris", Icons.inventory_2_rounded, Colors.brown, onTap: (){}),
                  _buildMenuCard("Keuangan", Icons.monetization_on_rounded, Colors.orange, onTap: (){}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(String label, String value, String status) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF5D4037))),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
          child: Text(status, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF4E342E))),
        )
      ],
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 15),
            Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF2C3312))),
          ],
        ),
      ),
    );
  }
}