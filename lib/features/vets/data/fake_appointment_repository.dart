import 'package:canivue/features/vets/domain/appointment.dart';
import 'package:canivue/features/vets/domain/appointment_repository.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';

/// In-memory appointment store, seeded with a little history so the list
/// isn't empty on first load, but freely growable via [bookAppointment].
class FakeAppointmentRepository implements AppointmentRepository {
  final List<Appointment> _appointments = [
    Appointment(
      id: 'appt-seed-1',
      vetId: 'vet-1',
      vetName: 'Dr. Sarah Jenkins',
      dogId: 'pet-1',
      dogName: 'Buddy',
      dateTime: DateTime.now().subtract(const Duration(days: 30)),
      status: AppointmentStatus.completed,
      consultationType: ConsultationType.inPerson,
      feeUsd: 45,
      notes: 'Annual wellness checkup.',
    ),
  ];

  @override
  Future<List<Appointment>> fetchAppointments(String dogId) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final results = _appointments.where((a) => a.dogId == dogId).toList();
    results.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return results;
  }

  @override
  Future<Appointment> bookAppointment({
    required String vetId,
    required String vetName,
    required String dogId,
    required String dogName,
    required DateTime dateTime,
    required ConsultationType consultationType,
    required double feeUsd,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final appointment = Appointment(
      id: 'appt-${DateTime.now().microsecondsSinceEpoch}',
      vetId: vetId,
      vetName: vetName,
      dogId: dogId,
      dogName: dogName,
      dateTime: dateTime,
      status: AppointmentStatus.confirmed,
      consultationType: consultationType,
      feeUsd: feeUsd,
    );
    _appointments.add(appointment);
    return appointment;
  }

  @override
  Future<Appointment> cancelAppointment(String appointmentId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    final updated = _appointments[index].copyWith(status: AppointmentStatus.cancelled);
    _appointments[index] = updated;
    return updated;
  }
}
