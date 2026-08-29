import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/home/data/fake_dashboard_repository.dart';
import 'package:canivue/features/home/domain/dashboard_repository.dart';
import 'package:canivue/features/home/domain/dashboard_summary.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) => FakeDashboardRepository());

/// Dashboard summary for one dog. Keyed (`.family`) by dog id so the cache
/// is per-dog and switching the active dog re-fetches instead of showing
/// stale data.
final dashboardSummaryProvider = FutureProvider.family<DashboardSummary, String>((ref, dogId) {
  return ref.watch(dashboardRepositoryProvider).fetchSummary(dogId);
});
