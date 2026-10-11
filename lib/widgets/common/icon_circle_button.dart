import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Tombol ikon bulat 56dp tanpa teks dan tanpa garis tepi (Button/Icon).
class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: AppColors.surfaceCard,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: AppColors.shadow,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: AppSize.touch,
            height: AppSize.touch,
            child: Icon(icon, size: 28, color: AppColors.foregroundPrimary),
          ),
        ),
      ),
    );
  }
}
