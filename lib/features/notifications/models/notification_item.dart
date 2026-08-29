import 'package:flutter/material.dart';

enum NotificationType {
  aiHealthAlert,
  vaccineReminder,
  activityGoal,
  smartCollar,
  vetAppointment,
  vetMessage,
  medicationReminder,
  communityActivity,
  billing,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final String petName;
  final String? petAvatar;
  bool isRead;
  final String? actionLabel;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.petName,
    this.petAvatar,
    this.isRead = false,
    this.actionLabel,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    String? petName,
    String? petAvatar,
    bool? isRead,
    String? actionLabel,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      petName: petName ?? this.petName,
      petAvatar: petAvatar ?? this.petAvatar,
      isRead: isRead ?? this.isRead,
      actionLabel: actionLabel ?? this.actionLabel,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.aiHealthAlert:
        return Icons.health_and_safety_rounded;
      case NotificationType.vaccineReminder:
        return Icons.vaccines_rounded;
      case NotificationType.activityGoal:
        return Icons.emoji_events_rounded;
      case NotificationType.smartCollar:
        return Icons.bluetooth_connected_rounded;
      case NotificationType.vetAppointment:
        return Icons.medical_services_rounded;
      case NotificationType.vetMessage:
        return Icons.chat_bubble_rounded;
      case NotificationType.medicationReminder:
        return Icons.medication_rounded;
      case NotificationType.communityActivity:
        return Icons.groups_rounded;
      case NotificationType.billing:
        return Icons.receipt_long_rounded;
    }
  }

  /// Broad grouping bucket used for "N new X" notification summaries
  /// (brief §25) rather than listing every notification individually.
  String get category {
    switch (type) {
      case NotificationType.aiHealthAlert:
        return 'Health Alerts';
      case NotificationType.vaccineReminder:
        return 'Vaccination Reminders';
      case NotificationType.medicationReminder:
        return 'Medication Reminders';
      case NotificationType.activityGoal:
        return 'Activity';
      case NotificationType.smartCollar:
        return 'Device Alerts';
      case NotificationType.vetAppointment:
        return 'Appointments';
      case NotificationType.vetMessage:
        return 'Veterinary Messages';
      case NotificationType.communityActivity:
        return 'Community Activity';
      case NotificationType.billing:
        return 'Subscription & Billing';
    }
  }

  Color get accentColor {
    switch (type) {
      case NotificationType.aiHealthAlert:
        return const Color(0xFFF43F5E); // Rose/Coral
      case NotificationType.vaccineReminder:
        return const Color(0xFFF59E0B); // Amber
      case NotificationType.activityGoal:
        return const Color(0xFF10B981); // Emerald
      case NotificationType.smartCollar:
        return const Color(0xFF0066FF); // Sapphire
      case NotificationType.vetAppointment:
        return const Color(0xFF8B5CF6); // Violet
      case NotificationType.vetMessage:
        return const Color(0xFF0F766E); // Teal
      case NotificationType.medicationReminder:
        return const Color(0xFFF59E0B); // Amber
      case NotificationType.communityActivity:
        return const Color(0xFF6366F1); // Indigo
      case NotificationType.billing:
        return const Color(0xFF64748B); // Slate
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}

