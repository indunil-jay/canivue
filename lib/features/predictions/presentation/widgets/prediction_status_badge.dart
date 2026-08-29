import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/predictions/domain/prediction.dart';

Color predictionStatusColor(BuildContext context, PredictionStatus status) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return switch (status) {
    PredictionStatus.monitoring => isDark ? AppColors.intelligenceOnDark : AppColors.intelligence,
    PredictionStatus.lowRisk => isDark ? AppColors.successOnDark : AppColors.success,
    PredictionStatus.moderateRisk => isDark ? AppColors.warningOnDark : AppColors.warning,
    PredictionStatus.highRisk => isDark ? AppColors.errorOnDark : AppColors.error,
    PredictionStatus.resolved => isDark ? AppColors.successOnDark : AppColors.success,
    PredictionStatus.vetReviewRecommended => isDark ? AppColors.warningOnDark : AppColors.warning,
  };
}

/// Status pill shared by the prediction card and prediction history list.
class PredictionStatusBadge extends StatelessWidget {
  const PredictionStatusBadge({super.key, required this.status});

  final PredictionStatus status;

  @override
  Widget build(BuildContext context) {
    final color = predictionStatusColor(context, status);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(status.label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
    );
  }
}
