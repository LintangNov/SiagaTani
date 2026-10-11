import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum PasswordLevel { weak, fair, strong }

/// Indikator kekuatan kata sandi: 3 segmen plus teks (tidak hanya warna).
class PasswordStrength extends StatelessWidget {
  const PasswordStrength({super.key, required this.password});

  final String password;

  static PasswordLevel levelOf(String value) {
    final v = value.trim();
    if (v.length < 6) return PasswordLevel.weak;
    final mixed = v.contains(RegExp(r'[A-Za-z]')) && v.contains(RegExp(r'\d'));
    return v.length >= 8 && mixed ? PasswordLevel.strong : PasswordLevel.fair;
  }

  @override
  Widget build(BuildContext context) {
    if (password.trim().isEmpty) return const SizedBox.shrink();

    final level = levelOf(password);
    final (label, color, filled) = switch (level) {
      PasswordLevel.weak => ('Lemah', AppColors.danger, 1),
      PasswordLevel.fair => ('Cukup', AppColors.warning, 2),
      PasswordLevel.strong => ('Kuat', AppColors.success, 3),
    };

    return Semantics(
      label: 'Kekuatan kata sandi: ${label.toLowerCase()}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpace.md),
        child: Row(
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: Container(
                  height: 8,
                  margin: EdgeInsets.only(right: i < 2 ? AppSpace.xs : 0),
                  decoration: BoxDecoration(
                    color: i < filled ? color : AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
            const SizedBox(width: AppSpace.md),
            SizedBox(
              width: 56,
              child: Text(
                label,
                style: AppText.body(
                  size: 13,
                  weight: FontWeight.w600,
                  color: color,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
