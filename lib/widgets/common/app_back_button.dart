import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'icon_circle_button.dart';

/// Tombol kembali bulat 56x56 (Button/Icon).
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconCircleButton(
      icon: Icons.arrow_back,
      semanticLabel: 'Kembali',
      onPressed: onPressed ?? () => Get.back(),
    );
  }
}
