import 'package:canivue/features/vets/domain/veterinarian.dart';

enum AppointmentStatus { requested, confirmed, upcoming, inProgress, completed, cancelled, noShow }

extension AppointmentStatusLabel on AppointmentStatus {
  String get label => switch (this) {
        AppointmentStatus.requested => 'Requested',
        AppointmentStatus.confirmed => 'Confirmed',
        AppointmentStatus.upcoming => 'Upcoming',
        AppointmentStatus.inProgress => 'In Progress',
        AppointmentStatus.completed => 'Completed',
        AppointmentStatus.cancelled => 'Cancelled',
        AppointmentStatus.noShow => 'No-show',
      };
}

class Appointment {
  const Appointment({
    required this.id,
    required this.vetId,
    required this.vetName,
    required this.dogId,
    required this.dogName,
    required this.dateTime,
    required this.status,
    required this.consultationType,
    required this.feeUsd,
    this.notes = '',
  });

  final String id;
  final String vetId;
  final String vetName;
  final String dogId;
  final String dogName;
  final DateTime dateTime;
  final AppointmentStatus status;
  final ConsultationType consultationType;
  final double feeUsd;
  final String notes;

  Appointment copyWith({AppointmentStatus? status, DateTime? dateTime}) {
    return Appointment(
      id: id,
      vetId: vetId,
      vetName: vetName,
      dogId: dogId,
      dogName: dogName,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      consultationType: consultationType,
      feeUsd: feeUsd,
      notes: notes,
    );
  }
}
