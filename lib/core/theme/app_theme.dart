import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_tokens.dart';

export 'app_colors.dart';
export 'app_tokens.dart';

/// Tema aplikasi SiagaTani berdasarkan design-system/MASTER.md.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    const scheme = ColorScheme.light(
      primary: AppColors.accentPrimary,
      onPrimary: AppColors.onAccent,
      primaryContainer: AppColors.surfaceSecondary,
      onPrimaryContainer: AppColors.foregroundPrimary,
      secondary: AppColors.accentSecondary,
      onSecondary: AppColors.onAccent,
      tertiary: AppColors.foregroundSecondary,
      error: AppColors.danger,
      onError: AppColors.onAccent,
      errorContainer: AppColors.dangerBg,
      surface: AppColors.surfaceCard,
      onSurface: AppColors.foregroundPrimary,
      onSurfaceVariant: AppColors.foregroundSecondary,
      outline: AppColors.borderStrong,
      outlineVariant: AppColors.borderSubtle,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: AppRadius.buttonBorder,
    );
    const buttonSize = Size.fromHeight(AppSize.touch);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surfacePrimary,
      splashFactory: InkRipple.splashFactory,

      textTheme: _textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfacePrimary,
        foregroundColor: AppColors.foregroundPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.heading(size: 20, weight: FontWeight.w600),
        iconTheme: const IconThemeData(
          color: AppColors.foregroundPrimary,
          size: 28,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          minimumSize: buttonSize,
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
          shape: buttonShape,
          textStyle: AppText.button(),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: AppColors.onAccent,
          minimumSize: buttonSize,
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
          shape: buttonShape,
          textStyle: AppText.button(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          minimumSize: buttonSize,
          side: const BorderSide(color: AppColors.accentPrimary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
          shape: buttonShape,
          textStyle: AppText.button(color: AppColors.accentPrimary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          minimumSize: const Size(AppSize.touch, AppSize.touch),
          shape: buttonShape,
          textStyle: AppText.body(size: 16, weight: FontWeight.w600),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentPrimary,
        foregroundColor: AppColors.onAccent,
        elevation: 2,
        shape: buttonShape,
        extendedTextStyle: AppText.button(),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.lg,
          vertical: AppSpace.lg,
        ),
        border: _inputBorder(AppColors.borderStrong),
        enabledBorder: _inputBorder(AppColors.borderStrong),
        focusedBorder: _inputBorder(AppColors.accentPrimary),
        errorBorder: _inputBorder(AppColors.danger),
        focusedErrorBorder: _inputBorder(AppColors.danger),
        hintStyle: AppText.body(
          size: 16,
          color: AppColors.foregroundTertiary,
        ),
        labelStyle: AppText.body(size: 16),
        errorStyle: AppText.body(
          size: 14,
          color: AppColors.danger,
          height: 1.3,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
        margin: EdgeInsets.zero,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceCard,
        modalBackgroundColor: AppColors.surfaceCard,
        showDragHandle: false,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
        titleTextStyle: AppText.heading(size: 22, weight: FontWeight.w600),
        contentTextStyle: AppText.body(size: 16),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.foregroundPrimary,
        contentTextStyle: AppText.body(
          size: 16,
          color: AppColors.onAccent,
          height: 1.3,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.inputBorder),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceCard,
        selectedColor: AppColors.accentPrimary,
        side: const BorderSide(color: AppColors.borderSubtle),
        shape: const StadiumBorder(),
        labelStyle: AppText.body(size: 16, weight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.md,
          vertical: AppSpace.md,
        ),
      ),

      iconTheme: const IconThemeData(
        color: AppColors.foregroundPrimary,
        size: 24,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.onAccent
              : AppColors.borderStrong,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.accentPrimary
              : AppColors.borderSubtle,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentPrimary,
        circularTrackColor: AppColors.surfaceSecondary,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: AppRadius.inputBorder,
    borderSide: BorderSide(color: color, width: 2),
  );

  /// Judul (display/headline/title) memakai Geist; isi dan label memakai Inter.
  static TextTheme get _textTheme {
    TextStyle h(double size, FontWeight w) => AppText.heading(
      size: size,
      weight: w,
      height: 1.2,
      letterSpacing: size >= 24 ? -0.3 : 0,
    );
    TextStyle b(double size, FontWeight w, [Color? c]) => AppText.body(
      size: size,
      weight: w,
      color: c ?? AppColors.foregroundPrimary,
    );

    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: h(40, FontWeight.w700),
      displayMedium: h(34, FontWeight.w700),
      displaySmall: h(30, FontWeight.w700),
      headlineLarge: h(28, FontWeight.w700),
      headlineMedium: h(26, FontWeight.w700),
      headlineSmall: h(22, FontWeight.w600),
      titleLarge: h(20, FontWeight.w600),
      titleMedium: h(18, FontWeight.w600),
      titleSmall: h(16, FontWeight.w600),
      bodyLarge: b(18, FontWeight.w400),
      bodyMedium: b(16, FontWeight.w400),
      bodySmall: b(14, FontWeight.w400, AppColors.foregroundSecondary),
      labelLarge: b(16, FontWeight.w600),
      labelMedium: b(14, FontWeight.w500, AppColors.foregroundSecondary),
      labelSmall: b(12, FontWeight.w500, AppColors.foregroundTertiary),
    );
  }
}
