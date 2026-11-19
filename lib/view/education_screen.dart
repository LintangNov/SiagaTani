import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme.dart';
import '../data/services/news_service.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/sheet_container.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  static const _categories = [
    'Semua',
    'Info Hama',
    'Penyakit',
    'Harga',
    'Budidaya',
    'Panduan',
  ];

  final NewsService _newsService = NewsService();
  final TextEditingController _searchCtrl = TextEditingController();

  String _selectedCategory = 'Semua';
  bool _isSearching = false;
  String _searchQuery = '';

  List<NewsArticle> _news = const [];
  bool _newsLoading = true;
  bool _newsFailed = false;

  /// Panduan bawaan: tetap tersedia tanpa internet.
  static const List<NewsArticle> _guides = [
    NewsArticle(
      title: 'Waspada Kutu Kebul Saat Cuaca Panas',
      category: 'Panduan',
      source: 'Tim SiagaTani',
      icon: Icons.menu_book_outlined,
      content:
          'Cuaca panas dan kering mempercepat perkembangbiakan kutu kebul. Kutu ini juga menularkan virus kuning.\n\n'
          'Gejala & Pencegahan:\n'
          '1. Periksa bagian bawah daun muda cabai, cari serangga putih kecil yang beterbangan.\n'
          '2. Pasang perangkap lekat kuning di sekitar bedengan setiap jarak 5 meter.\n'
          '3. Semprotkan insektisida nabati atau bahan aktif abamektin pada sore hari.\n'
          '4. Jaga kebersihan lahan dari tanaman inang liar seperti babadotan.',
    ),
    NewsArticle(
      title: 'Membuat Pestisida Nabati dari Daun Pepaya & Tembakau',
      category: 'Panduan',
      source: 'Tim SiagaTani',
      icon: Icons.menu_book_outlined,
      content:
          'Pestisida nabati ramah lingkungan dapat membantu menekan ulat grayak dan kutu daun.\n\n'
          'Bahan & Cara Pembuatan:\n'
          '1. Tumbuk halus 1 kg daun pepaya segar dan 100 gram tembakau.\n'
          '2. Rendam dalam 10 liter air dan tambahkan 1 sendok detergen cair sebagai perekat.\n'
          '3. Diamkan selama 24 jam di tempat teduh, kemudian saring larutan.\n'
          '4. Larutkan 1 gelas larutan pekat ke dalam 1 tangki semprot (14 liter), lalu aplikasikan ke tanaman.',
    ),
    NewsArticle(
      title: 'Mengenal Gejala Antraknosa (Patek) pada Buah',
      category: 'Panduan',
      source: 'Tim SiagaTani',
      icon: Icons.menu_book_outlined,
      content:
          'Antraknosa disebabkan jamur Colletotrichum yang menyerang saat daun dan buah lama basah. Sporanya menyebar lewat percikan air hujan.\n\n'
          'Ciri & Penanganan:\n'
          '1. Gejala awal berupa bercak melingkar cekung kehitaman pada buah cabai.\n'
          '2. Petik dan buang buah yang terkena patek jauh dari area lahan.\n'
          '3. Kurangi pemupukan nitrogen berlebih di musim hujan, perbanyak unsur kalsium dan kalium.\n'
          '4. Aplikasikan fungisida berbahan aktif tembaga hidroksida atau mankozeb sebelum hujan.',
    ),
    NewsArticle(
      title: 'Memasang Mulsa Plastik Hitam Perak untuk Cabai',
      category: 'Panduan',
      source: 'Tim SiagaTani',
      icon: Icons.menu_book_outlined,
      content:
          'Pemasangan mulsa hitam perak yang tepat membantu pertumbuhan cabai dan mengurangi hama.\n\n'
          'Langkah Praktis:\n'
          '1. Pasang mulsa saat matahari terik agar plastik memuai dan bisa ditarik kencang.\n'
          '2. Kunci tepi mulsa menggunakan pasak bambu berbentuk U pada jarak 50 cm.\n'
          '3. Buat lubang tanam dengan jarak tanam 50 x 60 cm.\n'
          '4. Sisi perak menghadap ke atas. Pantulannya membingungkan Thrips dan kutu kebul.',
    ),
    NewsArticle(
      title: 'Pemupukan Berimbang Menghadapi Cuaca Ekstrem',
      category: 'Panduan',
      source: 'Tim SiagaTani',
      icon: Icons.menu_book_outlined,
      content:
          'Saat cuaca berganti-ganti antara hujan dan panas ekstrem, pemupukan berimbang menentukan daya tahan tanaman cabai:\n\n'
          '1. Gunakan pupuk organik matang (kompos/kohe) sebagai pupuk dasar sebelum bedengan ditutup mulsa.\n'
          '2. Berikan pupuk kalsium berkala untuk memperkuat dinding sel buah sehingga tidak mudah terserang antraknosa.\n'
          '3. Pastikan saluran drainase berfungsi agar perakaran tidak terendam lebih dari 2 jam.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadNews({bool force = false}) async {
    setState(() {
      _newsLoading = true;
      _newsFailed = false;
    });
    try {
      final items = await _newsService.fetchChiliNews(force: force);
      if (!mounted) return;
      setState(() => _news = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _newsFailed = true);
    } finally {
      if (mounted) setState(() => _newsLoading = false);
    }
  }

  List<NewsArticle> _filtered() {
    final all = [..._news, ..._guides];
    final q = _searchQuery.toLowerCase();
    return all.where((item) {
      final matchesCategory =
          _selectedCategory == 'Semua' || item.category == _selectedCategory;
      final matchesSearch = q.isEmpty || item.title.toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered();
    final showHeadline = !_isSearching && _selectedCategory == 'Semua';
    final headline = showHeadline && list.isNotEmpty ? list.first : null;
    final rest = headline == null ? list : list.skip(1).toList();

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
                ),
                decoration: InputDecoration(
                  hintText: 'Cari berita atau panduan...',
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
      body: RefreshIndicator(
        color: AppColors.accentPrimary,
        onRefresh: () => _loadNews(force: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (headline != null) _buildHeadline(headline),

              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screen,
                ),
                child: Row(
                  children: [for (final c in _categories) _buildCategoryChip(c)],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screen,
                ),
                child: Text(
                  _selectedCategory == 'Panduan'
                      ? 'Panduan Budidaya'
                      : 'Berita Cabai Terkini',
                  style: AppText.heading(
                    size: 17,
                    weight: FontWeight.w700,
                    color: AppColors.foregroundPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (_selectedCategory != 'Panduan') _buildNewsStatus(),

              if (rest.isEmpty && !_newsLoading)
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
                  itemCount: rest.length,
                  itemBuilder: (context, index) => _buildNewsCard(rest[index]),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Baris status pemuatan berita (memuat / gagal). Panduan tetap tampil.
  Widget _buildNewsStatus() {
    if (_newsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.accentPrimary,
            ),
          ),
        ),
      );
    }
    if (!_newsFailed) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpace.screen,
        0,
        AppSpace.screen,
        12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: AppRadius.cardBorder,
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Berita belum bisa dimuat. Panduan di bawah tetap bisa dibaca.',
              style: AppText.body(size: 12, color: AppColors.warning),
            ),
          ),
          TextButton(
            onPressed: () => _loadNews(force: true),
            child: Text(
              'Coba lagi',
              style: AppText.body(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime? d) {
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return DateFormat('d MMM yyyy', 'id_ID').format(d);
  }

  String _metaLabel(NewsArticle a) {
    final date = _dateLabel(a.date);
    return date.isEmpty ? a.source : '${a.source} · $date';
  }

  // ── Kartu Headline ─────────────────────────────────────────────
  Widget _buildHeadline(NewsArticle item) {
    return GestureDetector(
      onTap: () => _openArticle(item),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpace.screen,
          vertical: 4,
        ),
        constraints: const BoxConstraints(minHeight: 150),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: AppRadius.cardBorder,
          gradient: AppColors.mainCardGradient,
          boxShadow: AppShadow.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: AppRadius.cardBorder,
                  ),
                  child: Text(
                    item.isGuide ? 'PANDUAN PILIHAN' : 'BERITA TERBARU',
                    style: AppText.body(
                      size: 10,
                      weight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(item.icon, color: Colors.white70, size: 22),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              item.title,
              style: AppText.heading(
                size: 18,
                weight: FontWeight.w700,
                color: Colors.white,
                height: 1.25,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              _metaLabel(item),
              style: AppText.body(size: 12, color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Category Chip ──────────────────────────────────────────────
  Widget _buildCategoryChip(String label) {
    final bool isActive = _selectedCategory == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
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

  // ── Kartu Berita / Panduan ─────────────────────────────────────
  Widget _buildNewsCard(NewsArticle article) {
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
          onTap: () => _openArticle(article),
          splashColor: AppColors.accentPrimary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    article.icon,
                    color: AppColors.accentPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.category,
                        style: AppText.body(
                          size: 12,
                          weight: FontWeight.w700,
                          color: AppColors.accentSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        article.title,
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
                      Text(
                        _metaLabel(article),
                        style: AppText.body(
                          size: 11,
                          color: AppColors.foregroundTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  // ── Detail ─────────────────────────────────────────────────────
  void _openArticle(NewsArticle item) {
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
                      item.category,
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
                item.title,
                style: AppText.heading(
                  size: 18,
                  weight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _metaLabel(item),
                style: AppText.body(
                  size: 12,
                  color: AppColors.foregroundTertiary,
                ),
              ),
              const SizedBox(height: 14),
              if (item.content != null)
                Text(
                  item.content!,
                  style: AppText.body(
                    size: 14,
                    color: AppColors.foregroundSecondary,
                    height: 1.55,
                  ),
                )
              else
                Text(
                  'Berita ini berasal dari ${item.source}. Buka situs aslinya untuk membaca selengkapnya.',
                  style: AppText.body(
                    size: 14,
                    color: AppColors.foregroundSecondary,
                    height: 1.55,
                  ),
                ),
              const SizedBox(height: 20),
              if (item.url != null) ...[
                AppButton(
                  label: 'Baca di ${item.source}',
                  onPressed: () => _openUrl(item.url!),
                ),
                const SizedBox(height: 10),
              ],
              AppButton.secondary(label: 'Tutup', onPressed: () => Get.back()),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _openUrl(String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok) {
      Get.snackbar('Gagal membuka', 'Tautan berita tidak dapat dibuka.');
    }
  }
}
