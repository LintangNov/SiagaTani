import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/app_theme.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/sheet_container.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _selectedCategory = 'Semua';
  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _articles = const [
    {
      'title': 'Waspada! Cuaca Panas Picu Ledakan Hama Kutu Kebul',
      'category': 'Info Hama',
      'date': '25 Nov 2025',
      'image':
          'https://images.unsplash.com/photo-1591035897819-f4bdf739f446?auto=format&fit=crop&w=600&q=80',
      'content':
          'Cuaca panas terik dan kelembapan rendah sering memicu perkembangbiakan kutu kebul secara pesat.\n\n'
          'Gejala & Pencegahan:\n'
          '1. Periksa bagian bawah daun muda cabai, cari keberadaan serbuk putih berterbangan.\n'
          '2. Pasang perangkap lekat kuning di sekitar bedengan setiap jarak 5 meter.\n'
          '3. Semprotkan insektisida nabati atau bahan aktif abamektin pada sore hari.\n'
          '4. Jaga kebersihan lahan dari tanaman inang liar seperti babadotan.',
    },
    {
      'title': 'Cara Membuat Pestisida Nabati dari Daun Pepaya & Tembakau',
      'category': 'Tips Tani',
      'date': '20 Nov 2025',
      'image':
          'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?auto=format&fit=crop&w=600&q=80',
      'content':
          'Pestisida nabati ramah lingkungan sangat efektif menekan populasi ulat grayak dan kutu daun:\n\n'
          'Bahan & Cara Pembuatan:\n'
          '1. Tumbuk halus 1 kg daun pepaya segar dan 100 gram tembakau.\n'
          '2. Rendam dalam 10 liter air dan tambahkan 1 sendok detergen cair sebagai perekat.\n'
          '3. Diamkan selama 24 jam di tempat teduh, kemudian saring larutan.\n'
          '4. Larutkan 1 gelas larutan pekat ke dalam 1 tangki semprot (14 liter), lalu aplikasikan ke tanaman.',
    },
    {
      'title': 'Mengenal Gejala Serangan Antraknosa (Patek) pada Buah',
      'category': 'Penyakit',
      'date': '18 Nov 2025',
      'image':
          'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=600&q=80',
      'content':
          'Antraknosa disebabkan oleh jamur Colletotrichum yang menyerang saat kelembapan udara tinggi:\n\n'
          'Ciri & Penanganan:\n'
          '1. Gejala awal berupa bercak melingkar cekung kehitaman pada buah cabai matang.\n'
          '2. Petik dan buang buah yang terkena patek jauh dari area lahan.\n'
          '3. Kurangi pemupukan nitrogen berlebih di musim penghujan, perbanyak unsur kalsium dan kalium.\n'
          '4. Aplikasikan fungisida berbahan aktif tembaga hidroksida atau mankozeb secara rutin.',
    },
    {
      'title': 'Panduan Pemasangan Mulsa Plastik Hitam Perak untuk Cabai',
      'category': 'Tips Tani',
      'date': '15 Nov 2025',
      'image':
          'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=600&q=80',
      'content':
          'Pemasangan mulsa MPHP secara tepat memaksimalkan pertumbuhan vegetatif cabai:\n\n'
          'Langkah Praktis:\n'
          '1. Pasang mulsa saat matahari terik agar plastik memuai dan lentur ditarik kencang.\n'
          '2. Kunci tepi mulsa menggunakan pasak bambu berbentuk U pada jarak 50 cm.\n'
          '3. Buat lubang tanam dengan pelubang arang panas dengan jarak tanam 50 x 60 cm.\n'
          '4. Pantulan perak menghalau hama serangga dan menjaga suhu perakaran tetap stabil.',
    },
  ];

  static const Map<String, String> _headlineArticle = {
    'title': 'Subsidi Pupuk & Pola Tanam Berimbang Menghadapi Cuaca Ekstrem',
    'badge': 'ARTIKEL PILIHAN',
    'category': 'Tips Tani',
    'date': '26 Nov 2025',
    'image':
        'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&w=800&q=80',
    'content':
        'Menghadapi anomali cuaca hujan dan panas ekstrem, pemupukan berimbang sangat menentukan daya tahan tanaman cabai:\n\n'
        '1. Kombinasikan pupuk organik matang (kompos/kohe) sebagai pupuk dasar sebelum bedengan ditutup mulsa.\n'
        '2. Berikan pupuk kalsium berkala untuk memperkuat dinding sel tanaman sehingga tidak mudah pecah terserang antraknosa.\n'
        '3. Pastikan saluran drainase berfungsi optimal agar perakaran tidak terendam lebih dari 2 jam.',
  };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, String>> _filteredArticles() {
    return _articles.where((item) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          item['category']!.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty ||
          item['title']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredArticles();

    return Scaffold(
      backgroundColor: AppColors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: AppColors.surfacePrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: AppSpace.screen,
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                style: AppText.body(
                  size: 14,
                  color: AppColors.foregroundPrimary,
                  // height: ,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari artikel edukasi...',
                  hintStyle: AppText.body(
                    size: 14,
                    color: AppColors.foregroundTertiary,
                    height: 1.3,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                ),
              )
            : Text(
                'Pojok Tani',
                style: AppText.heading(
                  size: 22,
                  weight: FontWeight.w700,
                  color: AppColors.foregroundPrimary,
                ),
              ),
        actions: [
          // Tombol search/close — lingkar putih kompak
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.screen),
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 1.5,
              shadowColor: AppColors.shadow,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  setState(() {
                    if (_isSearching) {
                      _isSearching = false;
                      _searchCtrl.clear();
                      _searchQuery = '';
                    } else {
                      _isSearching = true;
                    }
                  });
                },
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    size: 20,
                    color: AppColors.foregroundPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Headline Card (Margin horizontal 24 sama seperti dashboard) ──
            if (!_isSearching && _selectedCategory == 'Semua')
              _buildHeadline(_headlineArticle),

            const SizedBox(height: 12),

            // ── Horizontal Chips Kategori (Padding horizontal 24) ────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
              child: Row(
                children: [
                  _buildCategoryChip('Semua'),
                  _buildCategoryChip('Info Hama'),
                  _buildCategoryChip('Tips Tani'),
                  _buildCategoryChip('Penyakit'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Judul Bagian "Terbaru Hari Ini" (Padding horizontal 24) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
              child: Text(
                'Terbaru Hari Ini',
                style: AppText.heading(
                  size: 17,
                  weight: FontWeight.w700,
                  color: AppColors.foregroundPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Daftar Kartu Berita / Artikel (Padding horizontal 24) ──
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screen,
                  vertical: 32,
                ),
                child: Center(
                  child: Text(
                    'Tidak ada artikel yang cocok.',
                    style: AppText.body(
                      size: 14,
                      color: AppColors.foregroundSecondary,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screen,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return _buildNewsCard(list[index]);
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Kartu Headline Bergambar (Margin horizontal 24) ─────────────
  Widget _buildHeadline(Map<String, String> item) {
    return GestureDetector(
      onTap: () => _openArticleDetail(item),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpace.screen,
          vertical: 4,
        ),
        height: 168,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: AppRadius.cardBorder,
          image: DecorationImage(
            image: NetworkImage(item['image']!),
            fit: BoxFit.cover,
          ),
          boxShadow: AppShadow.card,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardBorder,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                const Color(0xFF1B3A28).withValues(alpha: 0.9),
              ],
            ),
          ),
          padding: const EdgeInsets.all(14),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary,
                  borderRadius: AppRadius.cardBorder,
                ),
                child: Text(
                  item['badge'] ?? 'ARTIKEL PILIHAN',
                  style: AppText.body(
                    size: 10,
                    weight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item['title']!,
                style: AppText.heading(
                  size: 18,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Category Chip ──────────────────────────────────────────────
  Widget _buildCategoryChip(String label) {
    final bool isActive = _selectedCategory == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentPrimary : Colors.white,
          borderRadius: AppRadius.cardBorder,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppText.body(
            size: 12,
            weight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.foregroundPrimary,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  // ── Kartu Berita / Artikel (80x80 thumbnail kiri) ───────────────
  Widget _buildNewsCard(Map<String, String> article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.cardBorder,
        boxShadow: AppShadow.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openArticleDetail(article),
          splashColor: AppColors.accentPrimary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    article['image']!,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 76,
                      height: 76,
                      color: AppColors.surfaceSecondary,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.foregroundSecondary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article['category']!,
                        style: AppText.body(
                          size: 12,
                          weight: FontWeight.w700,
                          color: AppColors.accentSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        article['title']!,
                        style: AppText.heading(
                          size: 15,
                          weight: FontWeight.w600,
                          color: AppColors.foregroundPrimary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: AppColors.foregroundTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            article['date']!,
                            style: AppText.body(
                              size: 11,
                              color: AppColors.foregroundTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Modal Lembar Baca Detail Artikel ───────────────────────────
  void _openArticleDetail(Map<String, String> item) {
    Get.bottomSheet(
      SheetContainer(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: AppRadius.cardBorder,
                    ),
                    child: Text(
                      item['category'] ?? 'Artikel',
                      style: AppText.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.foregroundPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.foregroundPrimary,
                      size: 22,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item['title']!,
                style: AppText.heading(
                  size: 18,
                  weight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              if (item['date'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  item['date']!,
                  style: AppText.body(
                    size: 12,
                    color: AppColors.foregroundTertiary,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                item['content'] ?? '',
                style: AppText.body(
                  size: 14,
                  color: AppColors.foregroundSecondary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),
              AppButton.secondary(label: 'Tutup', onPressed: () => Get.back()),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
