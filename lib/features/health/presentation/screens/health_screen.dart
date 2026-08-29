import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/components/timeline_tile.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/health/domain/health_timeline_event.dart';
import 'package:canivue/features/health/presentation/controllers/health_timeline_controller.dart';
import 'package:canivue/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:canivue/features/home/presentation/widgets/active_dog_switcher.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/pets/presentation/controllers/dogs_controller.dart';
import 'package:canivue/features/pets/screens/pet_list_screen.dart';

/// Owner shell "Health" tab — the detailed health profile for the active
/// dog (brief §9-10, §31): vitals summary, medical info, and the full
/// healthcare-journey timeline. Complements the Home dashboard's
/// today-focused snapshot rather than repeating it.
class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDogAsync = ref.watch(activeDogProvider);
    final dogsAsync = ref.watch(dogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Health')),
      body: SafeArea(
        child: activeDogAsync.when(
          loading: () => const _HealthSkeleton(),
          error: (error, _) => ErrorState(
            message: "We couldn't load your dogs. Pull down to try again.",
            onRetry: () => ref.invalidate(dogsProvider),
          ),
          data: (activeDog) {
            if (activeDog == null) {
              return EmptyState(
                icon: Icons.pets_rounded,
                title: 'No dog profile yet',
                message: 'Add a dog to start building their health profile.',
                actionLabel: 'Add a Dog',
                onAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PetListScreen())),
              );
            }

            final dogs = dogsAsync.value ?? [activeDog];

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dashboardSummaryProvider((id: activeDog.id, name: activeDog.name)));
                ref.invalidate(healthTimelineProvider(activeDog.id));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ActiveDogSwitcher(dogs: dogs, activeDog: activeDog),
                    const SizedBox(height: AppSpacing.xl),
                    _HealthScoreBanner(dog: activeDog),
                    const SizedBox(height: AppSpacing.xxl),
                    _sectionTitle(context, 'Medical Info'),
                    const SizedBox(height: AppSpacing.sm),
                    _MedicalInfoCard(dog: activeDog),
                    const SizedBox(height: AppSpacing.xxl),
                    _sectionTitle(context, 'Vaccinations'),
                    const SizedBox(height: AppSpacing.sm),
                    _VaccinationsList(dog: activeDog),
                    const SizedBox(height: AppSpacing.xxl),
                    _sectionTitle(context, 'Health Timeline'),
                    const SizedBox(height: AppSpacing.sm),
                    _HealthTimeline(dogId: activeDog.id),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
  }
}

class _HealthScoreBanner extends ConsumerWidget {
  const _HealthScoreBanner({required this.dog});

