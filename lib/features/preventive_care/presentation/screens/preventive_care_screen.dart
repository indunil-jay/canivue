import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/preventive_care/domain/care_task.dart';
import 'package:canivue/features/preventive_care/presentation/controllers/care_task_controller.dart';

IconData _iconFor(CareTaskCategory category) => switch (category) {
      CareTaskCategory.vaccination => Icons.vaccines_rounded,
      CareTaskCategory.deworming => Icons.bug_report_rounded,
      CareTaskCategory.fleaTick => Icons.pest_control_rounded,
      CareTaskCategory.dental => Icons.medical_information_rounded,
      CareTaskCategory.grooming => Icons.content_cut_rounded,
      CareTaskCategory.annualCheck => Icons.event_available_rounded,
      CareTaskCategory.weightGoal => Icons.monitor_weight_rounded,
      CareTaskCategory.medication => Icons.medication_rounded,
    };

/// Full "What's Due" preventive-care list (brief §21) — the Home dashboard
/// only ever previews the next couple of items; this is the complete list
/// with the ability to mark a task done.
class PreventiveCareScreen extends ConsumerWidget {
  const PreventiveCareScreen({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(careTaskControllerProvider(dogId));

    return Scaffold(
      appBar: AppBar(title: Text('$dogName\'s Preventive Care')),
      body: tasksAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: List.generate(4, (_) => const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBox(height: 64))),
        ),
        error: (_, _) => ErrorState(message: "We couldn't load preventive care tasks.", onRetry: () => ref.invalidate(careTaskControllerProvider(dogId))),
        data: (tasks) {
          final pending = tasks.where((t) => !t.completed).toList();
          final done = tasks.where((t) => t.completed).toList();

          if (tasks.isEmpty) {
            return const EmptyState(icon: Icons.check_circle_outline_rounded, title: 'Nothing scheduled', message: 'Preventive care tasks will appear here as they come due.');
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (pending.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.08), borderRadius: AppRadius.lgRadius),
                  child: Row(children: [Icon(Icons.check_circle_rounded, color: AppColors.success), const SizedBox(width: 12), const Expanded(child: Text('All caught up!'))]),
                )
              else
                for (final task in pending) _TaskTile(task: task, dogId: dogId),
              if (done.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xxl),
                Text('Completed', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                for (final task in done) _TaskTile(task: task, dogId: dogId),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task, required this.dogId});

  final CareTask task;
  final String dogId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = task.completed
        ? (isDark ? AppColors.darkMutedText : AppColors.lightMutedText)
        : task.isOverdue
            ? (isDark ? AppColors.errorOnDark : AppColors.error)
            : (isDark ? AppColors.warningOnDark : AppColors.warning);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Icon(_iconFor(task.category), color: color, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, decoration: task.completed ? TextDecoration.lineThrough : null),
                ),
                Text(
                  '${task.category.label} · ${task.completed ? 'Completed' : task.isOverdue ? 'Overdue' : 'Due ${DateFormat('MMM d').format(task.dueDate)}'}',
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
          if (!task.completed)
            Checkbox(value: false, onChanged: (_) => ref.read(careTaskControllerProvider(dogId).notifier).markDone(task.id))
          else
            Icon(Icons.check_circle_rounded, color: color, size: 20),
        ],
      ),
    );
  }
}
