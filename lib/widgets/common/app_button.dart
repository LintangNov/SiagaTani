import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, danger }

/// Tombol standar 56dp, radius 20, lebar penuh.
/// Primary = isi hijau, Secondary = garis hijau, Danger = isi merah.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  }) : variant = AppButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isSecondary = variant == AppButtonVariant.secondary;
    final fg = isSecondary ? AppColors.accentPrimary : AppColors.onAccent;
    final bg = switch (variant) {
      AppButtonVariant.primary => AppColors.accentPrimary,
      AppButtonVariant.danger => AppColors.danger,
      AppButtonVariant.secondary => Colors.transparent,
    };

    final child = loading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 24),
                const SizedBox(width: AppSpace.sm),
              ],
              Flexible(
                child: Text(label, textAlign: TextAlign.center),
              ),
            ],
          );

    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(AppSize.touch)),
      backgroundColor: WidgetStatePropertyAll(bg),
      foregroundColor: WidgetStatePropertyAll(fg),
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(AppText.button(color: fg)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: AppRadius.buttonBorder,
          side: isSecondary
              ? const BorderSide(color: AppColors.accentPrimary, width: 2)
              : BorderSide.none,
        ),
      ),
    );

    return SizedBox(
      width: double.infinity,
      height: AppSize.touch,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: style,
        child: child,
      ),
    );
  }
}
