import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/predictions/domain/prediction.dart';
import 'package:canivue/features/predictions/presentation/widgets/model_contribution_bar.dart';
import 'package:canivue/features/predictions/presentation/widgets/prediction_status_badge.dart';

/// AI disease-prediction card with expandable multi-model explainability
/// (brief §11-12). Uses the "intelligence" indigo accent throughout — never
/// the primary teal — so AI-authored content stays visually distinct from
/// routine health data.
class PredictionCard extends StatefulWidget {
  const PredictionCard({super.key, required this.prediction, this.initiallyExpanded = false});

  final Prediction prediction;
  final bool initiallyExpanded;

  @override
  State<PredictionCard> createState() => _PredictionCardState();
}

class _PredictionCardState extends State<PredictionCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prediction = widget.prediction;
    final intelligence = isDark ? AppColors.intelligenceOnDark : AppColors.intelligence;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: intelligence.withValues(alpha: isDark ? 0.35 : 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Text(prediction.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        PredictionStatusBadge(status: prediction.status),
                        Text(
                          prediction.category,
                          style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _statBlock(context, 'Combined Risk', '${prediction.combinedRiskPercent.round()}%', predictionStatusColor(context, prediction.status)),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: _statBlock(context, 'Confidence', '${prediction.confidencePercent.round()}%', intelligence)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Affected Indicators', style: theme.textTheme.labelMedium?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prediction.affectedIndicators
                .map((indicator) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground,
                        borderRadius: AppRadius.pillRadius,
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Text(indicator, style: theme.textTheme.labelSmall),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.primaryOnDark : AppColors.primary).withValues(alpha: isDark ? 0.12 : 0.06),
              borderRadius: AppRadius.mdRadius,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 18, color: isDark ? AppColors.primaryOnDark : AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(prediction.recommendedNextStep, style: theme.textTheme.bodySmall)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            borderRadius: AppRadius.mdRadius,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Text(
                    _expanded ? 'Hide explanation' : 'Why did the AI make this prediction?',
                    style: theme.textTheme.labelLarge?.copyWith(color: intelligence),
                  ),
                  const SizedBox(width: 4),
                  Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 18, color: intelligence),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: AppMotion.normal,
            curve: AppMotion.standard,
            child: _expanded ? _buildExplainability(context, prediction) : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'AI predictions are decision-support information, not a definitive veterinary diagnosis.',
            style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
          ),
        ],
      ),
    );
  }

  Widget _statBlock(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground,
        borderRadius: AppRadius.mdRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildExplainability(BuildContext context, Prediction prediction) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground,
          borderRadius: AppRadius.mdRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Model Contributions', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            for (final contribution in prediction.modelContributions) ModelContributionBar(contribution: contribution),
            const SizedBox(height: AppSpacing.sm),
            Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            const SizedBox(height: AppSpacing.sm),
            _explainRow(context, 'Historical comparison', prediction.historicalComparisonNote),
            const SizedBox(height: AppSpacing.sm),
            _explainRow(context, 'Data quality', prediction.dataQualityNote),
            const SizedBox(height: AppSpacing.sm),
            _explainRow(
              context,
              'Prediction timestamp',
              '${DateFormat('MMM d, yyyy · h:mm a').format(prediction.predictionDate)} · model ${prediction.modelVersion}',
            ),
            if (prediction.outcomeNote != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _explainRow(context, 'Outcome / follow-up', prediction.outcomeNote!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _explainRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
