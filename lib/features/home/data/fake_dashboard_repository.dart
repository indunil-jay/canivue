import 'package:canivue/features/home/domain/dashboard_repository.dart';
import 'package:canivue/features/home/domain/dashboard_summary.dart';

/// Deterministic-but-varied fake data keyed by dog id, so switching the
/// active dog visibly changes the dashboard instead of showing identical
/// numbers for every dog.
class FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSummary> fetchSummary(String dogId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final variant = dogId.hashCode % 3;

    switch (variant) {
      case 0:
        return DashboardSummary(
          healthScore: 98,
          vitals: const VitalsSnapshot(
            heartRateBpm: 72,
            temperatureC: 38.4,
            activityStepsToday: 8450,
            activityGoalSteps: 10000,
            sleepHoursLastNight: 9.4,
            hydrationMl: 620,
            hydrationGoalMl: 800,
            weightKg: 28.5,
          ),
          insight: const AiInsight(
            headline: "Buddy's activity is up 12% this week",
            detail: 'Consistent with the warmer weather and longer evening walks — no action needed.',
          ),
          reminders: [
            CareReminder(kind: ReminderKind.vaccination, title: 'Rabies booster', dueDate: DateTime.now().add(const Duration(days: 9))),
            CareReminder(kind: ReminderKind.grooming, title: 'Grooming appointment', dueDate: DateTime.now().add(const Duration(days: 14))),
          ],
          appointment: UpcomingAppointment(
            vetName: 'Dr. Sarah Jenkins',
            clinic: 'Bay Area Vet',
            time: DateTime.now().add(const Duration(days: 3, hours: 2)),
            isVideoCall: false,
          ),
          device: DeviceStatus(
            state: DeviceConnectionState.connected,
            batteryPercent: 78,
            lastSyncedAt: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
        );
      case 1:
        return DashboardSummary(
          healthScore: 84,
          vitals: const VitalsSnapshot(
            heartRateBpm: 95,
            temperatureC: 38.9,
            activityStepsToday: 4120,
            activityGoalSteps: 9000,
            sleepHoursLastNight: 7.1,
            hydrationMl: 410,
            hydrationGoalMl: 750,
            weightKg: 24.0,
          ),
          insight: const AiInsight(
            headline: 'Resting heart rate trending up over 7 days',
            detail: 'Luna\'s resting heart rate has gradually increased. Worth mentioning at her next checkup.',
            risk: RiskLevel.monitoring,
          ),
          reminders: [
            CareReminder(kind: ReminderKind.deworming, title: 'Deworming due', dueDate: DateTime.now().subtract(const Duration(days: 1))),
            CareReminder(kind: ReminderKind.medication, title: 'Joint supplement refill', dueDate: DateTime.now().add(const Duration(days: 2))),
          ],
          appointment: null,
          device: DeviceStatus(
            state: DeviceConnectionState.disconnected,
            lastSyncedAt: DateTime.now().subtract(const Duration(hours: 6)),
          ),
        );
      default:
        return DashboardSummary(
          healthScore: 91,
          vitals: const VitalsSnapshot(
            heartRateBpm: 88,
            temperatureC: 38.6,
            activityStepsToday: 6210,
            activityGoalSteps: 8000,
            sleepHoursLastNight: 10.1,
            hydrationMl: 540,
            hydrationGoalMl: 650,
            weightKg: 12.2,
          ),
          insight: const AiInsight(
            headline: "Charlie's sleep quality improved this week",
            detail: 'Deep-sleep duration is up compared with his 30-day baseline.',
          ),
          reminders: [
            CareReminder(kind: ReminderKind.checkup, title: 'Annual health check', dueDate: DateTime.now().add(const Duration(days: 21))),
          ],
          appointment: UpcomingAppointment(
            vetName: 'Dr. Sarah Jenkins',
            clinic: 'Bay Area Vet',
            time: DateTime.now().add(const Duration(days: 1, hours: 5)),
            isVideoCall: true,
          ),
          device: const DeviceStatus(state: DeviceConnectionState.notPaired),
        );
    }
  }
}
