import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Pastikan sudah add package google_fonts
import 'package:siaga_tani/view/main_screen.dart';
import 'package:siaga_tani/view/question.dart'; // Karena kamu pakai GetX di projectmu
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controller untuk PageView
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  // Data untuk setiap slide (Bisa diganti gambar aset kamu nanti)
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "The next generation\nof farming",
      "desc": "We provide data that enables the goals of global agriculture.",
      "icon": Icons.agriculture_rounded, // Ganti dengan path image kamu
    },
    {
      "title": "Monitor your crops\nin real-time",
      "desc": "Get instant insights about weather and pest predictions.",
      "icon": Icons.bar_chart_rounded,
    },
    {
      "title": "Connect with\nlocal farmers",
      "desc": "Share knowledge and resources with the community.",
      "icon": Icons.people_alt_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna background atas (Langit/Hijau muda)
      backgroundColor: const Color(0xFFE0F2F1),
      body: SafeArea(
        child: Column(
          children: [
            // --- BAGIAN ATAS: ILUSTRASI / GAMBAR ---
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ganti Icon ini dengan Image.asset('assets/...') nanti
                      Icon(
                        _onboardingData[index]['icon'],
                        size: 150,
                        color: Colors.teal[700],
                      ),
                      const SizedBox(height: 20),
                      // Hiasan lingkaran kecil (opsional, biar mirip desain)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFloatingIcon(Icons.wb_sunny, Colors.orange),
                          const SizedBox(width: 20),
                          _buildFloatingIcon(Icons.water_drop, Colors.blue),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            // --- BAGIAN BAWAH: TEXT & TOMBOL (KARTU PUTIH) ---
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 30,
                  ),
                  child: Column(
                    children: [
                      // Judul
                      Text(
                        _onboardingData[_currentPage]['title'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(
                            0xFF2C3312,
                          ), // Warna hijau tua dark
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      Text(
                        _onboardingData[_currentPage]['desc'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),

                      const Spacer(),

                      // Indikator Slide (Titik-titik)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => _buildDot(index),
                        ),
                      ),

                      const Spacer(),

                      // Tombol Get Started
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            // Aksi kalau tombol ditekan
                            if (_currentPage == _onboardingData.length - 1) {
                              // --- BAGIAN INI YANG DIGANTI ---
                              // Menggunakan Get.off() supaya user gak bisa kembali (back) ke onboarding lagi
                              // Get.off(
                              //   () => const QuestionnaireScreen(),
                              //   transition: Transition
                              //       .rightToLeft, // Tambah animasi biar transisinya halus
                              //   duration: const Duration(milliseconds: 500),
                              // );
                              Get.offAll(
                                () => const MainScreen(),
                                transition: Transition.fade,
                                duration: const Duration(milliseconds: 500),
                              );
                            } else {
                              // Kalau belum, geser ke halaman berikutnya
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF3E2723,
                            ), // Coklat tua kayak di gambar
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _onboardingData.length - 1
                                    ? "Mulai Sekarang"
                                    : "Lanjut",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget kecil untuk membuat dot indicator
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 25 : 6, // Kalau aktif jadi panjang
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF4CAF50)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  // Widget hiasan icon bulat
  Widget _buildFloatingIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Icon(icon, color: color),
    );
  }
}
