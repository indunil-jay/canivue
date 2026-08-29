import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';
import 'package:canivue/features/vets/domain/vet_repository.dart';
import 'package:canivue/features/vets/presentation/controllers/vet_controller.dart';

/// Every veterinarian, for client-side filtering by the global search
/// screen — kept separate from [vetSearchResultsProvider], which backs the
/// Vet Discovery screen's own query/filter UI state.
final allVetsProvider = FutureProvider.autoDispose<List<Veterinarian>>((ref) {
  return ref.watch(vetRepositoryProvider).search('', const VetSearchFilters());
});

/// Global search state (brief §28): the active query plus a small
/// in-memory history of recent searches for this session.
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class RecentSearchesController extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void add(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    state = [trimmed, ...state.where((q) => q.toLowerCase() != trimmed.toLowerCase())].take(8).toList();
  }

  void clear() => state = [];
}

final recentSearchesProvider = NotifierProvider<RecentSearchesController, List<String>>(RecentSearchesController.new);

const suggestedSearches = ['Vaccinations', 'Skin Allergies', 'Weight Loss', 'Dermatology', 'Golden Retriever'];
