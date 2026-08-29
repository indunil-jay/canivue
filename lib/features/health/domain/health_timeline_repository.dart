import 'package:canivue/features/health/domain/health_timeline_event.dart';

abstract class HealthTimelineRepository {
  Future<List<HealthTimelineEvent>> fetchTimeline(String dogId);
}
