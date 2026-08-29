import 'package:canivue/features/home/domain/dashboard_summary.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> fetchSummary(String dogId);
}
