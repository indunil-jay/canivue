import 'package:canivue/features/insights/domain/health_insight.dart';
import 'package:canivue/features/insights/domain/insights_repository.dart';

class FakeInsightsRepository implements InsightsRepository {
  @override
  Future<List<HealthInsight>> fetchInsights(String dogId, String dogName) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final variant = dogId.hashCode % 2;

    return [
      HealthInsight(
        headline: "$dogName's activity increased 12% this month",
        detail: 'Consistent with more frequent evening walks — a positive trend.',
        direction: TrendDirection.up,
      ),
      if (variant == 0)
        HealthInsight(
          headline: 'Resting heart rate has gradually increased over 7 days',
          detail: 'Worth mentioning at the next checkup if the trend continues.',
          direction: TrendDirection.up,
          isPositive: false,
        )
      else
        HealthInsight(
          headline: 'Weight has remained stable for 30 days',
          detail: 'No significant fluctuation — right on track with the nutrition goal.',
          direction: TrendDirection.stable,
        ),
      HealthInsight(
        headline: 'Sleep quality decreased compared with the 30-day baseline',
        detail: 'Deep-sleep duration is down slightly — consider a calmer evening routine.',
        direction: TrendDirection.down,
        isPositive: false,
      ),
      const HealthInsight(
        headline: 'Hydration levels are consistently on target',
        detail: 'Daily water intake has met the recommended goal for 3 straight weeks.',
        direction: TrendDirection.stable,
      ),
    ];
  }
}
