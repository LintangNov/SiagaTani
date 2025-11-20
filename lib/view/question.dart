import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // v8.2.2
import 'package:latlong2/latlong.dart'; // v0.9.1
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:siaga_tani/controllers/map_setup_controller.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();
  // Panggil controller map kita
  final MapSetupController _mapController = Get.put(MapSetupController());

  final Map<int, dynamic> _answers = {};
  int _currentPage = 0;

  // --- DATA PERTANYAAN ---
  final List<Map<String, dynamic>> _questions = [
    {
      "question": "Fase tanaman cabai Anda saat ini?",
      "type": "grid",
      "options": [
        {"label": "Bibit", "icon": "🌱"},
        {"label": "Vegetatif", "icon": "🌿"},
        {"label": "Berbunga", "icon": "🌼"},
        {"label": "Berbuah", "icon": "🌶️"},
      ],
    },
    {
      "question": "Varietas cabai apa yang Anda tanam?",
      "type": "grid",
      "options": [
        {"label": "Cabai Rawit", "icon": "⚡"},
        {"label": "Cabai Keriting", "icon": "〰️"},
        {"label": "Cabai Besar", "icon": "🔴"},
        {"label": "Lainnya", "icon": "❓"},
      ],
    },
    {
      "question": "Bagaimana pola tanam di lahan Anda?",
      "type": "list",
      "options": [
        {"label": "Monokultur", "sub": "Hanya satu jenis tanaman"},
        {"label": "Tumpangsari", "sub": "Diselingi tanaman lain"},
        {"label": "Polikultur", "sub": "Campuran banyak jenis"},
      ],
    },
    {
      "question": "Apakah lahan pernah terserang hama?",
      "type": "list",
      "options": [
        {"label": "Ya, Pernah", "sub": "Ada riwayat serangan"},
        {"label": "Tidak Pernah", "sub": "Lahan aman"},
        {"label": "Tidak Tahu", "sub": "Saya lupa"},
      ],
    },
    {
      "question": "Apakah Anda menggunakan Mulsa Plastik?",
      "type": "list",
      "options": [
        {"label": "Ya, Pakai", "sub": "Penutup tanah plastik"},
        {"label": "Tidak", "sub": "Tanah terbuka"},
      ],
    },

    // --- HALAMAN 6: LOKASI LAHAN UTAMA (GOJEK STYLE) ---
    {
      "question": "Tentukan titik lokasi lahan Anda",
      "type": "map_main",
      "desc": "Geser peta hingga pin merah berada tepat di lahan Anda.",
    },

    // --- HALAMAN 7: LOKASI PENDUKUNG (GENSHIN STYLE) ---
    {
      "question": "Ada tanaman apa di sekitar lahan?",
      "type": "map_surrounding",
      "desc":
          "Tap pada peta untuk menandai lahan tetangga. Tekan Lanjut jika tidak ada.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF2C3312);
    final accentColor = const Color(0xFF4CAF50);

    return Scaffold(
      body: Stack(
        children: [
          // PAGE VIEW CONTROLLER
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final q = _questions[index];

              // JIKA HALAMAN PETA
              if (q['type'] == 'map_main') {
                return _buildMapMainStep(q);
              } else if (q['type'] == 'map_surrounding') {
                return _buildMapSurroundingStep(q);
              }

              // JIKA HALAMAN KUESIONER BIASA
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(primaryColor, accentColor),
                      const SizedBox(height: 30),
                      Text(
                        q['question'],
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 30),

                      if (q['type'] == 'grid')
                        _buildGridOptions(q, index, accentColor)
                      else if (q['type'] == 'list')
                        _buildListOptions(q, index, accentColor),

                      const Spacer(),
                      _buildNextButton(primaryColor),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 🌍 WIDGET PETA 1: GOJEK STYLE ---
  Widget _buildMapMainStep(Map<String, dynamic> q) {
    return Stack(
      children: [
        Obx(
          () => FlutterMap(
            mapController: _mapController.mapController,
            options: MapOptions(
              initialCenter: _mapController.currentCenter.value,
              initialZoom: 15.0,
              // PERBAIKAN: Parameter callback mengikuti flutter_map v8.x
              onPositionChanged: _mapController.onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.siaga_tani',
              ),
            ],
          ),
        ),

        // PIN TENGAH (FIXED)
        const Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Icon(Icons.location_on, color: Colors.red, size: 50),
          ),
        ),

        // PANEL BAWAH
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lokasi Lahan Utama",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(q['desc'], style: GoogleFonts.poppins(color: Colors.grey)),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _mapController.saveMyFarmLocation();
                      _nextPage();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3312),
                    ),
                    child: Text(
                      "Konfirmasi Lokasi",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 🌍 WIDGET PETA 2: DATA PENDUKUNG ---
  Widget _buildMapSurroundingStep(Map<String, dynamic> q) {
    return Stack(
      children: [
        Obx(
          () => FlutterMap(
            options: MapOptions(
              initialCenter:
                  _mapController.myFarmLocation.value ??
                  const LatLng(-7.795, 110.369),
              initialZoom: 15.0,
              // v8.x onTap signature: (tapPos, latLng)
              onTap: (tapPos, latLng) {
                _mapController.addSurroundingPin(latLng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.siaga_tani',
              ),
              // LAYER MARKER (Pin Merah & Kuning)
              MarkerLayer(
                markers: [
                  // Pin Lahan Utama
                  if (_mapController.myFarmLocation.value != null)
                    Marker(
                      point: _mapController.myFarmLocation.value!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  // Pin Tanaman Sekitar (dari Controller)
                  ..._mapController.surroundingPins,
                ],
              ),
            ],
          ),
        ),

        // PANEL BAWAH
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Data Pendukung (Opsional)",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar(
                        "Sukses",
                        "Data Lahan & Lingkungan Tersimpan!",
                      );
                      Get.back(); // KEMBALI KE DASHBOARD
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                    child: Text(
                      "Selesai & Simpan",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildHeader(Color primary, Color accent) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primary),
          onPressed: () {
            if (_currentPage > 0)
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            else
              Get.back();
          },
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / _questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(accent),
            borderRadius: BorderRadius.circular(10),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _answers.containsKey(_currentPage) ? _nextPage : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: Colors.grey[400],
        ),
        child: Text(
          "Lanjut",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Render Grid untuk Pertanyaan Pilihan (Versi Perbaikan Layout)
  Widget _buildGridOptions(
    Map<String, dynamic> q,
    int index,
    Color activeColor,
  ) {
    return Expanded(
      child: GridView.builder(
        // Menggunakan BouncingScrollPhysics agar terasa premium,
        // tapi kalau itemnya sedikit dia tidak akan kemana-mana.
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 Kolom
          mainAxisSpacing: 15, // Jarak vertikal antar kotak
          crossAxisSpacing: 15, // Jarak horizontal antar kotak
          // PERBAIKAN UTAMA: Ubah rasio dari 1.3 ke 1.0 atau 1.1
          // Agar kotak lebih tinggi dan muat menampung Icon + Teks tanpa terpotong
          childAspectRatio: 1.1,
        ),
        itemCount: (q['options'] as List).length,
        itemBuilder: (context, i) {
          final opt = q['options'][i];
          bool isSelected = _answers[index] == opt['label'];

          return GestureDetector(
            onTap: () => setState(() => _answers[index] = opt['label']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              // PERBAIKAN: Tambah padding di dalam kotak agar teks tidak mepet pinggir
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.8),
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
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Besar
                  Text(
                    opt['icon'],
                    style: const TextStyle(
                      fontSize: 36,
                    ), // Sedikit diperbesar biar jelas
                  ),
                  const SizedBox(height: 12), // Jarak aman antara icon dan teks
                  // Teks Label
                  Text(
                    opt['label'],
                    textAlign: TextAlign.center, // Pastikan teks rata tengah
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: Colors.black87,
                    ),
                    maxLines: 2, // Izinkan 2 baris jika teks panjang
                    overflow:
                        TextOverflow.ellipsis, // Titik-titik jika kepanjangan
                  ),

                  // Opsional: Tambah icon centang jika dipilih biar makin jelas
                  if (isSelected) ...[
                    const SizedBox(height: 5),
                    Icon(Icons.check_circle, size: 18, color: activeColor),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Render List untuk Pertanyaan Pilihan Panjang (Sama kayak sebelumnya)
  Widget _buildListOptions(
    Map<String, dynamic> q,
    int index,
    Color activeColor,
  ) {
    return Expanded(
      child: ListView(
        children: (q['options'] as List).map((opt) {
          bool isSelected = _answers[index] == opt['label'];
          return GestureDetector(
            onTap: () => setState(() => _answers[index] = opt['label']),
            child: Container(
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
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opt['label'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          opt['sub'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
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
        }).toList(),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }
}
