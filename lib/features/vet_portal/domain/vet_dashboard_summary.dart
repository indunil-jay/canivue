/// The veterinarian dashboard (brief §33) — prioritized for efficiency:
/// today's schedule, what needs attention now, and recent activity.
class ScheduleEntry {
  const ScheduleEntry({required this.time, required this.ownerName, required this.dogName, required this.type, required this.confirmed});

  final String time;
  final String ownerName;
  final String dogName;
  final String type;
  final bool confirmed;
}

class RecentMessagePreview {
  const RecentMessagePreview({required this.ownerName, required this.preview, required this.timeAgo});

  final String ownerName;
  final String preview;
  final String timeAgo;
}

class VetDashboardSummary {
  const VetDashboardSummary({
    required this.vetName,
    required this.todaySchedule,
    required this.waitingConsultationCount,
    required this.criticalAlertCount,
    required this.newPatientCount,
    required this.recentMessages,
  });

  final String vetName;
  final List<ScheduleEntry> todaySchedule;
  final int waitingConsultationCount;
  final int criticalAlertCount;
  final int newPatientCount;
  final List<RecentMessagePreview> recentMessages;
}
