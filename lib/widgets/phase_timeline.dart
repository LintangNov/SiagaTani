import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/farm_model.dart';

/// Vertical visual timeline showing all growth phases matching the mockup:
/// - Completed: green check icon + "Completed on [date]"
/// - Current: green ring with dot + "Current" badge + "In Progress (XX%)" + tip card
/// - Future: grey number + "Estimated Start: [date]"
class PhaseTimeline extends StatelessWidget {
  final String currentPhase;
  final CropStage cropStage;
  final int dayCount;

  const PhaseTimeline({
    super.key,
    required this.currentPhase,
    required this.cropStage,
    this.dayCount = 45,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final phases = _buildPhaseList();
    final currentIndex = cropStage.index;

    return Column(
      children: [
        // Section header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Growth Timeline",
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              "Day $dayCount",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Timeline items
        ...List.generate(phases.length, (index) {
          final phase = phases[index];
          final isCompleted = index < currentIndex;
          final isCurrent = index == currentIndex;
          final isFuture = index > currentIndex;
          final isLast = index == phases.length - 1;

          return _buildPhaseItem(
            context,
            phase: phase,
            index: index + 1,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            isFuture: isFuture,
            isLast: isLast,
            colorScheme: colorScheme,
            theme: theme,
          );
        }),
      ],
    );
  }

  List<_PhaseData> _buildPhaseList() {
    // Generate realistic dates relative to now
    final now = DateTime.now();
    return [
      _PhaseData(
        label: "Germination",
        completedDate: _subtractDays(now, 60),
        estimatedDate: null,
        stage: CropStage.seedling,
        progress: 1.0,
        tip:
            "Pastikan kelembapan tanah terjaga dan hindari sinar matahari langsung.",
      ),
      _PhaseData(
        label: "Seedling",
        completedDate: _subtractDays(now, 35),
        estimatedDate: null,
        stage: CropStage.vegetative,
        progress: 1.0,
        tip: "Siapkan media tanam dan lakukan penyiraman rutin.",
      ),
      _PhaseData(
        label: "Vegetative Phase",
        completedDate: null,
        estimatedDate: null,
        stage: CropStage.vegetative,
        progress: 0.75,
        tip: "Fokus pada pupuk nitrogen untuk mendukung pertumbuhan daun.",
      ),
      _PhaseData(
        label: "Flowering",
        completedDate: null,
        estimatedDate: _addDays(now, 25),
        stage: CropStage.flowering,
        progress: 0.0,
        tip:
            "Kurangi pupuk nitrogen, tingkatkan fosfor untuk pembungaan optimal.",
      ),
      _PhaseData(
        label: "Fruiting",
        completedDate: null,
        estimatedDate: _addDays(now, 50),
        stage: CropStage.fruiting,
        progress: 0.0,
        tip: "Pastikan penyiraman cukup dan pantau hama buah.",
      ),
    ];
  }

  DateTime _subtractDays(DateTime from, int days) =>
      from.subtract(Duration(days: days));
  DateTime _addDays(DateTime from, int days) => from.add(Duration(days: days));

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}";
  }

  Widget _buildPhaseItem(
    BuildContext context, {
    required _PhaseData phase,
    required int index,
    required bool isCompleted,
    required bool isCurrent,
    required bool isFuture,
    required bool isLast,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    final activeColor = colorScheme.primary;
    final futureColor = Colors.grey.shade300;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline column (circle + line) ──
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Circle indicator
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? activeColor
                        : isCurrent
                        ? activeColor.withOpacity(0.15)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted || isCurrent
                          ? activeColor
                          : futureColor,
                      width: isCurrent ? 2.5 : 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : isCurrent
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: activeColor,
                              shape: BoxShape.circle,
                            ),
                          )
                        : Text(
                            "$index",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ),
                ),
                // Connecting line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isCompleted ? activeColor : futureColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── Content column ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with optional "Current" badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          phase.label,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isFuture
                                ? Colors.grey.shade400
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: activeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Current",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Subtitle based on state
                  if (isCompleted && phase.completedDate != null)
                    Text(
                      "Completed on ${_formatDate(phase.completedDate!)}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  if (isCurrent)
                    Text(
                      "In Progress (${(phase.progress * 100).toInt()}%)",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  if (isFuture && phase.estimatedDate != null)
                    Text(
                      "Estimated Start: ${_formatDate(phase.estimatedDate!)}",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  // Tip card for current phase
                  if (isCurrent) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        phase.tip,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseData {
  final String label;
  final DateTime? completedDate;
  final DateTime? estimatedDate;
  final CropStage stage;
  final double progress;
  final String tip;

  _PhaseData({
    required this.label,
    this.completedDate,
    this.estimatedDate,
    required this.stage,
    required this.progress,
    required this.tip,
  });
}
