import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/vets/domain/vet_repository.dart';
import 'package:canivue/features/vets/presentation/controllers/vet_controller.dart';
import 'package:canivue/features/vets/presentation/screens/vet_profile_screen.dart';
import 'package:canivue/features/vets/presentation/widgets/vet_card.dart';

/// Veterinarian discovery — search/filter marketplace (brief §16). The
/// active dog is passed through so booking, once reached from here, knows
/// which dog the consultation is for.
class VetDiscoveryScreen extends ConsumerWidget {
  const VetDiscoveryScreen({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  static const _specialties = ['Internal Medicine', 'Orthopedics', 'Dermatology', 'General Practice', 'Nutrition'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(vetSearchResultsProvider);
    final filters = ref.watch(vetSearchFiltersProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Find a Veterinarian')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: AppRadius.xlRadius,
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: (value) => ref.read(vetSearchQueryProvider.notifier).state = value,
                      decoration: const InputDecoration(hintText: 'Search by name or specialty', border: InputBorder.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                FilterChip(
                  label: const Text('Available Today'),
                  selected: filters.availableTodayOnly,
                  onSelected: (selected) => ref.read(vetSearchFiltersProvider.notifier).state = VetSearchFilters(
                    specialty: filters.specialty,
                    availableTodayOnly: selected,
                    consultationType: filters.consultationType,
                  ),
                ),
                const SizedBox(width: 8),
                for (final specialty in _specialties) ...[
                  FilterChip(
                    label: Text(specialty),
                    selected: filters.specialty == specialty,
                    onSelected: (selected) => ref.read(vetSearchFiltersProvider.notifier).state = VetSearchFilters(
                      specialty: selected ? specialty : null,
                      availableTodayOnly: filters.availableTodayOnly,
                      consultationType: filters.consultationType,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: resultsAsync.when(
              loading: () => ListView(
                padding: const EdgeInsets.all(20),
                children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 16), child: SkeletonBox(height: 110))),
              ),
              error: (_, _) => ErrorState(message: "We couldn't load veterinarians.", onRetry: () => ref.invalidate(vetSearchResultsProvider)),
              data: (vets) {
                if (vets.isEmpty) {
                  return const EmptyState(icon: Icons.search_off_rounded, title: 'No veterinarians found', message: 'Try a different search term or clear your filters.');
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: vets.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) => VetCard(
                    vet: vets[index],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => VetProfileScreen(vetId: vets[index].id, dogId: dogId, dogName: dogName)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
