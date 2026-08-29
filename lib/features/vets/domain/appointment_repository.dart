import 'package:canivue/features/vets/domain/appointment.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> fetchAppointments(String dogId);

  Future<Appointment> bookAppointment({
    required String vetId,
    required String vetName,
    required String dogId,
    required String dogName,
    required DateTime dateTime,
    required ConsultationType consultationType,
    required double feeUsd,
  });

  Future<Appointment> cancelAppointment(String appointmentId);
}
