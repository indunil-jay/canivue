/// The unified healthcare-journey timeline (brief §31) — sensor events, AI
/// predictions, consultations, vaccinations, medication, weight changes,
/// diagnoses, appointments and health alerts, all in one chronological view.
enum TimelineEventType {
  vaccination,
  medication,
  weightChange,
  diagnosis,
  appointment,
  aiPrediction,
  healthAlert,
  sensorEvent,
}

class HealthTimelineEvent {
  const HealthTimelineEvent({
    required this.type,
    required this.title,
    required this.description,
    required this.date,
  });

  final TimelineEventType type;
  final String title;
  final String description;
  final DateTime date;
}
