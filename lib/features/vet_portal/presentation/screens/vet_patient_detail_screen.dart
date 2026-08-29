import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/health/presentation/widgets/metric_chart_card.dart';
import 'package:canivue/features/predictions/presentation/controllers/prediction_controller.dart';
import 'package:canivue/features/predictions/presentation/widgets/prediction_card.dart';
import 'package:canivue/features/vet_portal/domain/vet_patient.dart';
import 'package:canivue/features/vets/domain/appointment.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';
import 'package:canivue/features/vets/presentation/controllers/appointment_controller.dart';

/// Dense-but-organized professional patient view (brief §34) — reuses the
/// same fake data sources the owner-side screens read from (predictions,
/// metrics, appointments), demonstrating the point of the repository
/// pattern: one source of truth, two role-specific presentations.
class VetPatientDetailScreen extends ConsumerWidget {
  const VetPatientDetailScreen({super.key, required this.patient});

  final VetPatient patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final predictionAsync = ref.watch(latestPredictionProvider(patient.dogId));
    final appointmentsAsync = ref.watch(appointmentsProvider(patient.dogId));

    return Scaffold(
      appBar: AppBar(title: Text(patient.dogName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: AppRadius.xlRadius),
            child: Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
                  child: const Icon(Icons.pets_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${patient.dogName} · ${patient.breed}', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('${patient.ageFormatted} · Owner: ${patient.ownerName}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (patient.hasCriticalAlert)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.xxl),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.errorOnDark : AppColors.error).withValues(alpha: isDark ? 0.16 : 0.08),
                borderRadius: AppRadius.mdRadius,
                border: Border.all(color: (isDark ? AppColors.errorOnDark : AppColors.error).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_rounded, color: isDark ? AppColors.errorOnDark : AppColors.error),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(child: Text('This patient has a critical alert requiring review.')),
                ],
              ),
            ),
          Text('Medical Info', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: AppRadius.xlRadius,
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _chipRow(context, 'Allergies', patient.allergies, isDark ? AppColors.errorOnDark : AppColors.error),
                const SizedBox(height: AppSpacing.md),
                _chipRow(context, 'Existing Conditions', patient.existingConditions, isDark ? AppColors.warningOnDark : AppColors.warning),
                const SizedBox(height: AppSpacing.md),
                _chipRow(context, 'Current Medications', patient.currentMedications, isDark ? AppColors.primaryOnDark : AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('AI Prediction', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          predictionAsync.when(
            loading: () => SkeletonBox(height: 160, borderRadius: AppRadius.xlRadius),
            error: (_, _) => const SizedBox.shrink(),
            data: (prediction) => prediction == null
                ? const EmptyState(icon: Icons.auto_awesome_outlined, title: 'No active predictions', message: 'Nothing flagged by the AI models right now.')
                : PredictionCard(prediction: prediction),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Health Trends', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          MetricChartCard(dogId: patient.dogId),
          const SizedBox(height: AppSpacing.xxl),
          Text('Appointment History', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          appointmentsAsync.when(
            loading: () => SkeletonBox(height: 80, borderRadius: AppRadius.xlRadius),
            error: (_, _) => const SizedBox.shrink(),
            data: (appointments) {
              if (appointments.isEmpty) {
                return const EmptyState(icon: Icons.event_busy_rounded, title: 'No appointment history', message: 'Past consultations with this patient will appear here.');
              }
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: AppRadius.xlRadius,
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < appointments.length; i++) ...[
                      if (i > 0) Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ListTile(
                        leading: Icon(appointments[i].consultationType == ConsultationType.video ? Icons.videocam_rounded : Icons.local_hospital_rounded),
                        title: Text(DateFormat('MMM d, yyyy').format(appointments[i].dateTime)),
                        subtitle: Text(appointments[i].notes.isEmpty ? appointments[i].status.label : appointments[i].notes),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _chipRow(BuildContext context, String label, List<String> items, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
          const SizedBox(height: 4),
          Text('None reported', style: theme.textTheme.bodySmall),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: color.withValues(alpha: isDark ? 0.16 : 0.08), borderRadius: AppRadius.pillRadius, border: Border.all(color: color.withValues(alpha: 0.35))),
                    child: Text(item, style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
