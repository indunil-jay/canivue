import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/notifications/widgets/notification_badge_button.dart';
import 'package:canivue/features/vet_portal/domain/vet_dashboard_summary.dart';
import 'package:canivue/features/vet_portal/presentation/controllers/vet_portal_controller.dart';

/// Veterinarian dashboard: prioritized clinic overview, consultation requests,
/// critical canine telemetry alerts, and today's schedule.
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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: true,
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(vetDashboardProvider(vetName)),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // 1. Editorial Header matching Home Screen vibe
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDark ? const Color(0x4414B8A6) : const Color(0xFFBFE7DC),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🩺', style: TextStyle(fontSize: 12)),
                                    const SizedBox(width: 5),
                                    Text(
                                      'CLINICAL PORTAL',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.primaryOnDark : AppColors.primary,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Welcome, $vetName',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const NotificationBadgeButton(),
                      ],
                    ),
                  ),
                ),

                // 2. Main Dashboard Content
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                  sliver: dashboardAsync.when(
                    loading: () => SliverList(
                      delegate: SliverChildListDelegate([
                        const SkeletonBox(height: 110, borderRadius: BorderRadius.all(Radius.circular(24))),
                        const SizedBox(height: 16),
                        const SkeletonBox(height: 160, borderRadius: BorderRadius.all(Radius.circular(24))),
                      ]),
                    ),
                    error: (_, _) => SliverToBoxAdapter(
                      child: ErrorState(
                        message: "We couldn't load your dashboard.",
                        onRetry: () => ref.invalidate(vetDashboardProvider(vetName)),
                      ),
                    ),
                    data: (summary) => SliverList(
                      delegate: SliverChildListDelegate([
                        // Quick Metric Cards Row
                        Row(
                          children: [
                            Expanded(
                              child: _pastelStatCard(
                                value: '${summary.waitingConsultationCount}',
                                label: 'Waiting',
                                icon: Icons.hourglass_top_rounded,
                                accentColor: const Color(0xFFF59E0B),
                                pastelColor: AppColors.pastelAmber,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _pastelStatCard(
                                value: '${summary.criticalAlertCount}',
                                label: 'Alerts',
                                icon: Icons.warning_rounded,
                                accentColor: const Color(0xFFF43F5E),
                                pastelColor: AppColors.softBlush,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _pastelStatCard(
                                value: '${summary.newPatientCount}',
                                label: 'New Dogs',
                                icon: Icons.pets_rounded,
                                accentColor: const Color(0xFF10B981),
                                pastelColor: AppColors.pastelMint,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Today's Schedule Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Today's Schedule",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  '${summary.todaySchedule.length} appointments booked today',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Column(
                              children: [
                                for (int i = 0; i < summary.todaySchedule.length; i++) ...[
                                  if (i > 0)
                                    Divider(
                                      height: 1,
                                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                    ),
                                  _scheduleTile(context, summary.todaySchedule[i], isDark),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Recent Patient Messages Section
                        Row(
                          children: [
                            Text(
                              'Recent Patient Enquiries',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        for (final message in summary.recentMessages)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 42,
                                  width: 42,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Center(
                                    child: Text('🐶', style: TextStyle(fontSize: 18)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.ownerName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14.5,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        message.preview,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  message.timeAgo,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pastelStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color accentColor,
    required Color pastelColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? accentColor.withValues(alpha: 0.14) : pastelColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF181A20),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF57534E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleTile(BuildContext context, ScheduleEntry entry, bool isDark) {
    final isVideo = entry.type == 'Video Call';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isVideo ? Icons.videocam_rounded : Icons.local_hospital_rounded,
              color: const Color(0xFF0F766E),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.dogName} (${entry.ownerName})',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.time} · ${entry.type}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: (entry.confirmed ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  entry.confirmed ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  size: 13,
                  color: entry.confirmed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 4),
                Text(
                  entry.confirmed ? 'Confirmed' : 'Pending',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: entry.confirmed ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
