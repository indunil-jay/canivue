import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/home/domain/dashboard_summary.dart';

/// The home dashboard's "What's Due" preventive-care preview (brief §21).
class CareRemindersSection extends StatelessWidget {
  const CareRemindersSection({super.key, required this.reminders});

  final List<CareReminder> reminders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (reminders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: isDark ? AppColors.successOnDark : AppColors.success, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text("All caught up — nothing due right now.", style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: reminders.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) => _ReminderCard(reminder: reminders[index]),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder});

  final CareReminder reminder;

  (IconData, Color) _style(bool isDark) {
    final overdue = reminder.isOverdue;
    final color = overdue ? (isDark ? AppColors.errorOnDark : AppColors.error) : (isDark ? AppColors.warningOnDark : AppColors.warning);
    final icon = switch (reminder.kind) {
      ReminderKind.vaccination => Icons.vaccines_rounded,
      ReminderKind.medication => Icons.medication_rounded,
      ReminderKind.grooming => Icons.content_cut_rounded,
      ReminderKind.checkup => Icons.event_available_rounded,
      ReminderKind.deworming => Icons.bug_report_rounded,
    };
    return (icon, color);
  }

  String _dueLabel() {
    final days = reminder.dueDate.difference(DateTime.now()).inDays;
    if (reminder.isOverdue) return 'Overdue';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final (icon, color) = _style(isDark);

    return Container(
      width: 190,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          Text(reminder.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          Text(_dueLabel(), style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
