import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/core/widgets/luxury_biometric_ring.dart';
import 'package:canivue/core/widgets/luxury_stat_card.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/health_check/screens/health_check_capture_screen.dart';
import 'package:canivue/features/home/domain/dashboard_summary.dart';
import 'package:canivue/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:canivue/features/home/presentation/widgets/active_dog_switcher.dart';
import 'package:canivue/features/home/presentation/widgets/ai_insight_card.dart';
import 'package:canivue/features/home/presentation/widgets/appointment_card.dart';
import 'package:canivue/features/home/presentation/widgets/care_reminders_section.dart';
import 'package:canivue/features/home/presentation/widgets/device_status_chip.dart';
import 'package:canivue/features/notifications/widgets/notification_badge_button.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/pets/presentation/controllers/dogs_controller.dart';
import 'package:canivue/features/pets/screens/pet_detail_screen.dart';
import 'package:canivue/features/pets/screens/pet_list_screen.dart';

/// The "Home" tab of the owner shell — see [OwnerShell] for the bottom
/// navigation and other tabs. User identity comes from
/// [authControllerProvider]; the dog shown comes from [activeDogProvider] —
/// switching the active dog re-scopes the whole dashboard (brief §7-8).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _displayName(String? userName, String userEmail) {
    if (userName != null && userName.isNotEmpty) {
      return userName;
    }
    final emailPrefix = userEmail.split('@').first;
    if (emailPrefix.isNotEmpty) {
      return emailPrefix[0].toUpperCase() + emailPrefix.substring(1);
    }
    return 'Pet Parent';
  }

  void _navigateToPets(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PetListScreen()));
  }

  void _navigateToHealthCheck(BuildContext context, List<Pet> dogs, {Pet? initialPet}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthCheckCaptureScreen(pets: dogs, initialPet: initialPet),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authControllerProvider);
    final displayName = _displayName(user?.name, user?.email ?? 'user@example.com');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.pets_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $displayName 👋',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                  Text(
                    'Canine Health Intelligence',
                    style: GoogleFonts.plusJakartaSans(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: const [NotificationBadgeButton(), SizedBox(width: 8)],
      ),
      body: _buildBody(context, ref, theme, isDark),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ThemeData theme, bool isDark) {
    final dogsAsync = ref.watch(dogsProvider);
    final activeDogAsync = ref.watch(activeDogProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dogsProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(isDark),
              const SizedBox(height: AppSpacing.xl),
              activeDogAsync.when(
                loading: () => const _DashboardSkeleton(),
                error: (error, _) => ErrorState(
                  message: 'We couldn\'t load your dogs. Pull down to try again.',
                  onRetry: () => ref.invalidate(dogsProvider),
                ),
                data: (activeDog) {
                  if (activeDog == null) {
                    return EmptyState(
                      icon: Icons.pets_rounded,
                      title: 'Add your first dog',
                      message: 'Create a dog profile to start tracking health, activity and AI insights.',
                      actionLabel: 'Add a Dog',
                      onAction: () => _navigateToPets(context),
                    );
                  }

                  final dogs = dogsAsync.value ?? [activeDog];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ActiveDogSwitcher(dogs: dogs, activeDog: activeDog),
                      const SizedBox(height: AppSpacing.xl),
                      _DashboardContent(dog: activeDog, dogs: dogs),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.section),
              _buildQuickServicesHeader(isDark),
              const SizedBox(height: AppSpacing.lg),
              _buildQuickServicesGrid(context, ref, isDark, dogsAsync.value ?? const []),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search dogs, health telemetry, records...',
                hintStyle: GoogleFonts.plusJakartaSans(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServicesHeader(bool isDark) {
    return Text(
      'Quick Services',
      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF0F172A), letterSpacing: -0.3),
    );
  }

  Widget _buildQuickServicesGrid(BuildContext context, WidgetRef ref, bool isDark, List<Pet> dogs) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.22,
      children: [
        _buildServiceCard(
          title: 'Health Check',
          subtitle: 'Multimodal AI Vision',
          icon: Icons.health_and_safety_rounded,
          gradient: AppTheme.primaryGradient,
          isDark: isDark,
          onTap: () => _navigateToHealthCheck(context, dogs),
        ),
        _buildServiceCard(
          title: 'Vaccinations',
          subtitle: 'Schedule & Alerts',
          icon: Icons.vaccines_rounded,
          gradient: const LinearGradient(colors: [Color(0xFF0E7490), Color(0xFF06B6B0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          isDark: isDark,
          onTap: () => AppFeedback.showToast(
            context,
            title: 'Vaccination Tracker 💉',
            message: 'All core vaccinations (Rabies, DHPP) are up to date for your dogs.',
            type: ToastType.info,
          ),
        ),
        _buildServiceCard(
          title: 'Dog Telemetry',
          subtitle: 'Collar & Biometrics',
          icon: Icons.bluetooth_connected_rounded,
          gradient: AppTheme.indigoGradient,
          isDark: isDark,
          onTap: () => _navigateToPets(context),
        ),
        _buildServiceCard(
          title: 'Vet Bookings',
          subtitle: 'Consultations',
          icon: Icons.calendar_month_rounded,
          gradient: AppTheme.emeraldGradient,
          isDark: isDark,
          onTap: () => AppFeedback.showToast(
            context,
            title: 'Vet Booking 🗓️',
            message: 'Veterinary discovery & booking arrive in a future update.',
            type: ToastType.info,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: AppRadius.xlRadius,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: AppRadius.xlRadius,
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1.1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: AppRadius.mdRadius,
                boxShadow: [BoxShadow(color: gradient.colors.first.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0F172A))),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white70 : const Color(0xFF64748B), fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}

/// The active dog's health hero + vitals + insight + reminders + appointment
/// + device status — everything scoped to whichever dog is selected.
class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.dog, required this.dogs});

  final Pet dog;
  final List<Pet> dogs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider(dog.id));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return summaryAsync.when(
      loading: () => const _DashboardSkeleton(),
      error: (error, _) => ErrorState(
        message: "We couldn't load ${dog.name}'s health summary.",
        onRetry: () => ref.invalidate(dashboardSummaryProvider(dog.id)),
      ),
      data: (summary) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHero(context, theme, isDark, summary),
          const SizedBox(height: AppSpacing.xl),
          _buildVitalsGrid(context, summary.vitals),
          const SizedBox(height: AppSpacing.xxl),
          AiInsightCard(insight: summary.insight),
          const SizedBox(height: AppSpacing.xxl),
          _sectionHeader(theme, isDark, "What's Due"),
          const SizedBox(height: AppSpacing.sm),
          CareRemindersSection(reminders: summary.reminders),
          const SizedBox(height: AppSpacing.xxl),
          _sectionHeader(theme, isDark, 'Upcoming Appointment'),
          const SizedBox(height: AppSpacing.sm),
          AppointmentCard(appointment: summary.appointment),
          const SizedBox(height: AppSpacing.lg),
          DeviceStatusChip(device: summary.device),
        ],
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, bool isDark, String title) {
    return Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF0F172A)));
  }

  Widget _buildHero(BuildContext context, ThemeData theme, bool isDark, DashboardSummary summary) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PetDetailScreen(pet: dog))),
      borderRadius: AppRadius.xxlRadius,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkHeroGradient : AppTheme.heroGradient,
          borderRadius: AppRadius.xxlRadius,
          border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.4), width: 1.2),
          boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: isDark ? 0.4 : 0.3), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: AppRadius.pillRadius,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(height: 8, width: 8, decoration: const BoxDecoration(color: AppTheme.emeraldAccent, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(
                          '${summary.vitals.heartRateBpm} bpm • ${summary.vitals.temperatureC.toStringAsFixed(1)}°C',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${dog.name}'s Health Cockpit",
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Multimodal AI fusing visual scans, bio-collar metrics & symptom signals.',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white.withValues(alpha: 0.88), fontSize: 13, height: 1.35),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: AppRadius.mdRadius,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                    ),
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => HealthCheckCaptureScreen(pets: dogs, initialPet: dog)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.white, size: 15),
                          const SizedBox(width: 6),
                          Text('Launch AI Scanner', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            LuxuryBiometricRing(percentage: summary.healthScore.toDouble(), size: 104, strokeWidth: 9, valueText: '${summary.healthScore}', unitText: '%', label: 'Health Score'),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsGrid(BuildContext context, VitalsSnapshot vitals) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: LuxuryStatCard(
                title: 'Activity',
                value: '${vitals.activityStepsToday}',
                unit: '/ ${vitals.activityGoalSteps}',
                icon: Icons.directions_walk_rounded,
                gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF14B8A6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                progress: (vitals.activityStepsToday / vitals.activityGoalSteps).clamp(0, 1).toDouble(),
                onTap: () => AppFeedback.showToast(
                  context,
                  title: 'Activity',
                  message: '${vitals.activityStepsToday} of ${vitals.activityGoalSteps} steps today.',
                  type: ToastType.info,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: LuxuryStatCard(
                title: 'Sleep',
                value: vitals.sleepHoursLastNight.toStringAsFixed(1),
                unit: 'hrs',
                icon: Icons.nightlight_round,
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFA5B4FC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                badgeText: vitals.sleepHoursLastNight >= 8 ? 'Optimal' : 'Low',
                badgeColor: vitals.sleepHoursLastNight >= 8 ? AppColors.success : AppColors.warning,
                progress: (vitals.sleepHoursLastNight / 10).clamp(0, 1).toDouble(),
                onTap: () => AppFeedback.showToast(
                  context,
                  title: 'Sleep',
                  message: '${vitals.sleepHoursLastNight.toStringAsFixed(1)} hours of rest last night.',
                  type: ToastType.info,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: LuxuryStatCard(
                title: 'Heart Rate',
                value: '${vitals.heartRateBpm}',
                unit: 'bpm',
                icon: Icons.favorite_rounded,
                gradient: const LinearGradient(colors: [Color(0xFFBE185D), Color(0xFFF472B6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                badgeText: vitals.heartRateBpm > 90 ? 'Elevated' : 'Normal',
                badgeColor: vitals.heartRateBpm > 90 ? AppColors.warning : AppColors.success,
                onTap: () => AppFeedback.showToast(
                  context,
                  title: 'Heart Rate',
                  message: 'Current reading: ${vitals.heartRateBpm} bpm.',
                  type: ToastType.info,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: LuxuryStatCard(
                title: 'Hydration',
                value: '${vitals.hydrationMl}',
                unit: '/ ${vitals.hydrationGoalMl} ml',
                icon: Icons.water_drop_rounded,
                gradient: const LinearGradient(colors: [Color(0xFF0369A1), Color(0xFF38BDF8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                progress: (vitals.hydrationMl / vitals.hydrationGoalMl).clamp(0, 1).toDouble(),
                onTap: () => AppFeedback.showToast(
                  context,
                  title: 'Hydration',
                  message: '${vitals.hydrationMl}ml of ${vitals.hydrationGoalMl}ml goal today.',
                  type: ToastType.info,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Loading placeholder mirroring the dashboard's layout so nothing jumps
/// once real data arrives.
class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(height: 76, width: double.infinity, borderRadius: BorderRadius.zero),
        const SizedBox(height: AppSpacing.xl),
        SkeletonBox(height: 180, borderRadius: AppRadius.xxlRadius),
        const SizedBox(height: AppSpacing.lg),
        Row(children: [
          Expanded(child: SkeletonBox(height: 110, borderRadius: AppRadius.lgRadius)),
          const SizedBox(width: 14),
          Expanded(child: SkeletonBox(height: 110, borderRadius: AppRadius.lgRadius)),
        ]),
        const SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 90, borderRadius: AppRadius.xlRadius),
      ],
    );
  }
}
