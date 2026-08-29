import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/vets/data/fake_vet_repository.dart';
import 'package:canivue/features/vets/domain/vet_repository.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';

final vetRepositoryProvider = Provider<VetRepository>((ref) => FakeVetRepository());

final vetSearchQueryProvider = StateProvider<String>((ref) => '');
final vetSearchFiltersProvider = StateProvider<VetSearchFilters>((ref) => const VetSearchFilters());

typedef VetSearchArgs = ({String query, VetSearchFilters filters});

final vetSearchResultsProvider = FutureProvider.autoDispose<List<Veterinarian>>((ref) {
  final query = ref.watch(vetSearchQueryProvider);
  final filters = ref.watch(vetSearchFiltersProvider);
  return ref.watch(vetRepositoryProvider).search(query, filters);
});

final vetDetailProvider = FutureProvider.family<Veterinarian, String>((ref, vetId) {
  return ref.watch(vetRepositoryProvider).fetchVet(vetId);
});
