import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Panel putih dengan sudut atas 28, padding 24, dan menghormati safe area bawah.
/// Dipakai untuk bottom sheet maupun panel tetap di dasar layar.
class SheetContainer extends StatelessWidget {
  const SheetContainer({super.key, required this.child, this.shadow = false});

  final Widget child;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen,
        AppSpace.screen,
        AppSpace.screen,
        AppSpace.screen + bottomInset,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.sheetTop,
        boxShadow: shadow
            ? const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
