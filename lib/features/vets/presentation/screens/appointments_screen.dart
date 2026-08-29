import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/vets/domain/appointment.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';
import 'package:canivue/features/vets/presentation/controllers/appointment_controller.dart';

Color _statusColor(BuildContext context, AppointmentStatus status) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return switch (status) {
    AppointmentStatus.confirmed || AppointmentStatus.upcoming => isDark ? AppColors.primaryOnDark : AppColors.primary,
    AppointmentStatus.completed => isDark ? AppColors.successOnDark : AppColors.success,
    AppointmentStatus.requested || AppointmentStatus.inProgress => isDark ? AppColors.warningOnDark : AppColors.warning,
    AppointmentStatus.cancelled || AppointmentStatus.noShow => isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
  };
}

/// Appointment history for one dog (brief §18) — every state from
/// requested through completed/cancelled/no-show, not just a happy-path
/// upcoming list.
class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider(dogId));

    return Scaffold(
      appBar: AppBar(title: Text('$dogName\'s Appointments')),
      body: appointmentsAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 16), child: SkeletonBox(height: 84))),
        ),
        error: (_, _) => ErrorState(message: "We couldn't load appointments.", onRetry: () => ref.invalidate(appointmentsProvider(dogId))),
        data: (appointments) {
          if (appointments.isEmpty) {
            return const EmptyState(icon: Icons.event_busy_rounded, title: 'No appointments yet', message: 'Book a veterinary consultation to see it here.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: appointments.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              final color = _statusColor(context, appointment.status);

              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: AppRadius.xlRadius,
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      appointment.consultationType == ConsultationType.video ? Icons.videocam_rounded : Icons.local_hospital_rounded,
                      color: color,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appointment.vetName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            DateFormat('EEE, MMM d · h:mm a').format(appointment.dateTime),
                            style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: color.withValues(alpha: isDark ? 0.18 : 0.1), borderRadius: AppRadius.pillRadius),
                      child: Text(appointment.status.label, style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