  final Pet dog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider((id: dog.id, name: dog.name)));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return summaryAsync.when(
      loading: () => SkeletonBox(height: 96, borderRadius: AppRadius.xlRadius),
      error: (_, _) => const SizedBox.shrink(),
      data: (summary) {
        final scoreColor = summary.healthScore >= 90
            ? (isDark ? AppColors.successOnDark : AppColors.success)
            : summary.healthScore >= 75
                ? (isDark ? AppColors.warningOnDark : AppColors.warning)
                : (isDark ? AppColors.errorOnDark : AppColors.error);

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: AppRadius.xlRadius,
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: scoreColor, width: 3)),
                child: Center(
                  child: Text('${summary.healthScore}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: scoreColor)),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overall Health Score', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '${summary.vitals.heartRateBpm} bpm · ${summary.vitals.temperatureC.toStringAsFixed(1)}°C · ${summary.vitals.weightKg.toStringAsFixed(1)} kg',
                      style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MedicalInfoCard extends StatelessWidget {
  const _MedicalInfoCard({required this.dog});

  final Pet dog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(context, 'Allergies', dog.allergies, isDark ? AppColors.errorOnDark : AppColors.error),
          if (dog.existingConditions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _infoRow(context, 'Existing Conditions', dog.existingConditions, isDark ? AppColors.warningOnDark : AppColors.warning),
          ],
          if (dog.medications.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Medications', style: theme.textTheme.labelMedium?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
            const SizedBox(height: 6),
            for (final med in dog.medications)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('${med.name} — ${med.dosage}, ${med.frequency}', style: theme.textTheme.bodySmall),
              ),
          ],
          if (dog.insurance != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Insurance', style: theme.textTheme.labelMedium?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
            const SizedBox(height: 4),
            Text(
              '${dog.insurance!.provider} · Policy ${dog.insurance!.policyNumber} · Expires ${DateFormat('MMM d, yyyy').format(dog.insurance!.expiryDate)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, List<String> items, Color chipColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: isDark ? 0.16 : 0.08),
                    borderRadius: AppRadius.pillRadius,
                    border: Border.all(color: chipColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(item, style: theme.textTheme.labelSmall?.copyWith(color: chipColor, fontWeight: FontWeight.bold)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _VaccinationsList extends StatelessWidget {
  const _VaccinationsList({required this.dog});

  final Pet dog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (dog.vaccinations.isEmpty) {
      return EmptyState(
        icon: Icons.vaccines_outlined,
        title: 'No vaccination records',
        message: 'Vaccination history will appear here once added.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          for (int i = 0; i < dog.vaccinations.length; i++) ...[
            if (i > 0) Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            _vaccinationTile(context, dog.vaccinations[i], isDark),
          ],
        ],
      ),
    );
  }

  Widget _vaccinationTile(BuildContext context, VaccinationRecord record, bool isDark) {
    final theme = Theme.of(context);
    final overdue = record.nextDueDate != null && record.nextDueDate!.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(Icons.vaccines_rounded, size: 20, color: isDark ? AppColors.primaryOnDark : AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  'Given ${DateFormat('MMM d, yyyy').format(record.dateGiven)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),
          if (record.nextDueDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (overdue ? AppColors.error : AppColors.success).withValues(alpha: isDark ? 0.16 : 0.08),
                borderRadius: AppRadius.pillRadius,
              ),
              child: Text(
                overdue ? 'Overdue' : 'Due ${DateFormat('MMM yyyy').format(record.nextDueDate!)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: overdue ? (isDark ? AppColors.errorOnDark : AppColors.error) : (isDark ? AppColors.successOnDark : AppColors.success),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HealthTimeline extends ConsumerWidget {
  const _HealthTimeline({required this.dogId});

  final String dogId;

  IconData _iconFor(TimelineEventType type) => switch (type) {
        TimelineEventType.vaccination => Icons.vaccines_rounded,
        TimelineEventType.medication => Icons.medication_rounded,
        TimelineEventType.weightChange => Icons.monitor_weight_rounded,
        TimelineEventType.diagnosis => Icons.assignment_rounded,
        TimelineEventType.appointment => Icons.event_available_rounded,
        TimelineEventType.aiPrediction => Icons.auto_awesome_rounded,
        TimelineEventType.healthAlert => Icons.warning_amber_rounded,
        TimelineEventType.sensorEvent => Icons.sensors_rounded,
      };

  Color _colorFor(BuildContext context, TimelineEventType type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (type) {
      TimelineEventType.healthAlert => isDark ? AppColors.errorOnDark : AppColors.error,
      TimelineEventType.aiPrediction => isDark ? AppColors.intelligenceOnDark : AppColors.intelligence,
      TimelineEventType.diagnosis => isDark ? AppColors.warningOnDark : AppColors.warning,
      _ => isDark ? AppColors.primaryOnDark : AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(healthTimelineProvider(dogId));

    return timelineAsync.when(
      loading: () => Column(children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBox(height: 56)))),
      error: (_, _) => ErrorState(message: "We couldn't load the health timeline.", onRetry: () => ref.invalidate(healthTimelineProvider(dogId))),
      data: (events) {
        if (events.isEmpty) {
          return const EmptyState(icon: Icons.timeline_rounded, title: 'No health events yet', message: 'Vaccinations, checkups and AI insights will build this timeline over time.');
        }

        return Column(
          children: [
            for (int i = 0; i < events.length; i++)
              TimelineTile(
                icon: _iconFor(events[i].type),
                color: _colorFor(context, events[i].type),
                title: events[i].title,
                subtitle: events[i].description,
                dateLabel: DateFormat('MMM d, yyyy').format(events[i].date),
                isFirst: i == 0,
                isLast: i == events.length - 1,
              ),
          ],
        );
      },
    );
  }
}

class _HealthSkeleton extends StatelessWidget {
  const _HealthSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(height: 76, width: double.infinity, borderRadius: BorderRadius.zero),
          const SizedBox(height: AppSpacing.xl),
          SkeletonBox(height: 96, borderRadius: AppRadius.xlRadius),
          const SizedBox(height: AppSpacing.xxl),
          SkeletonBox(height: 140, borderRadius: AppRadius.xlRadius),
        ],
      ),
    );
  }
}
