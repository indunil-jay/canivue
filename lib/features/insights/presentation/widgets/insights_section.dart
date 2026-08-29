import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/insights/domain/health_insight.dart';
import 'package:canivue/features/insights/presentation/controllers/insights_controller.dart';

/// Long-term health insights (brief §30) — trend statements, not raw data.
class InsightsSection extends ConsumerWidget {
  const InsightsSection({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(healthInsightsProvider((id: dogId, name: dogName)));

    return insightsAsync.when(
      loading: () => Column(children: List.generate(2, (_) => const Padding(padding: EdgeInsets.only(bottom: 10), child: SkeletonBox(height: 56)))),
      error: (_, _) => ErrorState(message: "We couldn't load insights.", onRetry: () => ref.invalidate(healthInsightsProvider((id: dogId, name: dogName)))),
      data: (insights) => Column(children: [for (final insight in insights) _InsightRow(insight: insight)]),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.insight});

  final HealthInsight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = insight.isPositive ? (isDark ? AppColors.successOnDark : AppColors.success) : (isDark ? AppColors.warningOnDark : AppColors.warning);
    final icon = switch (insight.direction) {
      TrendDirection.up => Icons.trending_up_rounded,
      TrendDirection.down => Icons.trending_down_rounded,
      TrendDirection.stable => Icons.trending_flat_rounded,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.headline, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(insight.detail, style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
