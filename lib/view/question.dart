import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();
  
  // Menyimpan jawaban user. Key: index halaman, Value: data jawaban
  final Map<int, dynamic> _answers = {};
  
  int _currentPage = 0;

  // --- DATA PERTANYAAN ---
  final List<Map<String, dynamic>> _questions = [
    {
      "question": "Fase tanaman cabai Anda saat ini?",
      "type": "grid", // Tampilan kotak-kotak (seperti bendera di referensi)
      "options": [
        {"label": "Bibit", "icon": "🌱"},
        {"label": "Vegetatif", "icon": "🌿"},
        {"label": "Berbunga", "icon": "🌼"},
        {"label": "Berbuah Muda", "icon": "🌶️"},
        {"label": "Berbuah Matang", "icon": "🔥"},
      ]
    },
    {
      "question": "Varietas cabai apa yang Anda tanam?",
      "type": "grid",
      "options": [
        {"label": "Cabai Rawit", "icon": "⚡"},
        {"label": "Cabai Keriting", "icon": "〰️"},
        {"label": "Cabai Besar", "icon": "🔴"},
        {"label": "Lainnya", "icon": "❓"},
      ]
    },
    {
      "question": "Bagaimana pola tanam di lahan Anda?",
      "type": "list", // Tampilan list memanjang ke bawah (seperti level di referensi)
      "options": [
        {"label": "Monokultur", "sub": "Hanya satu jenis tanaman (cabai saja)"},
        {"label": "Tumpangsari", "sub": "Cabai diselingi tanaman lain"},
        {"label": "Polikultur", "sub": "Campuran banyak jenis tanaman"},
      ]
    },
    {
      "question": "Apakah lahan pernah terserang hama?",
      "type": "list",
      "options": [
        {"label": "Ya, Pernah", "sub": "Ada riwayat serangan sebelumnya"},
        {"label": "Tidak Pernah", "sub": "Lahan aman / lahan baru"},
        {"label": "Tidak Tahu", "sub": "Saya lupa / belum tahu"},
      ]
    },
    {
      "question": "Apakah Anda menggunakan Mulsa Plastik?",
      "type": "list",
      "options": [
        {"label": "Ya, Pakai", "sub": "Menggunakan penutup tanah plastik"},
        {"label": "Tidak", "sub": "Tanah terbuka tanpa mulsa"},
      ]
    },
    // --- PERTANYAAN TERAKHIR: LOKASI (GPS) ---
    {
      "question": "Terakhir, di mana lokasi lahan Anda?",
      "type": "location", // Tipe khusus untuk tombol GPS
      "options": [] 
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Warna Tema
    final primaryColor = const Color(0xFF2C3312); // Hijau tua gelap
    final accentColor = const Color(0xFF4CAF50); // Hijau cerah
    final bgColor = const Color(0xFFF1F8E9); // Hijau sangat muda (background)

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
          onPressed: () {
            if (_currentPage > 0) {
              _pageController.previousPage(
                  duration: const Duration(milliseconds: 300), curve: Curves.ease);
            } else {
              Get.back();
            }
          },
        ),
        title: LinearProgressIndicator(
          value: (_currentPage + 1) / _questions.length,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          borderRadius: BorderRadius.circular(10),
          minHeight: 6,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // User harus pilih dulu baru bisa geser
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pertanyaan
                        Text(
                          q['question'],
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Render Pilihan Sesuai Tipe
                        if (q['type'] == 'grid')
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15,
                              childAspectRatio: 1.3,
                              children: (q['options'] as List).map((opt) {
                                return _buildGridOption(
                                  opt['label'], 
                                  opt['icon'], 
                                  index, 
                                  accentColor
                                );
                              }).toList(),
                            ),
                          )
                        else if (q['type'] == 'list')
                          Expanded(
                            child: ListView(
                              children: (q['options'] as List).map((opt) {
                                return _buildListOption(
                                  opt['label'], 
                                  opt['sub'], 
                                  index, 
                                  accentColor
                                );
                              }).toList(),
                            ),
                          )
                        else if (q['type'] == 'location')
                          _buildLocationInput(accentColor),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Tombol Lanjut (Hanya muncul jika halaman terakhir / GPS)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled() ? _nextPage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: Colors.grey[400],
                  ),
                  child: Text(
                    _currentPage == _questions.length - 1 
                        ? "Selesai & Masuk Dashboard" 
                        : "Lanjut",
                    style: GoogleFonts.poppins(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600, 
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  // 1. Tampilan Kotak (Seperti bendera di referensi)
  Widget _buildGridOption(String label, String icon, int pageIndex, Color activeColor) {
    bool isSelected = _answers[pageIndex] == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _answers[pageIndex] = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
            if (isSelected)
              // Icon centang kecil di pojok (opsional)
              Transform.translate(
                offset: const Offset(0, 5),
                child: Icon(Icons.check_circle, color: activeColor, size: 16),
              )
          ],
        ),
      ),
    );
  }

  // 2. Tampilan List Memanjang (Seperti level di referensi)
  Widget _buildListOption(String label, String sub, int pageIndex, Color activeColor) {
    bool isSelected = _answers[pageIndex] == label;
    return GestureDetector(
      onTap: () => setState(() => _answers[pageIndex] = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: const [
             BoxShadow(
              color: Colors.black12, 
              blurRadius: 6, 
              offset: Offset(0, 2)
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: activeColor)
            else
              Icon(Icons.circle_outlined, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  // 3. Tampilan Khusus GPS (Halaman Terakhir)
  Widget _buildLocationInput(Color activeColor) {
    bool hasLocation = _answers[_currentPage] != null;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            "Kami butuh lokasi lahan untuk\nmemprediksi cuaca.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          
          // Tombol Ambil GPS
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () async {
                // Simulasi Ambil GPS (Nanti pasang logic Geolocator di sini)
                await Future.delayed(const Duration(seconds: 1));
                setState(() {
                  _answers[_currentPage] = "Lat: -7.795, Long: 110.369"; // Dummy
                });
                Get.snackbar("Sukses", "Lokasi berhasil ditemukan!", 
                  backgroundColor: activeColor.withOpacity(0.8), colorText: Colors.white);
              },
              icon: const Icon(Icons.my_location),
              label: Text(hasLocation ? "Perbarui Lokasi" : "Gunakan GPS Saat Ini"),
              style: OutlinedButton.styleFrom(
                foregroundColor: activeColor,
                side: BorderSide(color: activeColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          
          if (hasLocation) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    "Lokasi tersimpan: Yogyakarta",
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  // --- LOGIC ---

  bool _isButtonEnabled() {
    // Tombol 'Lanjut' hanya aktif kalau halaman ini sudah dijawab
    // Kecuali halaman GPS, tombol 'Lanjut' berubah jadi 'Selesai' dan wajib ada lokasi
    return _answers.containsKey(_currentPage);
  }

  void _nextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeIn
      );
    } else {
      // FINISH
      print("Semua Jawaban: $_answers");
      // Simpan ke controller/database, lalu:
      // Get.offAllNamed('/dashboard'); 
      Get.snackbar("Selesai", "Setup lahan berhasil!");
    }
  }
}