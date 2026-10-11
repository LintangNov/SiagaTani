import 'package:flutter/material.dart';

/// Token warna SiagaTani (sumber: design-system/MASTER.md).
/// Nama lama (primary, textDark, dst.) dipertahankan sebagai alias token baru
/// agar layar lama tetap jalan sambil dimigrasi.
class AppColors {
  AppColors._();

  // ============ TOKEN DESIGN SYSTEM ============
  static const Color surfacePrimary = Color(0xFFF5F3EE);
  static const Color surfaceSecondary = Color(0xFFC8DBBC);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  static const Color foregroundPrimary = Color(0xFF1B3A28);
  static const Color foregroundSecondary = Color(0xFF385640);
  static const Color foregroundTertiary = Color(0xFF5E7466);

  static const Color accentPrimary = Color(0xFF27553A);
  static const Color accentSecondary = Color(0xFF8B5E34);
  static const Color onAccent = Color(0xFFFFFFFF);

  static const Color borderStrong = Color(0xFF758A7C);
  static const Color borderSubtle = Color(0xFFD6DDD0);

  static const Color danger = Color(0xFFB3261E);
  static const Color dangerBg = Color(0xFFFCE4E2);
  static const Color warning = Color(0xFF8A5A00);
  static const Color warningBg = Color(0xFFFDECC8);
  static const Color success = Color(0xFF1E6B3C);
  static const Color successBg = Color(0xFFE3F1E8);

  static const Color shadow = Color(0x1A1B3A28);
  static const Color overlay = Color(0x801B3A28);

  /// Gradasi kartu utama (cuaca, akun, artikel pilihan).
  static const LinearGradient mainCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3F8A63), Color(0xFF215A40)],
  );

  // ============ ALIAS NAMA LAMA ============
  static const Color primary = accentPrimary;
  static const Color primaryLight = surfaceSecondary;
  static const Color primaryDark = foregroundPrimary;

  static const Color secondary = foregroundSecondary;
  static const Color secondaryLight = foregroundTertiary;
  static const Color secondaryDark = foregroundPrimary;

  static const Color tertiary = Color(0xFF3F8A63);
  static const Color tertiaryLight = surfaceSecondary;
  static const Color tertiaryDark = Color(0xFF215A40);

  static const Color textDark = foregroundPrimary;
  static const Color textPrimary = foregroundPrimary;
  static const Color textSecondary = foregroundSecondary;
  static const Color textLight = foregroundTertiary;

  static const Color background = surfacePrimary;
  static const Color backgroundLight = surfaceCard;
  static const Color backgroundDark = surfaceSecondary;

  static const Color surface = surfaceCard;
  static const Color surfaceLight = surfaceCard;
  static const Color surfaceDark = surfacePrimary;

  static const Color error = danger;
  static const Color errorLight = dangerBg;
  static const Color errorDark = danger;

  static const Color border = borderSubtle;
  static const Color borderLight = borderSubtle;
  static const Color borderDark = borderStrong;

  static const LinearGradient primaryGradient = mainCardGradient;
}
