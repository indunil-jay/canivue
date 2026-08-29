import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/vets/data/fake_appointment_repository.dart';
import 'package:canivue/features/vets/domain/appointment.dart';
import 'package:canivue/features/vets/domain/appointment_repository.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) => FakeAppointmentRepository());

final appointmentsProvider = FutureProvider.family<List<Appointment>, String>((ref, dogId) {
  return ref.watch(appointmentRepositoryProvider).fetchAppointments(dogId);
});

class AppointmentBookingController extends Notifier<AsyncValue<Appointment?>> {
  @override
  AsyncValue<Appointment?> build() => const AsyncData(null);

  Future<void> book({
    required String vetId,
    required String vetName,
    required String dogId,
    required String dogName,
    required DateTime dateTime,
    required ConsultationType consultationType,
    required double feeUsd,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(appointmentRepositoryProvider).bookAppointment(
          vetId: vetId,
          vetName: vetName,
          dogId: dogId,
          dogName: dogName,
          dateTime: dateTime,
          consultationType: consultationType,
          feeUsd: feeUsd,
        ));
    if (state.hasValue) {
      ref.invalidate(appointmentsProvider(dogId));
    }
  }

  void reset() => state = const AsyncData(null);
}

final appointmentBookingControllerProvider = NotifierProvider<AppointmentBookingController, AsyncValue<Appointment?>>(
  AppointmentBookingController.new,
);
