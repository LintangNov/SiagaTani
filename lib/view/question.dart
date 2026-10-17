import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:siaga_tani/controllers/map_setup_controller.dart';
import 'package:siaga_tani/controllers/farm_controller.dart';
import '../core/theme/app_theme.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();

  final MapSetupController _mapController = Get.put(MapSetupController());
  final FarmController _farmController = Get.put(FarmController());

  int _currentPage = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      "key": "phase",
      "question": "Fase tanaman cabai Anda saat ini?",
      "type": "image_grid",
      "options": [
        {"label": "Bibit", "image": "assets/images/phase/bibit.png"},
        {"label": "Vegetatif", "image": "assets/images/phase/vegetatif.png"},
        {"label": "Berbunga", "image": "assets/images/phase/berbungaa.png"},
        {"label": "Berbuah", "image": "assets/images/phase/berbuah.png"},
        {"label": "Panen", "image": "assets/images/phase/berbuah_besar.png"},
      ],
    },
    {
      "key": "pattern",
      "question": "Bagaimana pola tanam di lahan Anda?",
      "type": "list",
      "options": [
        {"label": "Monokultur", "sub": "Hanya satu jenis tanaman"},
        {"label": "Tumpangsari", "sub": "Diselingi tanaman lain"},
        {"label": "Polikultur", "sub": "Campuran banyak jenis"},
      ],
    },
    {
      "key": "variety",
      "question": "Varietas cabai apa yang Anda tanam?",
      "type": "image_grid",
      "options": [
        {"label": "Cabai Rawit", "image": "assets/images/varietas/rawit.png"},
        {
          "label": "Cabai Keriting",
          "image": "assets/images/varietas/keriting.png",
        },
        {"label": "Cabai Besar", "image": "assets/images/varietas/besar.png"},
      ],
    },
    {
      "key": "history",
      "question": "Apakah lahan pernah terserang hama?",
      "type": "list",
      "options": [
        {"label": "Pernah", "sub": "Ada riwayat serangan"},
        {"label": "Tidak Pernah", "sub": "Lahan aman"},
        {"label": "Tidak Tahu", "sub": "Saya lupa"},
      ],
    },
    {
      "key": "mulch",
      "question": "Jenis mulsa apa yang Anda gunakan?",
      "type": "list",
      "options": [
        {"label": "Mulsa Perak", "sub": "Memantulkan cahaya"},
        {"label": "Mulsa Hitam", "sub": "Menjaga kehangatan"},
        {"label": "Tanpa Mulsa", "sub": "Tanah terbuka"},
      ],
    },
    {
      "key": "spray",
      "question": "Kapan terakhir kali Anda menyemprot pestisida?",
      "type": "list",
      "options": [
        {"label": "Baru saja (< 3 hari)", "sub": "Tanaman terlindungi"},
        {"label": "Seminggu lalu", "sub": "Efektivitas menurun"},
        {"label": "Belum Pernah", "sub": "Tidak ada proteksi"},
      ],
    },
    {
      "type": "map_main",
      "desc": "Geser peta hingga pin merah berada tepat di lahan Anda.",
    },
    {
      "type": "map_surrounding",
      "desc": "Tap peta untuk menandai tanaman di lahan tetangga.",
    },
    {
      "key": "name",
      "question": "Terakhir, beri nama lahan Anda",
      "type": "text",
      "hint": "Contoh: Lahan Cabai Belakang Rumah",
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _farmController.nameController.clear();
      _farmController.selectedPhase.value = "";
      _farmController.selectedVariety.value = "";
      _farmController.selectedPattern.value = "";
      _farmController.pestHistory.value = "";
      _farmController.mulchInput.value = "";
      _farmController.sprayInput.value = "";
      _mapController.myFarmLocation.value = null;
      _mapController.currentAddress.value = "Geser pin untuk lokasi...";
      _mapController.surroundingData.clear();
      _mapController.surroundingPins.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.foregroundPrimary;
    const accentColor = AppColors.accentPrimary;

    return Scaffold(
      backgroundColor: AppColors.surfacePrimary,
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
              if (q['type'] == 'map_surrounding') {
                return _buildMapSurroundingStep(q);
              }

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(primaryColor, accentColor),
                      const SizedBox(height: 15),
                      Text(
                        q['question'],
                        style: GoogleFonts.geist(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (q['type'] == 'image_grid')
                        _buildImageGridOptions(q, q['key'], accentColor)
                      else if (q['type'] == 'list')
                        _buildListOptions(q, q['key'], accentColor)
                      else if (q['type'] == 'text')
                        _buildTextInput(q, accentColor),
                      const SizedBox(height: 20),
                      _buildNextButton(accentColor, q['key']),
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

  Widget _buildImageGridOptions(
    Map<String, dynamic> q,
    String key,
    Color color,
  ) {
    return Expanded(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 0.90,
        ),
        itemCount: (q['options'] as List).length,
        itemBuilder: (ctx, i) {
          var opt = q['options'][i];

          return Obx(() {
            bool isSelected = _getValue(key) == opt['label'];
            return GestureDetector(
              onTap: () => _setValue(key, opt['label']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.cardBorder,
                  border: isSelected
                      ? Border.all(color: color, width: 2)
                      : Border.all(color: Colors.transparent, width: 0),
                  boxShadow: AppShadow.card,
                  image: DecorationImage(
                    image: AssetImage(opt['image']),
                    fit: BoxFit.cover,
                    colorFilter: isSelected
                        ? null
                        : const ColorFilter.mode(
                            Colors.white10,
                            BlendMode.darken,
                          ),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 80,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(AppRadius.card),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.white,
                            Color.fromARGB(228, 255, 255, 255),
                            Color.fromARGB(0, 255, 255, 255),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 15,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: color,
                                size: 18,
                              ),
                            ),
                          Flexible(
                            child: Text(
                              opt['label'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.foregroundPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildTextInput(Map<String, dynamic> q, Color activeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppRadius.inputBorder,
            border: Border.all(color: AppColors.borderStrong),
            boxShadow: AppShadow.card,
          ),
          child: TextField(
            controller: _farmController.nameController,
            onChanged: (val) => setState(() {}),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.foregroundPrimary,
            ),
            decoration: InputDecoration(
              hintText: q['hint'],
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.foregroundTertiary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
              prefixIcon: Icon(
                Icons.edit_location_alt_rounded,
                color: activeColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary.withValues(alpha: 0.35),
            borderRadius: AppRadius.inputBorder,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.aspect_ratio_rounded,
                color: AppColors.foregroundSecondary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Estimasi Luas Lahan",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.foregroundSecondary,
                    ),
                  ),
                  Text(
                    "1000 m²",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.foregroundPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListOptions(Map<String, dynamic> q, String key, Color color) {
    return Expanded(
      child: ListView.builder(
        itemCount: (q['options'] as List).length,
        itemBuilder: (ctx, i) {
          var opt = q['options'][i];
          return Obx(() {
            bool isSelected = _getValue(key) == opt['label'];
            return GestureDetector(
              onTap: () => _setValue(key, opt['label']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: AppRadius.cardBorder,
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: AppShadow.card,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt['label'],
                            style: GoogleFonts.inter(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.foregroundPrimary,
                            ),
                          ),
                          if (opt['sub'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                opt['sub'],
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.foregroundSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: color,
                        size: 22,
                      ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  String _getValue(String key) {
    switch (key) {
      case 'phase':
        return _farmController.selectedPhase.value;
      case 'variety':
        return _farmController.selectedVariety.value;
      case 'pattern':
        return _farmController.selectedPattern.value;
      case 'history':
        return _farmController.pestHistory.value;
      case 'mulch':
        return _farmController.mulchInput.value;
      case 'spray':
        return _farmController.sprayInput.value;
      default:
        return "";
    }
  }

  void _setValue(String key, String val) {
    switch (key) {
      case 'phase':
        _farmController.selectedPhase.value = val;
        break;
      case 'variety':
        _farmController.selectedVariety.value = val;
        break;
      case 'pattern':
        _farmController.selectedPattern.value = val;
        break;
      case 'history':
        _farmController.pestHistory.value = val;
        break;
      case 'mulch':
        _farmController.mulchInput.value = val;
        break;
      case 'spray':
        _farmController.sprayInput.value = val;
        break;
    }
  }

  Widget _buildNextButton(Color color, String? key) {
    bool isLastPage = _currentPage == _questions.length - 1;
    return SizedBox(
      width: double.infinity,
      height: AppSize.touch,
      child: Obx(() {
        bool isEnabled = false;
        if (key == 'name') {
          isEnabled = _farmController.nameController.text.isNotEmpty;
        } else if (key != null) {
          isEnabled = _getValue(key).isNotEmpty;
        }

        return ElevatedButton(
          onPressed: isEnabled
              ? (isLastPage ? () => _farmController.saveFarm() : _nextPage)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            disabledBackgroundColor: color.withValues(alpha: 0.35),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.buttonBorder,
            ),
          ),
          child: _farmController.isSaving.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  isLastPage ? "Selesai" : "Lanjut",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        );
      }),
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

  Widget _buildHeader(Color primary, Color accent) {
    return Row(
      children: [
        Material(
          color: AppColors.surfaceCard,
          shape: const CircleBorder(),
          elevation: 1.5,
          shadowColor: AppColors.shadow,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _currentPage > 0
                ? _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  )
                : Get.back(),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(Icons.arrow_back, size: 20, color: primary),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: (_currentPage + 1) / _questions.length,
              backgroundColor: AppColors.borderSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapMainStep(Map<String, dynamic> q) {
    return Stack(
      children: [
        Obx(
          () => FlutterMap(
            mapController: _mapController.mapController,
            options: MapOptions(
              initialCenter: _mapController.currentCenter.value,
              initialZoom: 16.0,
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
        const Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Icon(Icons.location_on, color: AppColors.danger, size: 50),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: AppRadius.sheetTop,
              boxShadow: AppShadow.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lokasi Lahan Utama",
                  style: GoogleFonts.geist(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.foregroundPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  if (_mapController.isLoadingAddress.value) {
                    return Row(
                      children: [
                        const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accentPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Mencari alamat...",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.foregroundSecondary,
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      const Icon(
                        Icons.map_rounded,
                        color: AppColors.accentPrimary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _mapController.currentAddress.value,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.foregroundPrimary,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: AppSize.touch,
                  child: ElevatedButton(
                    onPressed: () {
                      _mapController.saveMyFarmLocation(context);
                      _nextPage();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.buttonBorder,
                      ),
                    ),
                    child: Text(
                      "Konfirmasi Lokasi",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFloatingBackButton(),
      ],
    );
  }

  Widget _buildMapSurroundingStep(Map<String, dynamic> q) {
    return Stack(
      children: [
        Obx(
          () => FlutterMap(
            options: MapOptions(
              initialCenter:
                  _mapController.myFarmLocation.value ??
                  const LatLng(-7.795, 110.369),
              initialZoom: 16.0,
              onTap: (tapPos, latLng) =>
                  _mapController.addSurroundingPin(context, latLng),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.siaga_tani',
              ),
              MarkerLayer(
                markers: [
                  if (_mapController.myFarmLocation.value != null)
                    Marker(
                      point: _mapController.myFarmLocation.value!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.danger,
                        size: 50,
                      ),
                    ),
                  ..._mapController.surroundingPins,
                ],
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: AppRadius.sheetTop,
              boxShadow: AppShadow.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tanaman di Sekitar",
                  style: GoogleFonts.geist(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.foregroundPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tap peta untuk menandai sumber hama.",
                  style: GoogleFonts.inter(
                    color: AppColors.foregroundSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 15),
                Obx(
                  () => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _mapController.surroundingData
                        .asMap()
                        .entries
                        .map((entry) {
                          int idx = entry.key;
                          Map<String, dynamic> data = entry.value;
                          return Chip(
                            label: Text(data['type']),
                            backgroundColor:
                                AppColors.surfaceSecondary.withValues(alpha: 0.4),
                            avatar: const Icon(
                              Icons.grass_rounded,
                              size: 14,
                              color: AppColors.foregroundSecondary,
                            ),
                            labelStyle: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.foregroundPrimary,
                            ),
                            deleteIcon: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: AppColors.danger,
                            ),
                            onDeleted: () {
                              _mapController.surroundingData.removeAt(idx);
                              _mapController.surroundingPins.removeAt(idx);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                              side: const BorderSide(
                                color: AppColors.borderSubtle,
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: AppSize.touch,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.buttonBorder,
                      ),
                    ),
                    child: Text(
                      "Lanjut",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFloatingBackButton(),
      ],
    );
  }

  Widget _buildFloatingBackButton() {
    return Positioned(
      top: 50,
      left: 20,
      child: Material(
        color: AppColors.surfaceCard,
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: AppColors.shadow,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          ),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              Icons.arrow_back,
              color: AppColors.foregroundPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
