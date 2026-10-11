import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';

/// Tombol kembali persegi rounded 56x56.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Kembali',
      excludeSemantics: true,
      child: Material(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.buttonBorder,
        child: InkWell(
          borderRadius: AppRadius.buttonBorder,
          onTap: onPressed ?? () => Get.back(),
          child: const SizedBox(
            width: AppSize.touch,
            height: AppSize.touch,
            child: Icon(
              Icons.arrow_back,
              size: 28,
              color: AppColors.foregroundPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
