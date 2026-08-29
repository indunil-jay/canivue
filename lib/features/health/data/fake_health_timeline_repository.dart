import 'package:canivue/features/health/domain/health_timeline_event.dart';
import 'package:canivue/features/health/domain/health_timeline_repository.dart';

/// Synthetic but chronologically-sensible timeline, varied per dog so the
/// journey doesn't look identical across every dog in the household.
class FakeHealthTimelineRepository implements HealthTimelineRepository {
  @override
  Future<List<HealthTimelineEvent>> fetchTimeline(String dogId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final variant = dogId.hashCode % 2;

    final events = <HealthTimelineEvent>[
      HealthTimelineEvent(
        type: TimelineEventType.aiPrediction,
        title: 'AI health check completed',
        description: 'Multimodal scan found no signs of concern.',
        date: now.subtract(const Duration(days: 2)),
      ),
      HealthTimelineEvent(
        type: TimelineEventType.weightChange,
        title: 'Weight logged',
        description: 'Stable compared with the 30-day baseline.',
        date: now.subtract(const Duration(days: 6)),
      ),
      HealthTimelineEvent(
        type: TimelineEventType.vaccination,
        title: 'Rabies booster administered',
        description: 'Given at the primary vet clinic.',
        date: now.subtract(const Duration(days: 21)),
      ),
      HealthTimelineEvent(
        type: TimelineEventType.appointment,
        title: 'Veterinary consultation',
        description: 'Routine wellness checkup — no issues found.',
        date: now.subtract(const Duration(days: 40)),
      ),
      if (variant == 1)
        HealthTimelineEvent(
          type: TimelineEventType.healthAlert,
          title: 'Unusual inactivity flagged',
          description: 'Sensor detected below-average movement for 2 days; resolved on its own.',
          date: now.subtract(const Duration(days: 55)),
        ),
      HealthTimelineEvent(
        type: TimelineEventType.diagnosis,
        title: variant == 1 ? 'Mild seasonal allergy diagnosed' : 'Annual check-up: healthy',
        description: variant == 1 ? 'Prescribed antihistamine, resolved within 2 weeks.' : 'Vet confirmed excellent overall condition.',
        date: now.subtract(const Duration(days: 95)),
      ),
      HealthTimelineEvent(
        type: TimelineEventType.medication,
        title: 'Started joint supplement',
        description: 'Preventive care recommendation from primary vet.',
        date: now.subtract(const Duration(days: 130)),
      ),
    ];

    events.sort((a, b) => b.date.compareTo(a.date));
    return events;
  }
}
