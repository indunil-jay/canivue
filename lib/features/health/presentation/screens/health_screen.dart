import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/components/timeline_tile.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/luxury_biometric_ring.dart';
import 'package:canivue/features/health/domain/health_timeline_event.dart';
import 'package:canivue/features/health/presentation/controllers/health_timeline_controller.dart';
import 'package:canivue/features/health/presentation/widgets/metric_chart_card.dart';
import 'package:canivue/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:canivue/features/health_check/screens/health_check_capture_screen.dart';
import 'package:canivue/features/insights/presentation/widgets/insights_section.dart';
import 'package:canivue/features/home/presentation/controllers/dashboard_controller.dart';
import 'package:canivue/features/home/presentation/widgets/active_dog_switcher.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/pets/presentation/controllers/dogs_controller.dart';
import 'package:canivue/features/pets/screens/pet_list_screen.dart';
import 'package:canivue/features/predictions/presentation/controllers/prediction_controller.dart';
import 'package:canivue/features/predictions/presentation/screens/prediction_history_screen.dart';
import 'package:canivue/features/predictions/presentation/widgets/prediction_card.dart';

/// Owner shell "Health" tab — the detailed health profile for the active dog:
/// vitals summary, medical info, AI telemetry, and the full healthcare-journey timeline.
///
/// Designed with Canivue's signature warm pet sanctuary aesthetics:
/// ambient paw backdrops, warm pastel telemetry cards, tactile typography,
/// and responsive dark/light theme integration.
class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeDogAsync = ref.watch(activeDogProvider);
    final dogsAsync = ref.watch(dogsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: true,
        child: SafeArea(
          bottom: false,
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
                  onAction: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PetListScreen()),
                  ),
                );
              }

              final dogs = dogsAsync.value ?? [activeDog];

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  ref.invalidate(dashboardSummaryProvider((id: activeDog.id, name: activeDog.name)));
                  ref.invalidate(healthTimelineProvider(activeDog.id));
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers: [
                    // 1. Editorial Header matching Home Screen vibe
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: _buildHeader(context, activeDog, isDark),
                      ),
                    ),

                    // 2. Main Content
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          ActiveDogSwitcher(dogs: dogs, activeDog: activeDog),
                          const SizedBox(height: 16),
                          _HealthScoreBanner(dog: activeDog),
                          const SizedBox(height: 24),

                          // Vitals & Trends section
                          _sectionHeader(
                            context,
                            title: 'Vitals & Trends',
                            subtitle: 'Smart collar sync & biometric baseline',
                            badge: '📈 Telemetry',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(4),
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
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: MetricChartCard(dogId: activeDog.id),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // AI Disease Prediction section
                          _sectionHeader(
                            context,
                            title: 'AI Disease Diagnostics',
                            subtitle: 'Multi-modal neural disease risk assessment',
                            badge: '🔮 Predictive AI',
                            isDark: isDark,
                            trailing: TextButton.icon(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PredictionHistoryScreen(
                                      dogId: activeDog.id,
                                      dogName: activeDog.name,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.history_rounded, size: 16),
                              label: Text(
                                'History',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: isDark ? AppColors.primaryOnDark : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _AiHealthCheckLauncherCard(dog: activeDog, dogs: dogs, isDark: isDark),
                          const SizedBox(height: 14),
                          _AiPredictionSection(dog: activeDog, dogs: dogs),
                          const SizedBox(height: 24),

                          // Long-Term Insights section
                          _sectionHeader(
                            context,
                            title: 'Long-Term Insights',
                            subtitle: 'Preventive flags & lifestyle observations',
                            badge: '💡 Insights',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          InsightsSection(dogId: activeDog.id, dogName: activeDog.name),
                          const SizedBox(height: 24),

                          // Medical Info section
                          _sectionHeader(
                            context,
                            title: 'Clinical Medical Info',
                            subtitle: 'Allergies, conditions & active medications',
                            badge: '📋 Medical',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          _MedicalInfoCard(dog: activeDog),
                          const SizedBox(height: 24),

                          // Vaccinations section
                          _sectionHeader(
                            context,
                            title: 'Vaccination Records',
                            subtitle: 'Immunization history & booster schedule',
                            badge: '💉 Prevention',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          _VaccinationsList(dog: activeDog),
                          const SizedBox(height: 24),

                          // Health Journey Timeline
                          _sectionHeader(
                            context,
                            title: 'Health Journey Timeline',
                            subtitle: 'Chronological clinical milestones',
                            badge: '⏱️ Journey',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          _HealthTimeline(dogId: activeDog.id),
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Pet activeDog, bool isDark) {
    return Row(
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
                      'HEALTH SANCTUARY',
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
                'Clinical Telemetry',
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
        // Emergency Alert Action Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EmergencyScreen(dogId: activeDog.id, dogName: activeDog.name),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x2EF43F5E) : const Color(0xFFFDF2F0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0x66F43F5E) : const Color(0xFFFECDD3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emergency_rounded, size: 16, color: Color(0xFFF43F5E)),
                  const SizedBox(width: 6),
                  Text(
                    'Emergency',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF43F5E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required bool isDark,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
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
      loading: () => SkeletonBox(height: 120, borderRadius: BorderRadius.circular(24)),
      error: (_, _) => const SizedBox.shrink(),
      data: (summary) {
        final scoreColor = summary.healthScore >= 90
            ? const Color(0xFF10B981)
            : summary.healthScore >= 75
                ? const Color(0xFFF59E0B)
                : const Color(0xFFF43F5E);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  LuxuryBiometricRing(
                    percentage: summary.healthScore.toDouble(),
                    size: 68,
                    strokeWidth: 6.5,
                    accentColor: scoreColor,
                    valueText: '${summary.healthScore}',
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Overall Vitality Score',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: scoreColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                summary.healthScore >= 90
                                    ? 'Optimal'
                                    : summary.healthScore >= 75
                                        ? 'Good'
                                        : 'Action Needed',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: scoreColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dog.name} is in peak physical condition with active collar telemetry sync.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Vitals Chips Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x22FFFFFF) : const Color(0xFFF7F5F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _vitalStat('❤️ Heart', '${summary.vitals.heartRateBpm} bpm', isDark),
                    _divider(isDark),
                    _vitalStat('🌡️ Temp', '${summary.vitals.temperatureC.toStringAsFixed(1)}°C', isDark),
                    _divider(isDark),
                    _vitalStat('⚖️ Weight', '${summary.vitals.weightKg.toStringAsFixed(1)} kg', isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _vitalStat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _divider(bool isDark) {
    return Container(
      height: 22,
      width: 1,
      color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2DDD5),
    );
  }
}

class _AiHealthCheckLauncherCard extends StatelessWidget {
  const _AiHealthCheckLauncherCard({
    required this.dog,
    required this.dogs,
    required this.isDark,
  });

  final Pet dog;
  final List<Pet> dogs;
  final bool isDark;

  void _onLaunchScan(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthCheckCaptureScreen(pets: dogs, initialPet: dog),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1E2638), Color(0xFF151922)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF181A20), Color(0xFF262C38)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2DD4BF).withValues(alpha: isDark ? 0.4 : 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2DD4BF).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DD4BF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF2DD4BF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Health Check Scanner',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF2DD4BF),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      'Multimodal Vision · Collar · Symptoms',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'v2.3 Fusion',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Check ${dog.name}\'s Health Now',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Synthesize camera photo, smart collar gait and symptom descriptions into instant diagnostic predictions and disease progression risk.',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _onLaunchScan(context),
              icon: const Icon(Icons.camera_alt_rounded, size: 16, color: Color(0xFF181A20)),
              label: Text(
                'Run AI Health Check',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: const Color(0xFF181A20),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DD4BF),
                foregroundColor: const Color(0xFF181A20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiPredictionSection extends ConsumerWidget {
  const _AiPredictionSection({
    required this.dog,
    required this.dogs,
  });

  final Pet dog;
  final List<Pet> dogs;

  void _onLaunchScan(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthCheckCaptureScreen(pets: dogs, initialPet: dog),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictionAsync = ref.watch(latestPredictionProvider(dog.id));

    return predictionAsync.when(
      loading: () => SkeletonBox(height: 220, borderRadius: BorderRadius.circular(24)),
      error: (_, _) => ErrorState(
        message: "We couldn't load the latest AI analysis.",
        onRetry: () => ref.invalidate(latestPredictionProvider(dog.id)),
      ),
      data: (prediction) {
        if (prediction == null) {
          return EmptyState(
            icon: Icons.auto_awesome_outlined,
            title: 'No active predictions',
            message: 'Canivue is continuously monitoring — run a scan anytime to generate new AI diagnostics for ${dog.name}.',
            actionLabel: 'Run AI Health Check',
            onAction: () => _onLaunchScan(context),
          );
        }
        return PredictionCard(prediction: prediction);
      },
    );
  }
}

class _MedicalInfoCard extends StatelessWidget {
  const _MedicalInfoCard({required this.dog});

  final Pet dog;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            context,
            'Allergies & Sensitivities',
            dog.allergies,
            const Color(0xFFF43F5E),
            isDark,
          ),
          if (dog.existingConditions.isNotEmpty) ...[
            const SizedBox(height: 16),
            _infoRow(
              context,
              'Documented Conditions',
              dog.existingConditions,
              const Color(0xFFF59E0B),
              isDark,
            ),
          ],
          if (dog.medications.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Active Medications',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
              ),
            ),
            const SizedBox(height: 8),
            for (final med in dog.medications)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMintSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0x4414B8A6) : const Color(0xFFD3EFE8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medication_rounded, size: 16, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${med.name} — ${med.dosage}, ${med.frequency}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (dog.insurance != null) ...[
            const SizedBox(height: 16),
            Text(
              'Canine Insurance Policy',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x228B5CF6) : AppColors.pastelLilac,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0x448B5CF6) : const Color(0xFFE2D9FC),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 20, color: Color(0xFF7A67EE)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dog.insurance!.provider,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Policy #${dog.insurance!.policyNumber} · Expires ${DateFormat('MMM d, yyyy').format(dog.insurance!.expiryDate)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    List<String> items,
    Color chipColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: isDark ? 0.18 : 0.09),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: chipColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.plusJakartaSans(
                      color: chipColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (dog.vaccinations.isEmpty) {
      return const EmptyState(
        icon: Icons.vaccines_outlined,
        title: 'No vaccination records',
        message: 'Vaccination history will appear here once added.',
      );
    }

    return Container(
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
            for (int i = 0; i < dog.vaccinations.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              _vaccinationTile(context, dog.vaccinations[i], isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _vaccinationTile(BuildContext context, VaccinationRecord record, bool isDark) {
    final overdue = record.nextDueDate != null && record.nextDueDate!.isBefore(DateTime.now());
    final statusColor = overdue ? const Color(0xFFF43F5E) : const Color(0xFF10B981);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.vaccines_rounded, size: 20, color: statusColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Given ${DateFormat('MMM d, yyyy').format(record.dateGiven)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (record.nextDueDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                overdue ? 'Overdue' : 'Due ${DateFormat('MMM yyyy').format(record.nextDueDate!)}',
                style: GoogleFonts.plusJakartaSans(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
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
      TimelineEventType.aiPrediction => const Color(0xFF7A67EE),
      TimelineEventType.diagnosis => const Color(0xFFF59E0B),
      _ => isDark ? AppColors.primaryOnDark : AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(healthTimelineProvider(dogId));

    return timelineAsync.when(
      loading: () => Column(
        children: List.generate(
          3,
          (_) => const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBox(height: 60)),
        ),
      ),
      error: (_, _) => ErrorState(
        message: "We couldn't load the health timeline.",
        onRetry: () => ref.invalidate(healthTimelineProvider(dogId)),
      ),
      data: (events) {
        if (events.isEmpty) {
          return const EmptyState(
            icon: Icons.timeline_rounded,
            title: 'No health events yet',
            message: 'Vaccinations, checkups and AI insights will build this timeline over time.',
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            ),
          ),
          child: Column(
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
          ),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(height: 60, width: double.infinity, borderRadius: BorderRadius.zero),
          const SizedBox(height: 16),
          SkeletonBox(height: 110, borderRadius: BorderRadius.circular(24)),
          const SizedBox(height: 20),
          SkeletonBox(height: 160, borderRadius: BorderRadius.circular(24)),
        ],
      ),
    );
  }
}
