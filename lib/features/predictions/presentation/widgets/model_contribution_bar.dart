import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/predictions/domain/prediction.dart';

/// One row of the multi-model explainability view: "Activity Model — 82%"
/// rendered as a labelled horizontal bar, per brief §12.
class ModelContributionBar extends StatelessWidget {
  const ModelContributionBar({super.key, required this.contribution});

  final ModelContribution contribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barColor = isDark ? AppColors.intelligenceOnDark : AppColors.intelligence;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(contribution.modelName, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              Text(
                '${contribution.contributionPercent.round()}%',
                style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: barColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: AppRadius.xsRadius,
            child: LinearProgressIndicator(
              value: contribution.contributionPercent / 100,
              minHeight: 6,
              backgroundColor: isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
