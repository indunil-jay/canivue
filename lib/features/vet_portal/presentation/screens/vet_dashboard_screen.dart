import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/notifications/widgets/notification_badge_button.dart';
import 'package:canivue/features/vet_portal/domain/vet_dashboard_summary.dart';
import 'package:canivue/features/vet_portal/presentation/controllers/vet_portal_controller.dart';

/// Veterinarian dashboard (brief §33) — prioritized for efficiency: what
/// needs attention right now, then today's schedule and recent activity.
class VetDashboardScreen extends ConsumerWidget {
  const VetDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final vetName = user?.name.isNotEmpty == true ? user!.name : 'Doctor';
    final dashboardAsync = ref.watch(vetDashboardProvider(vetName));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome back, $vetName'),
        actions: const [NotificationBadgeButton(), SizedBox(width: 8)],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(vetDashboardProvider(vetName)),
        child: dashboardAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 16), child: SkeletonBox(height: 100))),
          ),
          error: (_, _) => ErrorState(message: "We couldn't load your dashboard.", onRetry: () => ref.invalidate(vetDashboardProvider(vetName))),
          data: (summary) => ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(child: _statCard(context, '${summary.waitingConsultationCount}', 'Waiting', Icons.hourglass_top_rounded, isDark ? AppColors.warningOnDark : AppColors.warning)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _statCard(context, '${summary.criticalAlertCount}', 'Critical Alerts', Icons.warning_rounded, isDark ? AppColors.errorOnDark : AppColors.error)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _statCard(context, '${summary.newPatientCount}', 'New Patients', Icons.person_add_rounded, isDark ? AppColors.primaryOnDark : AppColors.primary)),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text("Today's Schedule", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: AppRadius.xlRadius,
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < summary.todaySchedule.length; i++) ...[
                      if (i > 0) Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      _scheduleTile(context, summary.todaySchedule[i]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text('Recent Messages', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              for (final message in summary.recentMessages)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: AppRadius.mdRadius,
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(message.ownerName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text(message.preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Text(message.timeAgo, style: theme.textTheme.labelSmall),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String value, String label, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
        ],
      ),
    );
  }

  Widget _scheduleTile(BuildContext context, ScheduleEntry entry) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ListTile(
      leading: Icon(entry.type == 'Video Call' ? Icons.videocam_rounded : Icons.local_hospital_rounded, color: isDark ? AppColors.primaryOnDark : AppColors.primary),
      title: Text('${entry.dogName} · ${entry.ownerName}'),
      subtitle: Text('${entry.time} · ${entry.type}'),
      trailing: entry.confirmed
          ? Icon(Icons.check_circle_rounded, size: 18, color: isDark ? AppColors.successOnDark : AppColors.success)
          : Icon(Icons.schedule_rounded, size: 18, color: isDark ? AppColors.warningOnDark : AppColors.warning),
    );
  }
}
