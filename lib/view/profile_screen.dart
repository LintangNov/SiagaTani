import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Background abu-abu muda
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Profil & Pengaturan",
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C3312),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KARTU PROFIL (HEADER)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: _boxDecoration(),
              child: Row(
                children: [
                  // Foto Profil
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 30,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Nama & Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "Petani Siaga",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3312),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? "email@contoh.com",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tombol Edit Kecil
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // LABEL SECTION 1
            Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 10),
              child: Text(
                "Pengaturan Akun",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),

            // 2. GROUP MENU UTAMA
            Container(
              decoration: _boxDecoration(),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: "Detail Profil",
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    title: "Kata Sandi",
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: "Notifikasi",
                    onTap: () {},
                  ),
                  _buildDivider(),
                  // Switch Dark Mode (Visual Saja Dulu)
                  ListTile(
                    leading: const Icon(
                      Icons.dark_mode_outlined,
                      color: Color(0xFF2C3312),
                    ),
                    title: Text(
                      "Mode Gelap",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Switch(
                      value: false,
                      activeColor: const Color(0xFF4CAF50),
                      onChanged: (val) {}, // Nanti diisi logic theme
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // LABEL SECTION 2
            Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 10),
              child: Text(
                "Lainnya",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),

            // 3. GROUP INFO & LOGOUT
            Container(
              decoration: _boxDecoration(),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: "Tentang Aplikasi",
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    title: "Bantuan & FAQ",
                    onTap: () {},
                  ),
                  _buildDivider(),
                  // TOMBOL LOGOUT (Merah)
                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                    ),
                    title: Text(
                      "Keluar Akun",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.red,
                    ),
                    onTap: () =>
                        _showLogoutConfirmation(context, authController),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: Text(
                "Versi 1.0.0 (Beta)",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS & STYLING ---

  // Style Kotak Putih + Bayangan Halus
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Item List Biasa
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2C3312)),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2C3312),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  // Garis Pemisah Tipis
  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, indent: 50, endIndent: 20);
  }

  // Dialog Konfirmasi Logout
  // --- GANTI BAGIAN INI SAJA DI profile_screen.dart ---

  void _showLogoutConfirmation(
    BuildContext context,
    AuthController controller,
  ) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Agar dialog menyesuaikan isi
            children: [
              // 1. IKON (Lingkaran Merah Muda)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 32,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 20),

              // 2. JUDUL
              Text(
                "Keluar Akun",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3312),
                ),
              ),

              const SizedBox(height: 8),

              // 3. PESAN
              Text(
                "Apakah Anda yakin ingin keluar dari aplikasi SiagaTani?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5, // Spasi antar baris biar enak dibaca
                ),
              ),

              const SizedBox(height: 25),

              // 4. TOMBOL AKSI (Sejajar)
              Row(
                children: [
                  // Tombol Batal (Abu-abu)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Batal",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12), // Jarak antar tombol
                  // Tombol Keluar (Merah)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Tutup dialog
                        controller.logout(); // Proses logout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // Efek bayangan merah halus biar modern
                        shadowColor: Colors.red.withOpacity(0.4),
                      ),
                      child: Text(
                        "Ya, Keluar",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // User harus pilih tombol, gak bisa klik luar
    );
  }
}
