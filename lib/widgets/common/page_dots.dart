import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Indikator halaman: titik aktif memanjang 32x10, lainnya 10x10.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Halaman ${index + 1} dari $count',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: EdgeInsets.only(left: i == 0 ? 0 : AppSpace.sm),
              width: i == index ? 32 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: i == index
                    ? AppColors.accentPrimary
                    : AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
        ],
      ),
    );
  }
}
