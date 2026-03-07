import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/prediction_controller.dart';

/// AI Insights section matching the mockup design:
/// - Section header with sparkle icon
/// - Yield Prediction card (big number + trend)
/// - Risk Alert card with colored left border
class AiInsightCard extends StatelessWidget {
  final PredictionController controller;

  const AiInsightCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              "AI Insights",
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Yield Prediction Card ──
        _buildYieldPredictionCard(context),
        const SizedBox(height: 14),

        // ── Risk Alert Card ──
        Obx(() {
          if (controller.predictionResults.isEmpty) {
            return _buildSafeCard(context);
          }
          return _buildRiskAlertCard(context);
        }),

        // ── AI Loading / Advice ──
        Obx(() {
          if (controller.isLoadingAI.value) {
            return Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _buildLoadingCard(context),
            );
          }
          if (controller.aiAdvice.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _buildAdviceCard(context),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  YIELD PREDICTION CARD (mockup: big number, trend)
  // ═══════════════════════════════════════════════════════════
  Widget _buildYieldPredictionCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "YIELD PREDICTION",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface.withOpacity(0.6),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                "Updated 2h ago",
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Big yield number
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "4.2",
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "Tons / Ha",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Trend text
          Text(
            "Projected yield is +12% above average due to optimal weather conditions.",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.6),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  RISK ALERT CARD (mockup: colored left border)
  // ═══════════════════════════════════════════════════════════
  Widget _buildRiskAlertCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final topRisk = controller.predictionResults.first;

    final severity = topRisk.percentage;
    Color riskColor;
    String riskTitle;

    if (severity > 0.7) {
      riskColor = Colors.red.shade600;
      riskTitle = "High Risk of ${topRisk.pestName}";
    } else if (severity > 0.4) {
      riskColor = Colors.orange.shade600;
      riskTitle = "Moderate Risk of ${topRisk.pestName}";
    } else {
      riskColor = Colors.amber.shade700;
      riskTitle = "Low Risk of ${topRisk.pestName}";
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Colored left strip
          Container(
            width: 5,
            height: 130,
            decoration: BoxDecoration(
              color: riskColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Risk icon + label
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: riskColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "RISK ALERT",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: riskColor,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Risk title
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: riskColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          riskTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    topRisk.shortDescription,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.6),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "View Prevention Tips →",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  SAFE CARD (no risks)
  // ═══════════════════════════════════════════════════════════
  Widget _buildSafeCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 44,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 10),
          Text(
            "Lahan Aman",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Tidak ada risiko hama signifikan terdeteksi.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  LOADING & ADVICE CARDS
  // ═══════════════════════════════════════════════════════════
  Widget _buildLoadingCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: colorScheme.tertiary, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            "AI sedang menyusun saran...",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: colorScheme.primary, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "Saran Cerdas",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "AI",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            controller.aiAdvice.value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
