import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Tombol ikon bulat dengan lingkar putih — ukuran kompak best-practice.
/// Lingkar putih 36dp, ikon default 20dp. Dipakai di AppBar dan header.
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
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 1.5,
        shadowColor: AppColors.shadow,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 20, color: AppColors.foregroundPrimary),
          ),
        ),
      ),
    );
  }
}
