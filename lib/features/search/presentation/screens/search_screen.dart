import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/community/presentation/controllers/community_controller.dart';
import 'package:canivue/features/pets/presentation/controllers/dogs_controller.dart';
import 'package:canivue/features/pets/screens/pet_detail_screen.dart';
import 'package:canivue/features/search/presentation/controllers/search_controller.dart';
import 'package:canivue/features/vets/presentation/screens/vet_profile_screen.dart';

/// Global search (brief §28) across dogs, veterinarians and community
/// posts, with recent/suggested searches when there's no query yet.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _runSearch(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
    if (query.trim().isNotEmpty) ref.read(recentSearchesProvider.notifier).add(query);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground,
            borderRadius: AppRadius.pillRadius,
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 18, color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (value) => setState(() {}),
                  onSubmitted: _runSearch,
                  decoration: const InputDecoration(hintText: 'Search dogs, vets, posts...', border: InputBorder.none, isDense: true),
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                    setState(() {});
                  },
                  child: Icon(Icons.close_rounded, size: 18, color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                ),
            ],
          ),
        ),
      ),
      body: query.trim().isEmpty ? _buildSuggestions(context) : _SearchResults(query: query),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final recent = ref.watch(recentSearchesProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (recent.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Searches', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => ref.read(recentSearchesProvider.notifier).clear(), child: const Text('Clear')),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent
                .map((q) => ActionChip(
                      avatar: const Icon(Icons.history_rounded, size: 16),
                      label: Text(q),
                      onPressed: () {
                        _controller.text = q;
                        _runSearch(q);
                        setState(() {});
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
        Text('Suggested', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestedSearches
              .map((q) => ActionChip(
                    avatar: Icon(Icons.trending_up_rounded, size: 16, color: isDark ? AppColors.primaryOnDark : AppColors.primary),
                    label: Text(q),
                    onPressed: () {
                      _controller.text = q;
                      _runSearch(q);
                      setState(() {});
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lower = query.toLowerCase();

    final dogsAsync = ref.watch(dogsProvider);
    final vetsAsync = ref.watch(allVetsProvider);
    final postsAsync = ref.watch(communityFeedControllerProvider);

    final dogs = (dogsAsync.value ?? const []).where((d) => d.name.toLowerCase().contains(lower) || d.breed.toLowerCase().contains(lower)).toList();
    final vets = (vetsAsync.value ?? const []).where((v) => v.name.toLowerCase().contains(lower) || v.specialty.toLowerCase().contains(lower)).toList();
    final posts = (postsAsync.value ?? const []).where((p) => p.content.toLowerCase().contains(lower) || p.communityTag.toLowerCase().contains(lower)).toList();

    final hasAny = dogs.isNotEmpty || vets.isNotEmpty || posts.isNotEmpty;

    if (!hasAny) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('No results for "$query"', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (dogs.isNotEmpty) ..._section(context, 'Dogs', [
          for (final dog in dogs)
            ListTile(
              leading: const Icon(Icons.pets_rounded),
              title: Text(dog.name),
              subtitle: Text(dog.breed),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PetDetailScreen(pet: dog))),
            ),
        ]),
        if (vets.isNotEmpty) ..._section(context, 'Veterinarians', [
          for (final vet in vets)
            ListTile(
              leading: const Icon(Icons.medical_services_outlined),
              title: Text(vet.name),
              subtitle: Text(vet.specialty),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VetProfileScreen(vetId: vet.id, dogId: dogs.isNotEmpty ? dogs.first.id : '', dogName: dogs.isNotEmpty ? dogs.first.name : ''))),
            ),
        ]),
        if (posts.isNotEmpty) ..._section(context, 'Community Posts', [
          for (final post in posts)
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: Text(post.communityTag),
              subtitle: Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
        ]),
      ],
    );
  }

  List<Widget> _section(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return [
      Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      ...children,
      const SizedBox(height: AppSpacing.lg),
    ];
  }
}
