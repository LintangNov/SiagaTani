import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Tombol "Masuk dengan Google" memakai logo resmi Google (assets/icons/google.png).
class GoogleButton extends StatelessWidget {
  const GoogleButton({
    super.key,
    required this.onPressed,
    this.label = 'Masuk dengan Google',
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSize.touch,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceCard,
          foregroundColor: AppColors.foregroundPrimary,
          side: const BorderSide(color: AppColors.borderStrong, width: 2),
          textStyle: AppText.button(color: AppColors.foregroundPrimary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/google.png',
              height: 24,
              width: 24,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: AppSpace.md),
            Flexible(
              child: Text(
                label,
                style: AppText.button(color: AppColors.foregroundPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
