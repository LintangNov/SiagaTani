import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siaga_tani/controllers/auth_controller.dart';
import '../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black87),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                "Buat Akun Baru",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                "Bergabunglah dengan komunitas petani modern.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 30),

              // Nama Lengkap
              _buildLabel("Nama Lengkap"),
              _buildTextField(
                controller: nameCtrl,
                hint: "Nama Panggilan Anda",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              // Email
              _buildLabel("Email"),
              _buildTextField(
                controller: emailCtrl,
                hint: "contoh@email.com",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              // Password
              _buildLabel("Kata Sandi"),
              _buildTextField(
                controller: passCtrl,
                hint: "Minimal 6 karakter",
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 40),

              // Button Register
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: authController.isLoading.value
                        ? null
                        : () {
                            // Ambil text dan bersihkan spasi di awal/akhir
                            String name = nameCtrl.text.trim();
                            String email = emailCtrl.text.trim();
                            String pass = passCtrl.text.trim();

                            // 1. VALIDASI: Data Kosong
                            if (name.isEmpty || email.isEmpty || pass.isEmpty) {
                              Get.snackbar(
                                "Data Belum Lengkap",
                                "Semua kolom wajib diisi ya!",
                                backgroundColor: Colors.red.shade50,
                                colorText: Colors.red,
                                icon: const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                ),
                              );
                              return; // Stop, jangan lanjut
                            }

                            // 2. VALIDASI: Format Email (Pakai GetUtils)
                            if (!GetUtils.isEmail(email)) {
                              Get.snackbar(
                                "Email Tidak Valid",
                                "Coba cek lagi emailnya (contoh: nama@email.com)",
                                backgroundColor: Colors.orange.shade50,
                                colorText: Colors.orange.shade900,
                                icon: const Icon(
                                  Icons.alternate_email,
                                  color: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // 3. VALIDASI: Password (Firebase wajib minimal 6 karakter)
                            if (pass.length < 6) {
                              Get.snackbar(
                                "Password Lemah",
                                "Kata sandi minimal harus 6 karakter.",
                                backgroundColor: Colors.orange.shade50,
                                colorText: Colors.orange.shade900,
                                icon: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // Kalau semua lolos, baru panggil controller
                            authController.register(name, email, pass);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: authController.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Daftar",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
