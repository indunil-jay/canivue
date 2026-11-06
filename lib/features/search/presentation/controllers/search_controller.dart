import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';
import 'package:canivue/features/vets/domain/vet_repository.dart';
import 'package:canivue/features/vets/presentation/controllers/vet_controller.dart';

/// Search filter scopes for filtering across specific entity types.
enum SearchScope {
  all,
  diseaseGroups,
  veterinarians,
  dogs,
  communityPosts,
}

/// Currently active scope filter in the search screen.
final searchScopeProvider = StateProvider.autoDispose<SearchScope>((ref) => SearchScope.all);

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
  List<String> build() => ['Skin Allergies', 'Dr. Amara Osei', 'Arthritis'];

  void add(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    state = [trimmed, ...state.where((q) => q.toLowerCase() != trimmed.toLowerCase())].take(8).toList();
  }

  void remove(String query) {
    state = state.where((q) => q != query).toList();
  }

  void clear() => state = [];
}

final recentSearchesProvider = NotifierProvider<RecentSearchesController, List<String>>(RecentSearchesController.new);

const suggestedSearches = [
  'Skin Allergies',
  'Arthritis & Mobility',
  'Canine Obesity',
  'Diabetes Monitoring',
  'Dr. Amara Osei',
  'Dr. Robert Miller',
  'Joint Stiffness',
  'Ear Infection',
  'Heart Rate Telemetry',
  'Vaccination Schedule',
];

const quickSymptomPills = [
  {'emoji': '🐾', 'label': 'Paw Licking', 'query': 'Skin Allergies'},
  {'emoji': '🦴', 'label': 'Limping', 'query': 'Arthritis'},
  {'emoji': '🥗', 'label': 'Weight Control', 'query': 'Obesity'},
  {'emoji': '🩸', 'label': 'High Thirst', 'query': 'Diabetes'},
  {'emoji': '🥣', 'label': 'Sensitive Stomach', 'query': 'Digestive'},
  {'emoji': '❤️', 'label': 'Coughing', 'query': 'Heart Conditions'},
];
