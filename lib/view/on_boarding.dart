import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siaga_tani/view/main_screen.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Pertanian Digital\nMasa Depan",
      "desc": "Kami menyediakan data dan teknologi untuk mengotomatisasi dan mengoptimalkan pertanian global.",
      // Pastikan nama file sesuai dengan di folder assets/images/
      "icon": 'assets/images/onboarding_1.jpg',
    },
    {
      "title": "Monitor your crops\nin real-time",
      "desc": "Get instant insights about weather and pest predictions.",
      // Ganti dengan file gambar slide 2
      "icon": 'assets/images/onboarding_1.jpg',
    },
    {
      "title": "Connect with\nlocal farmers",
      "desc": "Share knowledge and resources with the community.",
      // Ganti dengan file gambar slide 3
      "icon": 'assets/images/onboarding_1.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Dapatkan tinggi layar untuk perhitungan posisi
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Warna background utama
      backgroundColor: const Color(0xFFE0F2F1),
      body: Stack(
        children: [
          // --- LAPISAN 1 (Belakang): PageView Gambar ---
          // Kita posisikan dia memenuhi layar, tapi kita akan atur paddingnya
          // agar gambarnya berada di bagian atas.
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (value) {
                setState(() {
                  _currentPage = value;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                // Gunakan Container untuk mengatur posisi gambar
                return Container(
                  // Beri padding atas agar tidak nabrak status bar
                  // padding: const EdgeInsets.only(top: 80, bottom: 250), 
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    _onboardingData[index]['icon'],
                    // Atur tinggi gambar relatif terhadap layar (misal 40%)
                    // height: screenHeight * 0.4, 
                    fit: BoxFit.fitWidth,
                  ),
                );
              },
            ),
          ),

          // --- LAPISAN 2 (Depan): Kartu Putih (Teks & Tombol) ---
          // Gunakan Align untuk menempelkannya di bagian bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              // Atur tinggi kartu putih (misal 45% dari tinggi layar)
              height: screenHeight * 0.35,
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
                padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Agar column hanya setinggi kontennya
                  children: [
                    // Judul
                    Text(
                      _onboardingData[_currentPage]['title'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3312),
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
                    
                    const Spacer(), // Spacer akan mendorong konten ke atas/bawah

                    // Indikator Slide (Titik-titik)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => _buildDot(index),
                      ),
                    ),

                    const SizedBox(height: 30), // Jarak antara dot dan tombol

                    // Tombol
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            Get.offAll(
                              () => const MainScreen(),
                              transition: Transition.fade,
                              duration: const Duration(milliseconds: 500),
                            );
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3E2723),
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
                            const Icon(Icons.arrow_forward, color: Colors.white),
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
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 25 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF4CAF50)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}