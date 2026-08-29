import 'package:canivue/features/insights/domain/health_insight.dart';

abstract class InsightsRepository {
  Future<List<HealthInsight>> fetchInsights(String dogId, String dogName);
}
