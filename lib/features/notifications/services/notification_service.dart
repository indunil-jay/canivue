import 'package:flutter/foundation.dart';
import 'package:canivue/features/notifications/models/notification_item.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal() {
    _initSampleNotifications();
  }

  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _initSampleNotifications() {
    final now = DateTime.now();
    _notifications.addAll([
      NotificationItem(
        id: 'notif-1',
        title: 'AI Health Alert: Ocular Discharge',
        message: 'Max’s recent eye scan detected mild conjunctival redness. AI recommends veterinarian review if persistent.',
        timestamp: now.subtract(const Duration(minutes: 12)),
        type: NotificationType.aiHealthAlert,
        petName: 'Max',
        isRead: false,
        actionLabel: 'View Health Check',
      ),
      NotificationItem(
        id: 'notif-2',
        title: 'Rabies Booster Due in 3 Days',
        message: 'Bella is due for her annual DHPP & Rabies vaccination on Friday. Check clinic availability.',
        timestamp: now.subtract(const Duration(hours: 2)),
        type: NotificationType.vaccineReminder,
        petName: 'Bella',
        isRead: false,
        actionLabel: 'View Vaccines',
      ),
      NotificationItem(
        id: 'notif-3',
        title: 'Daily Activity Target Crushed! 🏆',
        message: 'Rocky reached 11,450 active steps (5.2 km) today, exceeding his goal by 15%.',
        timestamp: now.subtract(const Duration(hours: 5)),
        type: NotificationType.activityGoal,
        petName: 'Rocky',
        isRead: false,
        actionLabel: 'Activity Stats',
      ),
      NotificationItem(
        id: 'notif-4',
        title: 'Smart Collar Battery Low (18%)',
        message: 'Max’s GPS & Bio-telemetry collar is below 20%. Please dock it on the wireless charger.',
        timestamp: now.subtract(const Duration(days: 1)),
        type: NotificationType.smartCollar,
        petName: 'Max',
        isRead: true,
        actionLabel: 'Collar Status',
      ),
      NotificationItem(
        id: 'notif-5',
        title: 'Vet Appointment Confirmed',
        message: 'Routine health checkup with Dr. Watson confirmed for Saturday at 10:30 AM.',
        timestamp: now.subtract(const Duration(days: 2)),
        type: NotificationType.vetAppointment,
        petName: 'Bella',
        isRead: true,
        actionLabel: 'View Details',
      ),
    ]);
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (final item in _notifications) {
      if (!item.isRead) {
        item.isRead = true;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}

