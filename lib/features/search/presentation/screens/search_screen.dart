import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/features/community/presentation/controllers/community_controller.dart';
import 'package:canivue/features/pets/presentation/controllers/dogs_controller.dart';
import 'package:canivue/features/pets/screens/pet_detail_screen.dart';
import 'package:canivue/features/search/presentation/controllers/search_controller.dart';
import 'package:canivue/features/vets/presentation/screens/vet_profile_screen.dart';

/// Global canine telemetry & marketplace search: dogs, clinicians, conditions,
/// and community discussions.
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
    HapticFeedback.lightImpact();
    ref.read(searchQueryProvider.notifier).state = query;
    if (query.trim().isNotEmpty) ref.read(recentSearchesProvider.notifier).add(query);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF181A20),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 20,
                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (value) => setState(() {}),
                  onSubmitted: _runSearch,
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search pets, clinicians, advice...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                      fontSize: 13.5,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                    setState(() {});
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
            ],
          ),
        ),
      ),
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: false,
        child: query.trim().isEmpty ? _buildSuggestions(context) : _SearchResults(query: query),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recent = ref.watch(recentSearchesProvider);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        if (recent.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(recentSearchesProvider.notifier).clear();
                },
                child: Text(
                  'Clear',
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? AppColors.primaryOnDark : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent
                .map(
                  (q) => InkWell(
                    onTap: () {
                      _controller.text = q;
                      _runSearch(q);
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 15,
                            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            q,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
        ],

        Text(
          'Trending Topics & Conditions',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestedSearches
              .map(
                (q) => InkWell(
                  onTap: () {
                    _controller.text = q;
                    _runSearch(q);
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up_rounded, size: 15, color: Color(0xFF0F766E)),
                        const SizedBox(width: 6),
                        Text(
                          q,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.primaryOnDark : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lower = query.toLowerCase();

    final dogsAsync = ref.watch(dogsProvider);
    final vetsAsync = ref.watch(allVetsProvider);
    final postsAsync = ref.watch(communityFeedControllerProvider);

    final dogs = (dogsAsync.value ?? const [])
        .where((d) => d.name.toLowerCase().contains(lower) || d.breed.toLowerCase().contains(lower))
        .toList();
    final vets = (vetsAsync.value ?? const [])
        .where((v) => v.name.toLowerCase().contains(lower) || v.specialty.toLowerCase().contains(lower))
        .toList();
    final posts = (postsAsync.value ?? const [])
        .where((p) => p.content.toLowerCase().contains(lower) || p.communityTag.toLowerCase().contains(lower))
        .toList();

    final hasAny = dogs.isNotEmpty || vets.isNotEmpty || posts.isNotEmpty;

    if (!hasAny) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔍', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              Text(
                'No results for "$query"',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try searching for pet names, breeds, doctor specialties, or symptoms.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      children: [
        if (dogs.isNotEmpty) ..._section(
          context,
          '🐶 Dogs Found',
          [
            for (final dog in dogs)
              _resultCard(
                leadingText: '🐕',
                title: dog.name,
                subtitle: '${dog.breed} · ${dog.ageYears}y',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PetDetailScreen(pet: dog))),
                isDark: isDark,
              ),
          ],
          isDark,
        ),
        if (vets.isNotEmpty) ..._section(
          context,
          '🩺 Veterinarians',
          [
            for (final vet in vets)
              _resultCard(
                leadingText: '👨‍⚕️',
                title: vet.name,
                subtitle: '${vet.specialty} · \$${vet.consultationFeeUsd.toStringAsFixed(0)} consult',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VetProfileScreen(
                      vetId: vet.id,
                      dogId: dogs.isNotEmpty ? dogs.first.id : '',
                      dogName: dogs.isNotEmpty ? dogs.first.name : 'Patient',
                    ),
                  ),
                ),
                isDark: isDark,
              ),
          ],
          isDark,
        ),
        if (posts.isNotEmpty) ..._section(
          context,
          '💬 Community Discussions',
          [
            for (final post in posts)
              _resultCard(
                leadingText: '🐾',
                title: post.communityTag,
                subtitle: post.content,
                onTap: () {},
                isDark: isDark,
              ),
          ],
          isDark,
        ),
      ],
    );
  }

  Widget _resultCard({
    required String leadingText,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
      ),
      child: ListTile(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(leadingText, style: const TextStyle(fontSize: 18))),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
      ),
    );
  }

  List<Widget> _section(BuildContext context, String title, List<Widget> children, bool isDark) {
    return [
      Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      const SizedBox(height: 8),
      ...children,
      const SizedBox(height: 14),
    ];
  }
}
