import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // v8.2.2
import 'package:latlong2/latlong.dart';      // v0.9.1
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:siaga_tani/controllers/map_setup_controller.dart';
import 'package:siaga_tani/controllers/farm_controller.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();
  
  // Panggil Controller
  final MapSetupController _mapController = Get.put(MapSetupController());
  final FarmController _farmController = Get.put(FarmController());
  
  int _currentPage = 0;

  // --- DATA PERTANYAAN ---
  final List<Map<String, dynamic>> _questions = [
    {
      "key": "phase",
      "question": "Fase tanaman cabai Anda saat ini?",
      "type": "grid",
      "options": [
        {"label": "Bibit", "icon": "🌱"},
        {"label": "Vegetatif", "icon": "🌿"},
        {"label": "Berbunga", "icon": "🌼"},
        {"label": "Berbuah Muda", "icon": "🌶️"},
      ]
    },
    {
      "key": "variety",
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
      "key": "pattern",
      "question": "Bagaimana pola tanam di lahan Anda?",
      "type": "list",
      "options": [
        {"label": "Monokultur", "sub": "Hanya satu jenis tanaman"},
        {"label": "Tumpangsari", "sub": "Diselingi tanaman lain"},
        {"label": "Polikultur", "sub": "Campuran banyak jenis"},
      ]
    },
    {
      "key": "history",
      "question": "Apakah lahan pernah terserang hama?",
      "type": "list",
      "options": [
        {"label": "Pernah", "sub": "Ada riwayat serangan"},
        {"label": "Tidak Pernah", "sub": "Lahan aman"},
        {"label": "Tidak Tahu", "sub": "Saya lupa"},
      ]
    },
    {
      "key": "mulch",
      "question": "Apakah Anda menggunakan Mulsa Plastik?",
      "type": "list",
      "options": [
        {"label": "Ya, Pakai", "sub": "Penutup tanah plastik"},
        {"label": "Tidak", "sub": "Tanah terbuka"},
      ]
    },
    {"type": "map_main", "desc": "Geser peta hingga pin merah berada tepat di lahan Anda."},
    {"type": "map_surrounding", "desc": "Tap peta untuk menandai tanaman di lahan tetangga."},
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF2C3312);
    final accentColor = const Color(0xFF4CAF50);

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final q = _questions[index];

              if (q['type'] == 'map_main') return _buildMapMainStep(q);
              if (q['type'] == 'map_surrounding') return _buildMapSurroundingStep(q);

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(primaryColor, accentColor),
                      const SizedBox(height: 30),
                      Text(q['question'], style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor)),
                      const SizedBox(height: 30),
                      
                      if (q['type'] == 'grid') _buildGridOptions(q, q['key'], accentColor)
                      else if (q['type'] == 'list') _buildListOptions(q, q['key'], accentColor),
                      
                      const SizedBox(height: 30),
                      _buildNextButton(primaryColor, q['key']),
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

  // --- FUNGSI CONTROLLER HELPER ---
  String _getValue(String key) {
    switch(key) {
      case 'phase': return _farmController.selectedPhase.value;
      case 'variety': return _farmController.selectedVariety.value;
      case 'pattern': return _farmController.selectedPattern.value;
      case 'history': return _farmController.pestHistory.value;
      case 'mulch': return _farmController.isMulchUsed.value;
      default: return "";
    }
  }

  void _setValue(String key, String val) {
    switch(key) {
      case 'phase': _farmController.selectedPhase.value = val; break;
      case 'variety': _farmController.selectedVariety.value = val; break;
      case 'pattern': _farmController.selectedPattern.value = val; break;
      case 'history': _farmController.pestHistory.value = val; break;
      case 'mulch': _farmController.isMulchUsed.value = val; break;
    }
  }

  // --- WIDGET GRID & LIST (YANG DIPERBAIKI) ---
  
  Widget _buildGridOptions(Map<String, dynamic> q, String key, Color color) {
    // HAPUS Obx() dari sini (Parent)
    return Expanded(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 10, bottom: 20, left: 4, right: 4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 1.0
        ),
        itemCount: (q['options'] as List).length,
        itemBuilder: (ctx, i) {
          var opt = q['options'][i];
          
          // PINDAHKAN Obx() KE SINI (Child Item)
          return Obx(() {
            bool isSelected = _getValue(key) == opt['label'];
            return GestureDetector(
              onTap: () => _setValue(key, opt['label']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                  border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,4))]
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(opt['icon'], style: const TextStyle(fontSize: 38)),
                  const SizedBox(height: 12),
                  Text(opt['label'], textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                  if(isSelected) ...[const SizedBox(height: 6), Icon(Icons.check_circle, size: 20, color: color)]
                ]),
              ),
            );
          });
        }
      ),
    );
  }

  Widget _buildListOptions(Map<String, dynamic> q, String key, Color color) {
     // HAPUS Obx() dari sini (Parent)
     return Expanded(
      child: ListView.builder( // Ganti jadi builder biar performa bagus
        itemCount: (q['options'] as List).length,
        itemBuilder: (ctx, i) {
          var opt = q['options'][i];
          
          // PINDAHKAN Obx() KE SINI (Child Item)
          return Obx(() {
            bool isSelected = _getValue(key) == opt['label'];
            return GestureDetector(
              onTap: () => _setValue(key, opt['label']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]
                ),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(opt['label'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    Text(opt['sub'], style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  ])),
                  if(isSelected) Icon(Icons.check_circle, color: color)
                ]),
              ),
            );
          });
        }
      ),
    );
  }

  Widget _buildNextButton(Color color, String key) {
    return SizedBox(
      width: double.infinity, height: 55,
      child: Obx(() => ElevatedButton(
        onPressed: _getValue(key).isNotEmpty ? _nextPage : null,
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), disabledBackgroundColor: Colors.grey[400]),
        child: Text("Lanjut", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
      )),
    );
  }

  // --- PETA (Tidak perlu diubah, sudah benar pakai Obx di dalam) ---
  
  Widget _buildMapMainStep(Map<String, dynamic> q) {
    return Stack(
      children: [
        Obx(() => FlutterMap(
          mapController: _mapController.mapController,
          options: MapOptions(
            initialCenter: _mapController.currentCenter.value, 
            initialZoom: 16.0,
            onPositionChanged: _mapController.onPositionChanged, 
          ),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.siaga_tani'),
          ],
        )),
        const Center(child: Padding(padding: EdgeInsets.only(bottom: 40), child: Icon(Icons.location_on, color: Colors.red, size: 50))),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lokasi Lahan Utama", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                Obx(() {
                  if (_mapController.isLoadingAddress.value) {
                    return Row(children: [const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 10), Text("Mencari alamat...", style: GoogleFonts.poppins(color: Colors.grey))]);
                  }
                  return Row(children: [const Icon(Icons.map, color: Colors.green, size: 18), const SizedBox(width: 8), Expanded(child: Text(_mapController.currentAddress.value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)))]);
                }),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () { _mapController.saveMyFarmLocation(); _nextPage(); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C3312)), child: Text("Konfirmasi Lokasi", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold))))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapSurroundingStep(Map<String, dynamic> q) {
    return Stack(
      children: [
        Obx(() => FlutterMap(
          options: MapOptions(
            initialCenter: _mapController.myFarmLocation.value ?? const LatLng(-7.795, 110.369),
            initialZoom: 16.0,
            onTap: (tapPos, latLng) => _mapController.addSurroundingPin(latLng), 
          ),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.siaga_tani'),
            MarkerLayer(markers: [
              if (_mapController.myFarmLocation.value != null) Marker(point: _mapController.myFarmLocation.value!, width: 50, height: 50, child: const Icon(Icons.location_on, color: Colors.red, size: 50)),
              ..._mapController.surroundingPins
            ]),
          ],
        )),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Data Pendukung (Opsional)", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 15),
                Obx(() => Wrap(spacing: 8, children: _mapController.surroundingData.map((data) => Chip(label: Text(data['type']), backgroundColor: Colors.orange[50], avatar: const Icon(Icons.grass, size: 14, color: Colors.orange), labelStyle: const TextStyle(fontSize: 12))).toList())),
                const SizedBox(height: 15),
                SizedBox(width: double.infinity, height: 50, child: Obx(() => ElevatedButton(onPressed: _farmController.isSaving.value ? null : () => _farmController.saveFarm(), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)), child: _farmController.isSaving.value ? const CircularProgressIndicator(color: Colors.white) : Text("Selesai & Analisis", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)))))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Color primary, Color accent) {
    return Row(children: [
      IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: primary), onPressed: () => _currentPage > 0 ? _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease) : Get.back()),
      Expanded(child: LinearProgressIndicator(value: (_currentPage + 1) / _questions.length, backgroundColor: Colors.grey[300], valueColor: AlwaysStoppedAnimation<Color>(accent), borderRadius: BorderRadius.circular(10), minHeight: 6)),
    ]);
  }

  void _nextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }
}