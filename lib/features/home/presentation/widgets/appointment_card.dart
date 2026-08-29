import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/home/domain/dashboard_summary.dart';

/// Upcoming veterinary appointment preview, with a real empty state for
/// "nothing booked" (brief §36 — never just the happy path).
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onBook,
    required this.onViewAppointments,
  });

  final UpcomingAppointment? appointment;
  final VoidCallback onBook;
  final VoidCallback onViewAppointments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appointment = this.appointment;

    if (appointment == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_busy_rounded,
              color: isDark
                  ? AppColors.darkMutedText
                  : AppColors.lightMutedText,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'No upcoming veterinary appointments',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            TextButton(onPressed: onBook, child: const Text('Book')),
          ],
        ),
      );
    }

    final formatted = DateFormat('EEE, MMM d · h:mm a')
        .format(appointment.time);

    return InkWell(
      onTap: onViewAppointments,
      borderRadius: AppRadius.lgRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: AppRadius.mdRadius,
              ),
              child: Icon(
                appointment.isVideoCall
                    ? Icons.videocam_rounded
                    : Icons.local_hospital_rounded,
                color: isDark ? AppColors.primaryOnDark : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${appointment.vetName} · ${appointment.clinic}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    formatted,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.darkMutedText
                  : AppColors.lightMutedText,
            ),
          ],
        ),
      ),
    );
  }
}
