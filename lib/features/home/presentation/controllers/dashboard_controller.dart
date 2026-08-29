import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/home/data/fake_dashboard_repository.dart';
import 'package:canivue/features/home/domain/dashboard_repository.dart';
import 'package:canivue/features/home/domain/dashboard_summary.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) => FakeDashboardRepository());

/// Dashboard summary for one dog, keyed (`.family`) by `(id, name)` so the
/// cache is per-dog — switching the active dog re-fetches instead of
/// showing stale data — and the fake repository can personalize its
/// generated copy with the dog's actual name.
final dashboardSummaryProvider = FutureProvider.family<DashboardSummary, ({String id, String name})>((ref, dog) {
  return ref.watch(dashboardRepositoryProvider).fetchSummary(dog.id, dog.name);
});
