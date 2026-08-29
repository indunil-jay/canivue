import 'package:canivue/features/vet_portal/domain/vet_dashboard_summary.dart';
import 'package:canivue/features/vet_portal/domain/vet_patient.dart';
import 'package:canivue/features/vet_portal/domain/vet_reputation.dart';

abstract class VetPortalRepository {
  Future<VetDashboardSummary> fetchDashboard(String vetName);

  Future<List<VetPatient>> fetchPatients();

  Future<VetReputation> fetchReputation();

  /// Weekly availability — day label -> whether the vet is taking
  /// appointments that day.
  Future<Map<String, bool>> fetchAvailability();

  Future<Map<String, bool>> setAvailability(String day, bool available);
}
