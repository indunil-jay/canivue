import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/home/domain/dashboard_summary.dart';

/// Surfaces the single most relevant AI-generated insight for the active
/// dog. Deliberately uses the "intelligence" indigo accent (never the
/// primary teal) so AI-driven content reads as visually distinct from
/// routine health data, per the `canivue-architecture` color convention.
class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key, required this.insight});

  final AiInsight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.intelligenceOnDark : AppColors.intelligence;

    return InkWell(
      borderRadius: AppRadius.xlRadius,
      onTap: () => AppFeedback.showToast(
        context,
        title: 'AI Health Insight',
        message: 'Full explainability & prediction history arrive in a future update.',
        type: ToastType.info,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: AppRadius.xlRadius,
          border: Border.all(color: accent.withValues(alpha: isDark ? 0.35 : 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(gradient: AppColors.intelligenceGradient, borderRadius: AppRadius.mdRadius),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          insight.headline,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (insight.risk != RiskLevel.normal) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _RiskBadge(risk: insight.risk),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight.detail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'AI decision-support — not a veterinary diagnosis.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.risk});

  final RiskLevel risk;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (label, color) = switch (risk) {
      RiskLevel.monitoring => ('Monitoring', isDark ? AppColors.warningOnDark : AppColors.warning),
      RiskLevel.elevated => ('Elevated', isDark ? AppColors.errorOnDark : AppColors.error),
      RiskLevel.normal => ('Normal', isDark ? AppColors.successOnDark : AppColors.success),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
    );
  }
}
