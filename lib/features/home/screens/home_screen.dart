import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/core/widgets/luxury_stat_card.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/home/domain/dashboard_summary.dart';
import 'package:canivue/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:canivue/features/home/presentation/widgets/active_dog_switcher.dart';
import 'package:canivue/features/home/presentation/widgets/ai_insight_card.dart';
import 'package:canivue/features/home/presentation/widgets/appointment_card.dart';
import 'package:canivue/features/home/presentation/widgets/care_reminders_section.dart';
import 'package:canivue/features/home/presentation/widgets/device_status_chip.dart';
import 'package:canivue/features/home/presentation/widgets/home_category_pills.dart';
import 'package:canivue/features/home/presentation/widgets/home_hero_pet_card.dart';
import 'package:canivue/features/home/presentation/widgets/home_quick_action_tiles.dart';
import 'package:canivue/features/notifications/widgets/notification_badge_button.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/pets/presentation/controllers/dogs_controller.dart';
import 'package:canivue/features/pets/screens/pet_list_screen.dart';
import 'package:canivue/features/preventive_care/presentation/screens/preventive_care_screen.dart';
import 'package:canivue/features/search/presentation/screens/search_screen.dart';
import 'package:canivue/features/vets/presentation/screens/appointments_screen.dart';
import 'package:canivue/features/vets/presentation/screens/vet_discovery_screen.dart';

/// Reimagined Canivue Home Screen.
///
/// Combines the warm, tactile, high-end pet sanctuary aesthetics of:
/// - Pawsure: Warm sunshine amber hero card, obsidian action tiles, frosted telemetry pills
/// - PawAdopt: Organic pastel backplates and pet-first framing
/// - PawMate: Soft pastel category squares and friendly typography
/// - Pupora: Clean minimal lines, floating capsule nav, and high accessibility
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Overview', 'Telemetry', 'Medical', 'Schedule'];

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
    HapticFeedback.lightImpact();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PetListScreen()));
  }

  void _navigateToSearch(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(authControllerProvider);
    final displayName = _displayName(user?.name, user?.email ?? 'user@example.com');

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: AmbientPawBackdrop(
        showContainerLines: true,
        showPawWatermarks: true,
        showParticles: true,
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(dogsProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // 1. Custom Editorial App Bar / Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: _buildHeader(context, displayName, isDark),
                  ),
                ),

                // 2. Search & Filter Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: _buildSearchBar(context, isDark),
                  ),
                ),

                // 3. Segmented Care Filter Pills
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 10),
                    child: _buildSegmentedFilterBar(isDark),
                  ),
                ),

                // 4. Main Dynamic Pet Body
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMainBody(context, ref, isDark),
                  ),
                ),

                // 5. Cushion for floating bottom navigation bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String displayName, bool isDark) {
    return Row(
      children: [
        // Avatar circle with warm golden accent border
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF242A38) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFED25E),
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFED25E).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '🐶',
              style: TextStyle(fontSize: 22),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $displayName 👋',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: isDark ? Colors.white : const Color(0xFF181A20),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Good pets make a great life!',
                style: GoogleFonts.plusJakartaSans(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Search & Notification actions
        GestureDetector(
          onTap: () => _navigateToSearch(context),
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242A38) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0x22FFFFFF) : const Color(0xFFECE6DC),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.search_rounded,
              size: 20,
              color: isDark ? Colors.white : const Color(0xFF181A20),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const NotificationBadgeButton(),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () => _navigateToSearch(context),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B202C) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0x22FFFFFF) : const Color(0xFFECE6DC),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search dogs, health records, vets...',
                style: GoogleFonts.plusJakartaSans(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF78716C),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFED25E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tune_rounded,
                size: 16,
                color: Color(0xFF181A20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedFilterBar(bool isDark) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedFilterIndex;
          final title = _filters[index];

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilterIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF181A20))
                    : (isDark ? const Color(0x1AFFFFFF) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? const Color(0x22FFFFFF) : const Color(0xFFECE6DC)),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF181A20))
                              .withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? (isDark ? const Color(0xFF181A20) : Colors.white)
                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF57534E)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainBody(BuildContext context, WidgetRef ref, bool isDark) {
    final dogsAsync = ref.watch(dogsProvider);
    final activeDogAsync = ref.watch(activeDogProvider);

    return activeDogAsync.when(
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
            const SizedBox(height: 12),

            // Active Pet Switcher row
            ActiveDogSwitcher(dogs: dogs, activeDog: activeDog),

            const SizedBox(height: 18),

            // Main Pet Dashboard Content
            _DashboardContent(dog: activeDog, dogs: dogs),
          ],
        );
      },
    );
  }
}

