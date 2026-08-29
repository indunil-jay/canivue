import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/predictions/domain/prediction.dart';
import 'package:canivue/features/predictions/presentation/controllers/prediction_controller.dart';
import 'package:canivue/features/predictions/presentation/widgets/prediction_card.dart';
import 'package:canivue/features/predictions/presentation/widgets/prediction_status_badge.dart';

/// Full AI-analysis history for one dog (brief §13) — every past
/// prediction with its status, confidence, category, date, model version
/// and outcome, most recent first.
class PredictionHistoryScreen extends ConsumerWidget {
  const PredictionHistoryScreen({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(predictionHistoryProvider(dogId));

    return Scaffold(
      appBar: AppBar(title: Text('$dogName\'s AI Analysis History')),
      body: historyAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 16), child: SkeletonBox(height: 90))),
        ),
        error: (_, _) => ErrorState(
          message: "We couldn't load the prediction history.",
          onRetry: () => ref.invalidate(predictionHistoryProvider(dogId)),
        ),
        data: (predictions) {
          if (predictions.isEmpty) {
            return const EmptyState(
              icon: Icons.auto_awesome_outlined,
              title: 'No AI predictions yet',
              message: 'Run an AI health check to generate the first analysis for this dog.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: predictions.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, index) => _HistoryEntry(prediction: predictions[index]),
          );
        },
      ),
    );
  }
}

class _HistoryEntry extends StatefulWidget {
  const _HistoryEntry({required this.prediction});

  final Prediction prediction;

  @override
  State<_HistoryEntry> createState() => _HistoryEntryState();
}

class _HistoryEntryState extends State<_HistoryEntry> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (_expanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PredictionCard(prediction: widget.prediction, initiallyExpanded: true),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () => setState(() => _expanded = false), child: const Text('Collapse')),
          ),
        ],
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prediction = widget.prediction;

    return InkWell(
      onTap: () => setState(() => _expanded = true),
      borderRadius: AppRadius.xlRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: AppRadius.xlRadius,
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(prediction.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
                      PredictionStatusBadge(status: prediction.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${prediction.category} · ${prediction.confidencePercent.round()}% confidence · ${DateFormat('MMM d, yyyy').format(prediction.predictionDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  ),
                  if (prediction.outcomeNote != null) ...[
                    const SizedBox(height: 6),
                    Text(prediction.outcomeNote!, style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
          ],
        ),
      ),
    );
  }
}
