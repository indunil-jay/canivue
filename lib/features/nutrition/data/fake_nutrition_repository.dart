import 'package:canivue/features/nutrition/domain/nutrition_profile.dart';
import 'package:canivue/features/nutrition/domain/nutrition_repository.dart';

class FakeNutritionRepository implements NutritionRepository {
  @override
  Future<NutritionProfile> fetchProfile(String dogId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final variant = dogId.hashCode % 3;

    return switch (variant) {
      0 => const NutritionProfile(
          currentWeightKg: 28.5,
          weightGoalKg: 27.0,
          thirtyDayWeightChangeKg: 0.3,
          bodyConditionScore: 6,
          dailyCalorieTarget: 1450,
          feedingSchedule: [
            FeedingScheduleEntry(time: '7:00 AM', foodName: 'Canivue Adult Formula', portionGrams: 180),
            FeedingScheduleEntry(time: '6:00 PM', foodName: 'Canivue Adult Formula', portionGrams: 180),
          ],
          nutritionGoal: 'Gradual weight reduction — slightly overweight for breed and frame.',
        ),
      1 => const NutritionProfile(
          currentWeightKg: 24.0,
          weightGoalKg: 24.0,
          thirtyDayWeightChangeKg: 0.0,
          bodyConditionScore: 5,
          dailyCalorieTarget: 1300,
          feedingSchedule: [
            FeedingScheduleEntry(time: '7:30 AM', foodName: 'Canivue Active Formula', portionGrams: 160),
            FeedingScheduleEntry(time: '5:30 PM', foodName: 'Canivue Active Formula', portionGrams: 160),
          ],
          nutritionGoal: 'Maintain current weight — ideal body condition.',
        ),
      _ => const NutritionProfile(
          currentWeightKg: 12.2,
          weightGoalKg: 12.5,
          thirtyDayWeightChangeKg: -0.2,
          bodyConditionScore: 4,
          dailyCalorieTarget: 620,
          feedingSchedule: [
            FeedingScheduleEntry(time: '8:00 AM', foodName: 'Canivue Small Breed Formula', portionGrams: 90),
            FeedingScheduleEntry(time: '6:30 PM', foodName: 'Canivue Small Breed Formula', portionGrams: 90),
          ],
          nutritionGoal: 'Slight weight gain recommended — monitor appetite.',
        ),
    };
  }
}
