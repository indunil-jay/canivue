import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/health/data/fake_health_timeline_repository.dart';
import 'package:canivue/features/health/domain/health_timeline_event.dart';
import 'package:canivue/features/health/domain/health_timeline_repository.dart';

final healthTimelineRepositoryProvider = Provider<HealthTimelineRepository>((ref) => FakeHealthTimelineRepository());

final healthTimelineProvider = FutureProvider.family<List<HealthTimelineEvent>, String>((ref, dogId) {
  return ref.watch(healthTimelineRepositoryProvider).fetchTimeline(dogId);
});
