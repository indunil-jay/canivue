import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/features/nutrition/domain/nutrition_profile.dart';
import 'package:canivue/features/nutrition/presentation/controllers/nutrition_controller.dart';

/// Canine nutrition & body weight tracker: 30-day weight trends, 9-point body
/// condition score dial, calorie goal, and daily feeding schedule.
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(nutritionProfileProvider(dogId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF181A20),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '$dogName\'s Nutrition',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: false,
        child: profileAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SkeletonBox(height: 140, borderRadius: BorderRadius.all(Radius.circular(24))),
                SizedBox(height: 16),
                SkeletonBox(height: 160, borderRadius: BorderRadius.all(Radius.circular(24))),
              ],
            ),
          ),
          error: (_, _) => ErrorState(
            message: "We couldn't load nutrition data.",
            onRetry: () => ref.invalidate(nutritionProfileProvider(dogId)),
          ),
          data: (profile) => _NutritionBody(profile: profile, dogName: dogName),
        ),
      ),
    );
  }
}

class _NutritionBody extends StatelessWidget {
  const _NutritionBody({required this.profile, required this.dogName});

  final NutritionProfile profile;
  final String dogName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trendUp = profile.thirtyDayWeightChangeKg > 0;
    final trendColor = profile.thirtyDayWeightChangeKg == 0
        ? (isDark ? AppColors.darkMutedText : AppColors.lightMutedText)
        : (isDark ? AppColors.primaryOnDark : AppColors.primary);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      children: [
        // Current Weight & Target Hero Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Weight',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${profile.currentWeightKg.toStringAsFixed(1)} kg',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          profile.thirtyDayWeightChangeKg == 0
                              ? Icons.remove_rounded
                              : (trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded),
                          size: 16,
                          color: trendColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.thirtyDayWeightChangeKg == 0
                              ? 'Stable over 30 days'
                              : '${profile.thirtyDayWeightChangeKg.abs().toStringAsFixed(1)} kg in last 30d',
                          style: GoogleFonts.plusJakartaSans(
                            color: trendColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                width: 1,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Target Goal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${profile.weightGoalKg.toStringAsFixed(1)} kg',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Body Condition Score
        _sectionLabel('Body Condition Score (BCS)', isDark),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            ),
          ),
          child: _BodyConditionGauge(score: profile.bodyConditionScore),
        ),
        const SizedBox(height: 20),

        // Daily Calorie Target
        _sectionLabel('Daily Caloric Needs', isDark),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x22F59E0B) : AppColors.pastelAmber,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🔥', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile.dailyCalorieTarget} kcal / day',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF181A20),
                      ),
                    ),
                    Text(
                      'Optimized for $dogName\'s breed baseline and daily activity',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : const Color(0xFF57534E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Feeding Schedule
        _sectionLabel('Daily Feeding Routine', isDark),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                for (int i = 0; i < profile.feedingSchedule.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.restaurant_rounded, color: Color(0xFF0F766E), size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.feedingSchedule[i].foodName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              Text(
                                profile.feedingSchedule[i].time,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0x22FFFFFF) : const Color(0xFFF7F5F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${profile.feedingSchedule[i].portionGrams}g',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Vet Nutrition Goal Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x2210B981) : AppColors.pastelMintSoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.flag_rounded, size: 20, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  profile.nutritionGoal,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }
}

class _BodyConditionGauge extends StatelessWidget {
  const _BodyConditionGauge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ideal = score >= 4 && score <= 5;
    final color = ideal ? const Color(0xFF10B981) : (score < 4 ? const Color(0xFF0284C7) : const Color(0xFFF59E0B));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(9, (i) {
            final value = i + 1;
            final isCurrent = value == score;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: isCurrent ? 24 : 12,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? color
                      : (isDark ? const Color(0x22FFFFFF) : const Color(0xFFEBE6DC)),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1 (Under)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
              ),
            ),
            Text(
              '$score / 9 · ${ideal ? 'Ideal Canine Body Condition' : score < 4 ? 'Slightly Underweight' : 'Slightly Overweight'}',
              style: GoogleFonts.plusJakartaSans(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
            Text(
              '9 (Heavy)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
