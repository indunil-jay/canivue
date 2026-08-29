import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';

/// Post-consultation summary shared into the thread (brief §19) —
/// visually distinct from a plain chat bubble so it reads as a structured
/// record rather than conversation.
class ConsultationSummaryBubble extends StatelessWidget {
  const ConsultationSummaryBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(AppSpacing.md),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(color: isDark ? AppColors.primaryOnDark.withValues(alpha: 0.4) : AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_rounded, size: 16, color: isDark ? AppColors.primaryOnDark : AppColors.primary),
                const SizedBox(width: 6),
                Text('Consultation Summary', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Diagnosis: Mild seasonal allergy', style: theme.textTheme.bodySmall),
            const SizedBox(height: 2),
            Text('Treatment: Antihistamine, 1x daily for 10 days', style: theme.textTheme.bodySmall),
            const SizedBox(height: 2),
            Text('Follow-up: 2 weeks if symptoms persist', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
