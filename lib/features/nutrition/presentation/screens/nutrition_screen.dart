import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/nutrition/domain/nutrition_profile.dart';
import 'package:canivue/features/nutrition/presentation/controllers/nutrition_controller.dart';

/// Nutrition & weight management (brief §22): weight trend summary, body
/// condition score, feeding schedule and a vet-informed nutrition goal.
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(nutritionProfileProvider(dogId));

    return Scaffold(
      appBar: AppBar(title: Text('$dogName\'s Nutrition')),
      body: profileAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(20),
          child: Column(children: [SkeletonBox(height: 140), SizedBox(height: 16), SkeletonBox(height: 160)]),
        ),
        error: (_, _) => ErrorState(message: "We couldn't load nutrition data.", onRetry: () => ref.invalidate(nutritionProfileProvider(dogId))),
        data: (profile) => _NutritionBody(profile: profile),
      ),
    );
  }
}

class _NutritionBody extends StatelessWidget {
  const _NutritionBody({required this.profile});

  final NutritionProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trendUp = profile.thirtyDayWeightChangeKg > 0;
    final trendColor = profile.thirtyDayWeightChangeKg == 0
        ? (isDark ? AppColors.darkMutedText : AppColors.lightMutedText)
        : (isDark ? AppColors.primaryOnDark : AppColors.primary);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: AppRadius.xlRadius,
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Weight', style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    Text('${profile.currentWeightKg.toStringAsFixed(1)} kg', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(profile.thirtyDayWeightChangeKg == 0 ? Icons.remove_rounded : (trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded), size: 14, color: trendColor),
                        const SizedBox(width: 4),
                        Text(
                          profile.thirtyDayWeightChangeKg == 0 ? 'Stable over 30 days' : '${profile.thirtyDayWeightChangeKg.abs().toStringAsFixed(1)} kg over 30 days',
                          style: theme.textTheme.labelSmall?.copyWith(color: trendColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Goal', style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  Text('${profile.weightGoalKg.toStringAsFixed(1)} kg', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Body Condition Score', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        _BodyConditionGauge(score: profile.bodyConditionScore),
        const SizedBox(height: AppSpacing.xxl),
        Text('Daily Calorie Target', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        Text('${profile.dailyCalorieTarget} kcal / day', style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xxl),
        Text('Feeding Schedule', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: AppRadius.xlRadius,
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            children: [
              for (int i = 0; i < profile.feedingSchedule.length; i++) ...[
                if (i > 0) Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ListTile(
                  leading: Icon(Icons.restaurant_rounded, color: isDark ? AppColors.primaryOnDark : AppColors.primary),
                  title: Text(profile.feedingSchedule[i].time),
                  subtitle: Text(profile.feedingSchedule[i].foodName),
                  trailing: Text('${profile.feedingSchedule[i].portionGrams}g', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: isDark ? 0.14 : 0.06), borderRadius: AppRadius.mdRadius),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.flag_rounded, size: 18, color: isDark ? AppColors.primaryOnDark : AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(profile.nutritionGoal, style: theme.textTheme.bodySmall)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BodyConditionGauge extends StatelessWidget {
  const _BodyConditionGauge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ideal = score >= 4 && score <= 5;
    final color = ideal ? AppColors.success : (score < 4 ? AppColors.info : AppColors.warning);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(9, (i) {
            final value = i + 1;
            final isCurrent = value == score;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                height: isCurrent ? 22 : 14,
                decoration: BoxDecoration(
                  color: isCurrent ? color : (isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground),
                  borderRadius: AppRadius.xsRadius,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          '$score / 9 — ${ideal ? 'Ideal body condition' : score < 4 ? 'Slightly underweight' : 'Slightly overweight'}',
          style: theme.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
