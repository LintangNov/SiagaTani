import 'dart:io' show HttpDate;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

/// Satu entri di Pojok Tani: berita dari internet atau panduan bawaan.
class NewsArticle {
  final String title;
  final String category;
  final String source;
  final DateTime? date;
  final String? url; // berita: tautan ke situs asli
  final String? content; // panduan: isi lengkap
  final IconData icon;

  const NewsArticle({
    required this.title,
    required this.category,
    required this.source,
    required this.icon,
    this.date,
    this.url,
    this.content,
  });

  bool get isGuide => url == null;
}

/// Berita khusus cabai dari Google News RSS (gratis, tanpa API key).
///
/// Dua kueri digabung: (1) hama & penyakit cabai 90 hari terakhir, karena
/// beritanya jarang dan tenggelam oleh berita harga; (2) berita cabai umum
/// 30 hari terakhir. Judul disaring lagi agar hanya berita yang benar-benar
/// menyebut cabai/cabe yang tampil, dan berita harga dibatasi jumlahnya.
class NewsService {
  static const Duration _cacheTtl = Duration(minutes: 30);
  static const int _maxPriceNews = 15;
  static const List<String> _queries = [
    'cabai (hama OR penyakit OR OPT OR antraknosa OR patek OR thrips OR "kutu kebul" OR "virus kuning" OR "lalat buah") when:90d',
    'cabai (petani OR panen OR budidaya OR tanam OR harga) when:30d',
  ];

  /// Sisa nama situs/URL di akhir judul, misalnya " - https://media.id/".
  static final RegExp _trailingSite = RegExp(
    r'\s-\s(https?://\S+|[\w.-]+\.(com|id|net|co\.id|org))$',
    caseSensitive: false,
  );

  static List<NewsArticle>? _cache;
  static DateTime? _cachedAt;

  Future<List<NewsArticle>> fetchChiliNews({bool force = false}) async {
    if (!force &&
        _cache != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheTtl) {
      return _cache!;
    }

    final bodies = await Future.wait(_queries.map(_fetchFeed));
    final ok = bodies.whereType<String>().toList();
    if (ok.isEmpty) throw Exception('Gagal memuat berita');

    final seen = <String>{};
    final all = <NewsArticle>[];
    for (final body in ok) {
      all.addAll(_parse(body, seen));
    }
    all.sort((a, b) {
      final da = a.date ?? DateTime(2000);
      final db = b.date ?? DateTime(2000);
      return db.compareTo(da);
    });

    var priceCount = 0;
    final items = all.where((a) {
      if (a.category != 'Harga') return true;
      return ++priceCount <= _maxPriceNews;
    }).toList();

    _cache = items;
    _cachedAt = DateTime.now();
    return items;
  }

  /// Mengembalikan isi RSS, atau null bila gagal (kueri lain tetap dipakai).
  Future<String?> _fetchFeed(String query) async {
    final url = Uri.https('news.google.com', '/rss/search', {
      'q': query,
      'hl': 'id',
      'gl': 'ID',
      'ceid': 'ID:id',
    });
    try {
      final res = await http.get(url).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) return res.body;
      debugPrint('NewsService status ${res.statusCode}');
    } catch (e) {
      debugPrint('NewsService error: $e');
    }
    return null;
  }

  List<NewsArticle> _parse(String body, Set<String> seen) {
    final doc = XmlDocument.parse(body);
    final result = <NewsArticle>[];

    for (final item in doc.findAllElements('item')) {
      final rawTitle = item.getElement('title')?.innerText.trim() ?? '';
      final link = item.getElement('link')?.innerText.trim() ?? '';
      final source = item.getElement('source')?.innerText.trim() ?? '';
      if (rawTitle.isEmpty || link.isEmpty) continue;

      // Google News selalu menambahkan " - Nama Media" (kadang URL) di akhir.
      var title = rawTitle;
      if (source.isNotEmpty && title.endsWith(' - $source')) {
        title = title.substring(0, title.length - source.length - 3);
      } else {
        final cut = title.lastIndexOf(' - ');
        if (cut > 0) title = title.substring(0, cut);
      }
      title = title.replaceFirst(_trailingSite, '').trim();

      final lower = title.toLowerCase();
      if (!lower.contains('cabai') && !lower.contains('cabe')) continue;
      if (!seen.add(lower)) continue;

      final (category, icon) = _categorize(lower);
      result.add(
        NewsArticle(
          title: title,
          category: category,
          source: source.isEmpty ? 'Google News' : source,
          date: _parseDate(item.getElement('pubDate')?.innerText),
          url: link,
          icon: icon,
        ),
      );
    }
    return result;
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null) return null;
    try {
      return HttpDate.parse(raw.trim()).toLocal();
    } catch (_) {
      return null;
    }
  }

  static (String, IconData) _categorize(String t) {
    bool any(List<String> words) => words.any(t.contains);
    if (any(['penyakit', 'antraknosa', 'patek', 'virus', 'jamur', 'layu', 'busuk'])) {
      return ('Penyakit', Icons.coronavirus_outlined);
    }
    if (any(['hama', 'thrips', 'trips', 'kutu', 'ulat', 'lalat', 'tungau'])) {
      return ('Info Hama', Icons.bug_report_outlined);
    }
    if (any(['harga', 'pasar', 'inflasi', 'mahal', 'murah', 'tembus']) ||
        RegExp(r'\brp\s?\d').hasMatch(t)) {
      return ('Harga', Icons.trending_up);
    }
    return ('Budidaya', Icons.agriculture_outlined);
  }
}
