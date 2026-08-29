import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/vet_portal/data/fake_vet_portal_repository.dart';
import 'package:canivue/features/vet_portal/domain/vet_dashboard_summary.dart';
import 'package:canivue/features/vet_portal/domain/vet_patient.dart';
import 'package:canivue/features/vet_portal/domain/vet_portal_repository.dart';
import 'package:canivue/features/vet_portal/domain/vet_reputation.dart';

final vetPortalRepositoryProvider = Provider<VetPortalRepository>((ref) => FakeVetPortalRepository());

final vetDashboardProvider = FutureProvider.family<VetDashboardSummary, String>((ref, vetName) {
  return ref.watch(vetPortalRepositoryProvider).fetchDashboard(vetName);
});

final vetPatientsProvider = FutureProvider<List<VetPatient>>((ref) {
  return ref.watch(vetPortalRepositoryProvider).fetchPatients();
});

final vetReputationProvider = FutureProvider<VetReputation>((ref) {
  return ref.watch(vetPortalRepositoryProvider).fetchReputation();
});

class VetAvailabilityController extends AsyncNotifier<Map<String, bool>> {
  @override
  Future<Map<String, bool>> build() {
    return ref.watch(vetPortalRepositoryProvider).fetchAvailability();
  }

  Future<void> setDay(String day, bool available) async {
    state = await AsyncValue.guard(() => ref.read(vetPortalRepositoryProvider).setAvailability(day, available));
  }
}

final vetAvailabilityControllerProvider = AsyncNotifierProvider<VetAvailabilityController, Map<String, bool>>(
  VetAvailabilityController.new,
);
