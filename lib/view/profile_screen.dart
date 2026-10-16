import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/ui_utils.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_text_field.dart';
import '../widgets/common/sheet_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static String _selectedTextSize = 'Normal';

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  String _getUserDisplayName() {
    final user = _currentUser;
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }
    return 'Budi';
  }

  String _getUserEmail() {
    final user = _currentUser;
    if (user?.email != null && user!.email!.trim().isNotEmpty) {
      return user.email!.trim();
    }
    return 'budi@email.com';
  }

  String _getUserInitial() {
    final name = _getUserDisplayName();
    return name.isNotEmpty ? name[0].toUpperCase() : 'B';
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final displayName = _getUserDisplayName();
    final displayEmail = _getUserEmail();
    final initial = _getUserInitial();
    final photoUrl = _currentUser?.photoURL;

    return Scaffold(
      backgroundColor: AppColors.surfacePrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.screen,
            vertical: AppSpace.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Judul "Profil" ──────────────────────────────
              Text(
                'Profil',
                style: AppText.heading(
                  size: 24,
                  weight: FontWeight.w700,
                  color: AppColors.foregroundPrimary,
                ),
              ),
              const SizedBox(height: AppSpace.lg),

              // ── Kartu Akun Utama (Hijau Elegan Sesuai UI Acuan) ────
              _buildAccountCard(
                displayName: displayName,
                email: displayEmail,
                initial: initial,
                photoUrl: photoUrl,
                onTap: () => _openDetailProfilSheet(context),
              ),
              const SizedBox(height: AppSpace.xl),

              // ── Kartu Menu Pengaturan (Putih Rounded Sesuai UI) ───
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppShadow.card,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Detail Profil',
                      onTap: () => _openDetailProfilSheet(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.lock_outline_rounded,
                      title: 'Ubah Kata Sandi',
                      onTap: () => _openChangePasswordSheet(context),
                    ),
                    _buildMenuItem(
                      customIcon: const _TextSizeIcon(),
                      title: 'Ukuran Teks',
                      onTap: () => _openTextSizeSheet(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline_rounded,
                      title: 'Tentang Aplikasi',
                      onTap: () => _openAboutAppSheet(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Bantuan dan FAQ',
                      onTap: () => _openFaqSheet(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.xl),

              // ── Tombol "Keluar Akun" (Outlined Merah Sesuai UI) ────
              _buildLogoutButton(
                onTap: () => _showLogoutConfirmation(context, authController),
              ),
              const SizedBox(height: AppSpace.lg),

              // ── Keterangan Versi Aplikasi ──────────────────────────
              Center(
                child: Text(
                  'SiagaTani versi 1.0',
                  style: AppText.body(
                    size: 14,
                    color: AppColors.foregroundTertiary,
                    weight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.xxl),
            ],
          ),
        ),
      ),
    );
  }

  // ── Kartu Akun Utama ───────────────────────────────────────────
  Widget _buildAccountCard({
    required String displayName,
    required String email,
    required String initial,
    String? photoUrl,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF286548), Color(0xFF1B4933)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadow.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                // Avatar Lingkaran Putih dengan Inisial Tebal / Foto
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: photoUrl != null && photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildInitialText(initial),
                          )
                        : _buildInitialText(initial),
                  ),
                ),
                const SizedBox(width: 16),

                // Nama & Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppText.heading(
                          size: 20,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        email,
                        style: AppText.body(
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Panah Chevron Kanan Putih
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialText(String initial) {
    return Center(
      child: Text(
        initial,
        style: AppText.heading(
          size: 26,
          weight: FontWeight.w800,
          color: const Color(0xFF1B3A28),
        ),
      ),
    );
  }

  // ── Baris Item Menu ────────────────────────────────────────────
  Widget _buildMenuItem({
    IconData? icon,
    Widget? customIcon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.accentPrimary.withValues(alpha: 0.08),
        highlightColor: AppColors.accentPrimary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              if (customIcon != null)
                customIcon
              else if (icon != null)
                Icon(icon, size: 24, color: AppColors.foregroundPrimary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppText.body(
                    size: 16,
                    weight: FontWeight.w600,
                    color: AppColors.foregroundPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: AppColors.foregroundTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tombol Keluar Akun (Outlined Merah) ─────────────────────────
  Widget _buildLogoutButton({required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      height: AppSize.touch,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.danger, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.danger.withValues(alpha: 0.12),
          highlightColor: AppColors.danger.withValues(alpha: 0.06),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: AppColors.danger,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Keluar Akun',
                style: AppText.body(
                  size: 16,
                  weight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialog Konfirmasi Keluar Akun ──────────────────────────────
  void _showLogoutConfirmation(
    BuildContext context,
    AuthController controller,
  ) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpace.screen),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.dangerBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 32,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                'Keluar dari Akun?',
                style: AppText.heading(
                  size: 20,
                  weight: FontWeight.w700,
                  color: AppColors.foregroundPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                'Anda perlu masuk lagi untuk menggunakan aplikasi SiagaTani.',
                textAlign: TextAlign.center,
                style: AppText.body(
                  size: 14,
                  color: AppColors.foregroundSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpace.xl),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Batal',
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: AppButton.danger(
                      label: 'Ya, Keluar',
                      onPressed: () {
                        Get.back();
                        controller.logout();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // ── Sub-layar: Detail Profil ───────────────────────────────────
  void _openDetailProfilSheet(BuildContext context) {
    final nameCtrl = TextEditingController(text: _getUserDisplayName());
    final emailCtrl = TextEditingController(text: _getUserEmail());
    bool isSaving = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return SheetContainer(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Detail Profil', style: AppText.heading(size: 20)),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.foregroundPrimary,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.lg),

                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getUserInitial(),
                          style: AppText.heading(
                            size: 34,
                            weight: FontWeight.w800,
                            color: AppColors.foregroundPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),

                  AppTextField(
                    label: 'Nama Panggilan',
                    controller: nameCtrl,
                    helper: 'Dipakai untuk menyapa Anda di Beranda',
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: AppSpace.lg),

                  AppTextField(
                    label: 'Email',
                    controller: emailCtrl,
                    enabled: false,
                    helper: 'Email tidak dapat diubah',
                  ),
                  const SizedBox(height: AppSpace.xl),

                  AppButton(
                    label: 'Simpan Perubahan',
                    loading: isSaving,
                    onPressed: () async {
                      final newName = nameCtrl.text.trim();
                      if (newName.isEmpty) return;
                      setSheetState(() => isSaving = true);
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await user.updateDisplayName(newName);
                        }
                        if (Get.isRegistered<DashboardController>()) {
                          await Get.find<DashboardController>().fetchUserData();
                        }
                        if (mounted) setState(() {});
                        Get.back();
                        UiUtils.showSuccess('Profil berhasil diperbarui');
                      } catch (e) {
                        setSheetState(() => isSaving = false);
                        UiUtils.showError('Gagal memperbarui profil: $e');
                      }
                    },
                  ),
                  const SizedBox(height: AppSpace.md),
                  AppButton.secondary(
                    label: 'Batal',
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  // ── Sub-layar: Ubah Kata Sandi ─────────────────────────────────
  void _openChangePasswordSheet(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGoogleUser =
        user?.providerData.any((p) => p.providerId == 'google.com') ?? false;

    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    String? errorText;
    bool isSaving = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return SheetContainer(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ubah Kata Sandi', style: AppText.heading(size: 20)),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.foregroundPrimary,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.lg),

                  if (isGoogleUser) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpace.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary.withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.accentPrimary,
                            size: 28,
                          ),
                          const SizedBox(width: AppSpace.md),
                          Expanded(
                            child: Text(
                              'Akun Anda terhubung melalui Google Sign-In, sehingga tidak memerlukan kata sandi terpisah.',
                              style: AppText.body(size: 14, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.xl),
                    AppButton.secondary(
                      label: 'Tutup',
                      onPressed: () => Get.back(),
                    ),
                  ] else ...[
                    AppTextField(
                      label: 'Kata Sandi Baru',
                      controller: newPassCtrl,
                      isPassword: true,
                      helper: 'Minimal 6 karakter',
                      errorText: errorText,
                    ),
                    const SizedBox(height: AppSpace.lg),
                    AppTextField(
                      label: 'Ulangi Kata Sandi Baru',
                      controller: confirmPassCtrl,
                      isPassword: true,
                    ),
                    const SizedBox(height: AppSpace.xl),
                    AppButton(
                      label: 'Simpan Kata Sandi',
                      loading: isSaving,
                      onPressed: () async {
                        final newPass = newPassCtrl.text.trim();
                        final confirmPass = confirmPassCtrl.text.trim();

                        if (newPass.length < 6) {
                          setSheetState(
                            () => errorText = 'Kata sandi minimal 6 karakter.',
                          );
                          return;
                        }
                        if (newPass != confirmPass) {
                          setSheetState(
                            () => errorText =
                                'Kata sandi konfirmasi tidak cocok.',
                          );
                          return;
                        }

                        setSheetState(() {
                          errorText = null;
                          isSaving = true;
                        });

                        try {
                          await user?.updatePassword(newPass);
                          Get.back();
                          UiUtils.showSuccess(
                            'Kata sandi berhasil diperbarui.',
                          );
                        } catch (e) {
                          setSheetState(() {
                            isSaving = false;
                            errorText =
                                'Gagal memperbarui kata sandi. Silakan masuk ulang.';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppSpace.md),
                    AppButton.secondary(
                      label: 'Batal',
                      onPressed: () => Get.back(),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  // ── Sub-layar: Ukuran Teks ─────────────────────────────────────
  void _openTextSizeSheet(BuildContext context) {
    final options = [
      {
        'name': 'Normal',
        'scale': '100%',
        'example': 'Kelembapan 60%, waktunya memeriksa daun.',
      },
      {
        'name': 'Besar',
        'scale': '115%',
        'example': 'Kelembapan 60%, waktunya memeriksa daun.',
      },
      {
        'name': 'Sangat Besar',
        'scale': '130%',
        'example': 'Kelembapan 60%, waktunya memeriksa daun.',
      },
    ];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return SheetContainer(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ukuran Teks', style: AppText.heading(size: 20)),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.foregroundPrimary,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    'Pilih ukuran tampilan yang paling nyaman Anda baca.',
                    style: AppText.body(
                      size: 14,
                      color: AppColors.foregroundSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpace.lg),

                  for (final opt in options) ...[
                    InkWell(
                      onTap: () {
                        setSheetState(() {
                          _selectedTextSize = opt['name']!;
                        });
                        setState(() {});
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpace.lg),
                        margin: const EdgeInsets.only(bottom: AppSpace.md),
                        decoration: BoxDecoration(
                          color: _selectedTextSize == opt['name']
                              ? AppColors.surfaceSecondary.withValues(
                                  alpha: 0.4,
                                )
                              : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedTextSize == opt['name']
                                ? AppColors.accentPrimary
                                : AppColors.borderSubtle,
                            width: _selectedTextSize == opt['name'] ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        opt['name']!,
                                        style: AppText.body(
                                          size: 16,
                                          weight: FontWeight.w700,
                                          color: AppColors.foregroundPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${opt['scale']})',
                                        style: AppText.body(
                                          size: 13,
                                          color: AppColors.foregroundTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    opt['example']!,
                                    style: AppText.body(
                                      size: opt['name'] == 'Sangat Besar'
                                          ? 16
                                          : opt['name'] == 'Besar'
                                          ? 15
                                          : 14,
                                      color: AppColors.foregroundSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedTextSize == opt['name'])
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.accentPrimary,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpace.md),
                  AppButton(
                    label: 'Selesai',
                    onPressed: () {
                      Get.back();
                      UiUtils.showSuccess(
                        'Ukuran teks $_selectedTextSize diterapkan.',
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  // ── Sub-layar: Tentang Aplikasi ────────────────────────────────
  void _openAboutAppSheet(BuildContext context) {
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
                  Text('Tentang Aplikasi', style: AppText.heading(size: 20)),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.foregroundPrimary,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.lg),

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppShadow.card,
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                    Text(
                      'SiagaTani',
                      style: AppText.heading(size: 22, weight: FontWeight.w700),
                    ),
                    Text(
                      'Versi 1.0.0',
                      style: AppText.body(
                        size: 14,
                        color: AppColors.foregroundTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.lg),

              Text(
                'Asisten petani cabai untuk memantau cuaca dan risiko hama di lahan Anda.',
                textAlign: TextAlign.center,
                style: AppText.body(
                  size: 15,
                  color: AppColors.foregroundSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              Center(
                child: Text(
                  'Dibuat sebagai proyek mata kuliah Komputer dan Masyarakat',
                  textAlign: TextAlign.center,
                  style: AppText.body(
                    size: 13,
                    color: AppColors.foregroundTertiary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.xl),

              Container(
                padding: const EdgeInsets.all(AppSpace.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfacePrimary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sumber Data & Atribusi',
                      style: AppText.body(
                        size: 15,
                        weight: FontWeight.w700,
                        color: AppColors.foregroundPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    _buildAttributionItem(
                      'Peta Digital',
                      '© Kontributor OpenStreetMap',
                    ),
                    _buildAttributionItem(
                      'Prakiraan Cuaca',
                      'OpenWeatherMap API',
                    ),
                    _buildAttributionItem(
                      'Analisis Cerdas',
                      'Google Gemini AI',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.xl),

              AppButton.secondary(label: 'Tutup', onPressed: () => Get.back()),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildAttributionItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: AppColors.accentPrimary),
          const SizedBox(width: 8),
          Text(
            '$title: ',
            style: AppText.body(size: 13, weight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              desc,
              style: AppText.body(
                size: 13,
                color: AppColors.foregroundSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-layar: Bantuan dan FAQ ─────────────────────────────────
  void _openFaqSheet(BuildContext context) {
    final faqs = [
      {
        'q': 'Bagaimana cara menambah lahan baru?',
        'a':
            'Buka menu Beranda atau tab Lahan Saya, lalu tekan tombol "+ Tambah Lahan". Isi data nama lahan, fase tanam, varietas cabai, dan tandai koordinat lokasi lahan di peta.',
      },
      {
        'q': 'Kenapa cuaca di Beranda tidak muncul?',
        'a':
            'Pastikan GPS perangkat Anda dalam keadaan aktif dan izin lokasi telah disetujui untuk SiagaTani. Anda juga dapat menarik layar ke bawah (pull to refresh) untuk memperbarui.',
      },
      {
        'q': 'Kenapa peta tidak dapat dimuat?',
        'a':
            'Peta digital OpenStreetMap membutuhkan sambungan internet aktif. Pastikan kuota seluler atau sambungan Wi-Fi Anda stabil.',
      },
      {
        'q': 'Apa arti status Aman, Waspada, dan Bahaya?',
        'a':
            'Status risiko dihitung berdasarkan kombinasi data cuaca aktual (suhu, kelembapan) dan fase tanaman Anda untuk mendeteksi dini ancaman hama seperti Kutu Kebul atau jamur Antraknosa.',
      },
      {
        'q': 'Apakah saran pencegahan AI pasti akurat?',
        'a':
            'Saran dari AI dirancang sebagai panduan pendamping budidaya dan pencegahan dini. Selalu lakukan pengamatan langsung kondisi fisik tanaman di lahan Anda.',
      },
    ];

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
                  Text('Bantuan dan FAQ', style: AppText.heading(size: 20)),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.foregroundPrimary,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                'Pertanyaan umum seputar penggunaan aplikasi SiagaTani.',
                style: AppText.body(
                  size: 14,
                  color: AppColors.foregroundSecondary,
                ),
              ),
              const SizedBox(height: AppSpace.lg),

              for (final faq in faqs)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpace.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfacePrimary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      iconColor: AppColors.accentPrimary,
                      collapsedIconColor: AppColors.foregroundTertiary,
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      title: Text(
                        faq['q']!,
                        style: AppText.body(
                          size: 15,
                          weight: FontWeight.w600,
                          color: AppColors.foregroundPrimary,
                        ),
                      ),
                      children: [
                        Text(
                          faq['a']!,
                          style: AppText.body(
                            size: 14,
                            color: AppColors.foregroundSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: AppSpace.lg),

              AppButton.secondary(label: 'Tutup', onPressed: () => Get.back()),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ── Widget Ikon AA Khusus untuk "Ukuran Teks" ─────────────────────
class _TextSizeIcon extends StatelessWidget {
  const _TextSizeIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'A',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.foregroundPrimary,
                height: 1,
              ),
            ),
            Text(
              'A',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.foregroundPrimary,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
