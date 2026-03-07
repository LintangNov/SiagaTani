import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/farm_model.dart';
import '../view/farm_detail_screen.dart';

/// Horizontally scrollable farm overview card for the dashboard.
/// Shows crop type, visual growth phase progress, and a short status hint.
class FarmOverviewCard extends StatelessWidget {
  final FarmModel farm;

  const FarmOverviewCard({super.key, required this.farm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final phaseProgress = _getPhaseProgress(farm.cropStage);
    final phaseLabel = _getPhaseLabel(farm.cropStage);
    final nextAction = _getNextAction(farm.cropStage);

    return GestureDetector(
      onTap: () => Get.to(() => FarmDetailScreen(), arguments: farm),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farm name
            Text(
              farm.farmName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Variety chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                farm.variety,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const Spacer(),
            // Phase progress
            Text(
              phaseLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: phaseProgress,
                minHeight: 6,
                backgroundColor: colorScheme.primaryContainer.withOpacity(0.5),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 8),
            // Next action hint
            Row(
              children: [
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    nextAction,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getPhaseProgress(CropStage stage) {
    switch (stage) {
      case CropStage.seedling:
        return 0.2;
      case CropStage.vegetative:
        return 0.4;
      case CropStage.flowering:
        return 0.6;
      case CropStage.fruiting:
        return 0.8;
      case CropStage.harvesting:
        return 1.0;
    }
  }

  String _getPhaseLabel(CropStage stage) {
    switch (stage) {
      case CropStage.seedling:
        return "Bibit";
      case CropStage.vegetative:
        return "Vegetatif";
      case CropStage.flowering:
        return "Berbunga";
      case CropStage.fruiting:
        return "Berbuah";
      case CropStage.harvesting:
        return "Panen";
    }
  }

  String _getNextAction(CropStage stage) {
    switch (stage) {
      case CropStage.seedling:
        return "Siapkan pemupukan";
      case CropStage.vegetative:
        return "Pantau pertumbuhan";
      case CropStage.flowering:
        return "Cek penyerbukan";
      case CropStage.fruiting:
        return "Periksa buah";
      case CropStage.harvesting:
        return "Siap panen";
    }
  }
}
