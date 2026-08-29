/// Nutrition & weight management (brief §22).
class FeedingScheduleEntry {
  const FeedingScheduleEntry({required this.time, required this.foodName, required this.portionGrams});

  final String time;
  final String foodName;
  final int portionGrams;
}

class NutritionProfile {
  const NutritionProfile({
    required this.currentWeightKg,
    required this.weightGoalKg,
    required this.thirtyDayWeightChangeKg,
    required this.bodyConditionScore,
    required this.dailyCalorieTarget,
    required this.feedingSchedule,
    required this.nutritionGoal,
  });

  final double currentWeightKg;
  final double weightGoalKg;
  final double thirtyDayWeightChangeKg;

  /// 1-9 scale (veterinary standard); 4-5 is ideal.
  final int bodyConditionScore;
  final int dailyCalorieTarget;
  final List<FeedingScheduleEntry> feedingSchedule;
  final String nutritionGoal;
}
