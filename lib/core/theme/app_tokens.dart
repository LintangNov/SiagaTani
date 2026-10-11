import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Jarak, radius, dan ukuran sentuh (design-system/MASTER.md).
class AppSpace {
  AppSpace._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Padding horizontal standar layar.
  static const double screen = 24;
}

class AppRadius {
  AppRadius._();
  static const double input = 16;
  static const double card = 20;
  static const double button = 20;
  static const double sheet = 28;
  static const double full = 999;

  static BorderRadius get inputBorder => BorderRadius.circular(input);
  static BorderRadius get cardBorder => BorderRadius.circular(card);
  static BorderRadius get buttonBorder => BorderRadius.circular(button);
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}

class AppSize {
  AppSize._();

  /// Target sentuh minimum untuk pengguna lansia.
  static const double touch = 56;
}

/// Gaya teks: Geist untuk judul, Inter untuk isi.
class AppText {
  AppText._();

  static TextStyle heading({
    double size = 26,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.foregroundPrimary,
    double height = 1.2,
    double letterSpacing = -0.3,
  }) => GoogleFonts.geist(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle body({
    double size = 18,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.foregroundSecondary,
    double height = 1.5,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );

  static TextStyle button({Color color = AppColors.onAccent}) =>
      body(size: 18, weight: FontWeight.w600, color: color, height: 1.2);
}
