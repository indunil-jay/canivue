import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/insights/data/fake_insights_repository.dart';
import 'package:canivue/features/insights/domain/health_insight.dart';
import 'package:canivue/features/insights/domain/insights_repository.dart';

final insightsRepositoryProvider = Provider<InsightsRepository>((ref) => FakeInsightsRepository());

final healthInsightsProvider = FutureProvider.family<List<HealthInsight>, ({String id, String name})>((ref, dog) {
  return ref.watch(insightsRepositoryProvider).fetchInsights(dog.id, dog.name);
});
