import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  final List<Map<String, String>> articles = const [
    {
      "title": "Waspada! Cuaca Panas Picu Ledakan Kutu Kebul",
      "category": "Info Hama",
      "date": "25 Nov 2025",
      "image": "https://images.unsplash.com/photo-1591035897819-f4bdf739f446?auto=format&fit=crop&w=800&q=80",
      "url": "https://pertanian.go.id"
    },
    {
      "title": "Harga Cabai Rawit Meroket di Pasar Induk",
      "category": "Berita Pasar",
      "date": "24 Nov 2025",
      "image": "https://images.unsplash.com/photo-1558380381-c280df4d1b8b?q=80",
      "url": "https://bi.go.id/hargapangan"
    },
    {
      "title": "Cara Membuat Pestisida Nabati dari Daun Pepaya",
      "category": "Tips Tani",
      "date": "20 Nov 2025",
      "image": "https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?auto=format&fit=crop&w=800&q=80",
      "url": "https://cybex.pertanian.go.id"
    },
    {
      "title": "Mengenal Gejala Serangan Antraknosa (Patek)",
      "category": "Penyakit",
      "date": "18 Nov 2025",
      "image": "https://bumikita.id/img/img_artikel/ca15310f591eb3d1a424af8441338051.jpg",
      "url": "https://example.com"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Pojok Tani",
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C3312),
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeadline(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildCategoryChip("Semua", true),
                  _buildCategoryChip("Berita Pasar", false),
                  _buildCategoryChip("Info Hama", false),
                  _buildCategoryChip("Tips Tani", false),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Terbaru Hari Ini",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3312),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return _buildNewsCard(articles[index]);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&w=1000&q=80"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text("HOT NEWS", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 8),
            Text(
              "Subsidi Pupuk 2025: Kuota Ditambah, Petani Wajib Pakai Kartu Tani!",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(label),
        labelStyle: GoogleFonts.poppins(
          color: isActive ? Colors.white : Colors.grey[700],
          fontSize: 12,
        ),
        backgroundColor: isActive ? const Color(0xFF2C3312) : Colors.white,
        side: isActive ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildNewsCard(Map<String, String> article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              article['image']!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (c, o, s) => Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.image_not_supported)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article['category']!.toUpperCase(),
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(height: 4),
                Text(
                  article['title']!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3312),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      article['date']!,
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}