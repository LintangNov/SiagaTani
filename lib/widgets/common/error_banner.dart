import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Banner galat server/jaringan: latar merah muda, ikon, teks, bisa ditutup.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final VoidCallback onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg,
          AppSpace.md,
          AppSpace.xs,
          AppSpace.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.dangerBg,
          borderRadius: AppRadius.inputBorder,
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.error_outline,
                size: 24,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: AppText.body(
                        size: 14,
                        color: AppColors.foregroundPrimary,
                        height: 1.4,
                      ),
                    ),
                    if (actionLabel != null)
                      TextButton(
                        onPressed: onAction,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          minimumSize: const Size(AppSize.touch, AppSize.touch),
                        ),
                        child: Text(actionLabel!),
                      ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              tooltip: 'Tutup pesan',
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              icon: const Icon(
                Icons.close,
                size: 24,
                color: AppColors.foregroundSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
