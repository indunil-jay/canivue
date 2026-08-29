/// Aggregate "front page" view of one dog's health — a summarized read
/// distinct from the full health-monitoring detail (that lives behind the
/// Health tab). Real backends commonly expose a dashboard/summary endpoint
/// like this precisely so the home screen doesn't have to assemble it from
/// several heavier calls.
library;

enum RiskLevel { normal, monitoring, elevated }

class VitalsSnapshot {
  const VitalsSnapshot({
    required this.heartRateBpm,
    required this.temperatureC,
    required this.activityStepsToday,
    required this.activityGoalSteps,
    required this.sleepHoursLastNight,
    required this.hydrationMl,
    required this.hydrationGoalMl,
    required this.weightKg,
  });

  final int heartRateBpm;
  final double temperatureC;
  final int activityStepsToday;
  final int activityGoalSteps;
  final double sleepHoursLastNight;
  final int hydrationMl;
  final int hydrationGoalMl;
  final double weightKg;
}

class AiInsight {
  const AiInsight({required this.headline, required this.detail, this.risk = RiskLevel.normal});

  final String headline;
  final String detail;
  final RiskLevel risk;
}

enum ReminderKind { vaccination, medication, grooming, checkup, deworming }

class CareReminder {
  const CareReminder({required this.kind, required this.title, required this.dueDate});

  final ReminderKind kind;
  final String title;
  final DateTime dueDate;

  bool get isOverdue => dueDate.isBefore(DateTime.now());
}

class UpcomingAppointment {
  const UpcomingAppointment({required this.vetName, required this.clinic, required this.time, required this.isVideoCall});

  final String vetName;
  final String clinic;
  final DateTime time;
  final bool isVideoCall;
}

enum DeviceConnectionState { connected, disconnected, notPaired }

class DeviceStatus {
  const DeviceStatus({
    required this.state,
    this.deviceName = 'Canivue Smart Collar',
    this.batteryPercent,
    this.lastSyncedAt,
  });

  final DeviceConnectionState state;
  final String deviceName;
  final int? batteryPercent;
  final DateTime? lastSyncedAt;
}

/// Everything the Home dashboard shows for one dog.
class DashboardSummary {
  const DashboardSummary({
    required this.healthScore,
    required this.vitals,
    required this.insight,
    required this.reminders,
    required this.appointment,
    required this.device,
  });

  /// 0-100.
  final int healthScore;
  final VitalsSnapshot vitals;
  final AiInsight insight;
  final List<CareReminder> reminders;
  final UpcomingAppointment? appointment;
  final DeviceStatus device;
}