/// The active dog's health hero + vitals + insight + reminders + appointment
class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.dog, required this.dogs});

  final Pet dog;
  final List<Pet> dogs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider((id: dog.id, name: dog.name)));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return summaryAsync.when(
      loading: () => const _DashboardSkeleton(),
      error: (error, _) => ErrorState(
        message: "We couldn't load ${dog.name}'s health summary.",
        onRetry: () => ref.invalidate(dashboardSummaryProvider((id: dog.id, name: dog.name))),
      ),
      data: (summary) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Reimagined Pet Showcase Card (Images 1 & 2 & 3 hybrid)
          HomeHeroPetCard(
            dog: dog,
            dogs: dogs,
            summary: summary,
          ),

          const SizedBox(height: 20),

          // 2. Side-by-Side Quick Action Tiles (Image 1 Pawsure style)
          HomeQuickActionTiles(dog: dog, dogs: dogs),

          const SizedBox(height: 24),

          // 3. Category Quick Navigation Row (Image 3 PawMate style)
          _sectionHeader('Quick Services', isDark),
          const SizedBox(height: 12),
          HomeCategoryPills(dog: dog, dogs: dogs),

          const SizedBox(height: 24),

          // 4. Live Health Telemetry & Activity Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader('Daily Biometrics & Activity', isDark),
              Text(
                'Today',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF2DD4BF) : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildVitalsGrid(context, summary.vitals, isDark),

          const SizedBox(height: 24),

          // 5. AI Health Insights Card
          _sectionHeader('Multimodal AI Insights', isDark),
          const SizedBox(height: 12),
          AiInsightCard(insight: summary.insight),

          const SizedBox(height: 24),

          // 6. Care Reminders & Preventive Health
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader("What's Due", isDark),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PreventiveCareScreen(dogId: dog.id, dogName: dog.name)),
                ),
                child: Text(
                  'View All',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF2DD4BF) : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CareRemindersSection(reminders: summary.reminders),

          const SizedBox(height: 24),

          // 7. Upcoming Vet Appointment Card
          _sectionHeader('Upcoming Appointment', isDark),
          const SizedBox(height: 10),
          AppointmentCard(
            appointment: summary.appointment,
            onBook: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => VetDiscoveryScreen(dogId: dog.id, dogName: dog.name)),
            ),
            onViewAppointments: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AppointmentsScreen(dogId: dog.id, dogName: dog.name)),
            ),
          ),

          const SizedBox(height: 18),

          // 8. Device Hardware Status Chip
          DeviceStatusChip(device: summary.device, dogId: dog.id, dogName: dog.name),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w800,
        fontSize: 16.5,
        color: isDark ? Colors.white : const Color(0xFF181A20),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildVitalsGrid(BuildContext context, VitalsSnapshot vitals, bool isDark) {
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                progress: (vitals.activityStepsToday / vitals.activityGoalSteps).clamp(0, 1).toDouble(),
                onTap: () => AppFeedback.showToast(
                  context,
                  title: 'Daily Steps',
                  message: '${vitals.activityStepsToday} of ${vitals.activityGoalSteps} steps completed today.',
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFA5B4FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                badgeText: vitals.sleepHoursLastNight >= 8 ? 'Optimal' : 'Low',
                badgeColor: vitals.sleepHoursLastNight >= 8 ? AppColors.success : AppColors.warning,
                progress: (vitals.sleepHoursLastNight / 10).clamp(0, 1).toDouble(),
                onTap: () => AppFeedback.showToast(
                  context,
                  title: 'Restful Sleep',
                  message: '${vitals.sleepHoursLastNight.toStringAsFixed(1)} hours of restorative sleep recorded.',
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
                gradient: const LinearGradient(
                  colors: [Color(0xFFBE185D), Color(0xFFF472B6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                badgeText: vitals.heartRateBpm > 90 ? 'Elevated' : 'Normal',
                badgeColor: vitals.heartRateBpm > 90 ? AppColors.warning : AppColors.success,
                progress: (vitals.heartRateBpm / 140).clamp(0, 1).toDouble(),
                onTap: () => AppFeedback.showToast(
                  context,
                  title: 'Canine Heart Rate',
                  message: '${vitals.heartRateBpm} beats per minute (stable sinus rhythm).',
                  type: ToastType.info,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: LuxuryStatCard(
                title: 'Temperature',
                value: vitals.temperatureC.toStringAsFixed(1),
                unit: '°C',
                icon: Icons.thermostat_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                badgeText: vitals.temperatureC <= 39.2 ? 'Normal' : 'High',
                badgeColor: vitals.temperatureC <= 39.2 ? AppColors.success : AppColors.error,
                progress: ((vitals.temperatureC - 37.0) / 3.0).clamp(0, 1).toDouble(),
                onTap: () => AppFeedback.showToast(
                  context,
                  title: 'Body Temperature',
                  message: '${vitals.temperatureC.toStringAsFixed(1)}°C — perfectly in canine baseline.',
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

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        SkeletonBox(height: 80, width: double.infinity),
        SizedBox(height: 16),
        SkeletonBox(height: 260, width: double.infinity),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 130)),
            SizedBox(width: 14),
            Expanded(child: SkeletonBox(height: 130)),
          ],
        ),
        SizedBox(height: 16),
        SkeletonBox(height: 90, width: double.infinity),
      ],
    );
  }
}
