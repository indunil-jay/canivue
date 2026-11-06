import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/features/community/domain/community_post.dart';
import 'package:canivue/features/community/presentation/controllers/community_controller.dart';
import 'package:canivue/features/community/presentation/screens/community_detail_screen.dart';
import 'package:canivue/features/pets/presentation/controllers/dogs_controller.dart';
import 'package:canivue/features/pets/screens/pet_detail_screen.dart';
import 'package:canivue/features/search/presentation/controllers/search_controller.dart';
import 'package:canivue/features/vets/presentation/screens/vet_profile_screen.dart';

/// Global canine telemetry & marketplace search: dogs, clinicians, disease groups,
/// and community discussions.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    super.key,
    this.initialQuery,
    this.initialScope,
  });

  final String? initialQuery;
  final SearchScope? initialScope;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');

    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
        ref.read(searchQueryProvider.notifier).state = widget.initialQuery!.trim();
      }
      if (widget.initialScope != null) {
        ref.read(searchScopeProvider.notifier).state = widget.initialScope!;
      }
      _focusNode.requestFocus();
    });
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
    if (query.trim().isNotEmpty) {
      ref.read(recentSearchesProvider.notifier).add(query);
    }
  }

  void _clearSearch() {
    HapticFeedback.lightImpact();
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final activeScope = ref.watch(searchScopeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: false,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Premium Search Header Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    // Back button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: isDark ? Colors.white : const Color(0xFF181A20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Interactive Search Bar Input
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _isFocused
                                ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E))
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: _isFocused ? 1.8 : 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isFocused
                                  ? const Color(0xFF0F766E).withValues(alpha: isDark ? 0.3 : 0.12)
                                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: _isFocused ? 14 : 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              size: 20,
                              color: _isFocused
                                  ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E))
                                  : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                textInputAction: TextInputAction.search,
                                onChanged: (value) {
                                  ref.read(searchQueryProvider.notifier).state = value;
                                  setState(() {});
                                },
                                onSubmitted: _runSearch,
                                style: GoogleFonts.plusJakartaSans(
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search pets, clinicians, diseases...',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            if (_controller.text.isNotEmpty)
                              GestureDetector(
                                onTap: _clearSearch,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFE5E7EB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: isDark ? Colors.white : const Color(0xFF4B5563),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Horizontal Scope Filter Pills (All, Groups, Clinicians, Dogs, Feed)
              if (query.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _scopePill(
                          label: 'All Results',
                          scope: SearchScope.all,
                          activeScope: activeScope,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _scopePill(
                          label: '🐾 Disease Groups',
                          scope: SearchScope.diseaseGroups,
                          activeScope: activeScope,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _scopePill(
                          label: '🩺 Clinicians',
                          scope: SearchScope.veterinarians,
                          activeScope: activeScope,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _scopePill(
                          label: '🐶 Pets',
                          scope: SearchScope.dogs,
                          activeScope: activeScope,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _scopePill(
                          label: '💬 Discussions',
                          scope: SearchScope.communityPosts,
                          activeScope: activeScope,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. Search Results or Suggestions
              Expanded(
                child: query.trim().isEmpty
                    ? _buildSuggestions(context, isDark)
                    : _SearchResults(
                        query: query.trim(),
                        scope: activeScope,
                        onOpenCommunity: (comm) {
                          _runSearch(query);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CommunityDetailScreen(community: comm),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scopePill({
    required String label,
    required SearchScope scope,
    required SearchScope activeScope,
    required bool isDark,
  }) {
    final isSelected = scope == activeScope;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(searchScopeProvider.notifier).state = scope;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF0F766E) : const Color(0xFF181A20))
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF181A20))
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, bool isDark) {
    final recent = ref.watch(recentSearchesProvider);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
      children: [
        // Quick Symptom Search Buttons
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'QUICK SYMPTOM CHECKS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFF0F766E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickSymptomPills.map((item) {
            return InkWell(
              onTap: () {
                final query = item['query']!;
                _controller.text = query;
                _runSearch(query);
                setState(() {});
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item['emoji']!, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      item['label']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Recent Searches
        if (recent.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(recentSearchesProvider.notifier).clear();
                },
                child: Text(
                  'Clear all',
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent.map((q) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _controller.text = q;
                      _runSearch(q);
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
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
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              ref.read(recentSearchesProvider.notifier).remove(q);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: Icon(
                                Icons.close_rounded,
                                size: 13,
                                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Trending Topics & Conditions
        Text(
          'Trending Clinical Topics',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestedSearches.map((q) {
            return InkWell(
              onTap: () {
                _controller.text = q;
                _runSearch(q);
                setState(() {});
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
                  ),
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
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({
    required this.query,
    required this.scope,
    required this.onOpenCommunity,
  });

  final String query;
  final SearchScope scope;
  final ValueChanged<DiseaseCommunity> onOpenCommunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lower = query.toLowerCase();

    final dogsAsync = ref.watch(dogsProvider);
    final vetsAsync = ref.watch(allVetsProvider);
    final communitiesAsync = ref.watch(communitiesControllerProvider);
    final postsAsync = ref.watch(communityFeedControllerProvider);

    final dogs = (dogsAsync.value ?? const [])
        .where((d) =>
            d.name.toLowerCase().contains(lower) ||
            d.breed.toLowerCase().contains(lower) ||
            d.microchipId.toLowerCase().contains(lower))
        .toList();

    final vets = (vetsAsync.value ?? const [])
        .where((v) =>
            v.name.toLowerCase().contains(lower) ||
            v.specialty.toLowerCase().contains(lower) ||
            v.bio.toLowerCase().contains(lower) ||
            v.clinics.any((c) => c.toLowerCase().contains(lower)))
        .toList();

    final communities = (communitiesAsync.value ?? const [])
        .where((c) =>
            c.name.toLowerCase().contains(lower) ||
            c.description.toLowerCase().contains(lower) ||
            c.leadVetName.toLowerCase().contains(lower))
        .toList();

    final posts = (postsAsync.value ?? const [])
        .where((p) =>
            p.content.toLowerCase().contains(lower) ||
            p.communityTag.toLowerCase().contains(lower) ||
            p.authorName.toLowerCase().contains(lower))
        .toList();

    final showCommunities = (scope == SearchScope.all || scope == SearchScope.diseaseGroups) && communities.isNotEmpty;
    final showVets = (scope == SearchScope.all || scope == SearchScope.veterinarians) && vets.isNotEmpty;
    final showDogs = (scope == SearchScope.all || scope == SearchScope.dogs) && dogs.isNotEmpty;
    final showPosts = (scope == SearchScope.all || scope == SearchScope.communityPosts) && posts.isNotEmpty;

    final hasAny = showCommunities || showVets || showDogs || showPosts;

    if (!hasAny) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🐾', style: TextStyle(fontSize: 34)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No results for "$query"',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Try searching for pet names, breeds, vet specialties, or health conditions.',
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
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 40),
      children: [
        // 1. Disease Groups Found
        if (showCommunities)
          ..._section(
            context,
            '🐾 Disease Groups (${communities.length})',
            [
              for (final c in communities)
                _resultCard(
                  leadingWidget: Text(c.coverEmoji, style: const TextStyle(fontSize: 22)),
                  title: c.name,
                  subtitle: '${c.memberCount} members · Lead: ${c.leadVetName.split(',').first}',
                  badgeText: c.joined ? 'Joined' : 'Join Group',
                  badgeColor: c.joined ? const Color(0xFF10B981) : const Color(0xFF0F766E),
                  onTap: () => onOpenCommunity(c),
                  isDark: isDark,
                ),
            ],
            isDark,
          ),

        // 2. Clinicians Found
        if (showVets)
          ..._section(
            context,
            '🩺 Veterinarians (${vets.length})',
            [
              for (final vet in vets)
                _resultCard(
                  leadingWidget: const Text('👨‍⚕️', style: TextStyle(fontSize: 22)),
                  title: vet.name,
                  subtitle: '${vet.specialty} · \$${vet.consultationFeeUsd.toStringAsFixed(0)} consult · ★ 4.9',
                  badgeText: 'Verified',
                  badgeColor: const Color(0xFF10B981),
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

        // 3. Dogs Found
        if (showDogs)
          ..._section(
            context,
            '🐶 Dogs (${dogs.length})',
            [
              for (final dog in dogs)
                _resultCard(
                  leadingWidget: const Text('🐕', style: TextStyle(fontSize: 22)),
                  title: dog.name,
                  subtitle: '${dog.breed} · ${dog.ageYears} yrs · ${dog.weightKg} kg',
                  badgeText: 'Telemetry Active',
                  badgeColor: const Color(0xFF0284C7),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PetDetailScreen(pet: dog)),
                  ),
                  isDark: isDark,
                ),
            ],
            isDark,
          ),

        // 4. Community Posts Found
        if (showPosts)
          ..._section(
            context,
            '💬 Discussions (${posts.length})',
            [
              for (final post in posts)
                _resultCard(
                  leadingWidget: const Text('💬', style: TextStyle(fontSize: 20)),
                  title: post.communityTag,
                  subtitle: '${post.authorName}: ${post.content}',
                  badgeText: post.isVeterinarian ? 'Vet Verified' : null,
                  badgeColor: const Color(0xFF7A67EE),
                  onTap: () {
                    // Match community and open
                    final comm = (communitiesAsync.value ?? const []).firstWhere(
                      (c) => c.name.toLowerCase() == post.communityTag.toLowerCase(),
                      orElse: () => (communitiesAsync.value ?? const []).isNotEmpty
                          ? communitiesAsync.value!.first
                          : const DiseaseCommunity(
                              id: 'c-default',
                              name: 'Canine Care',
                              description: 'General pet care advice',
                              memberCount: 100,
                            ),
                    );
                    onOpenCommunity(comm);
                  },
                  isDark: isDark,
                ),
            ],
            isDark,
          ),
      ],
    );
  }

  Widget _resultCard({
    required Widget leadingWidget,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: leadingWidget),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: (badgeColor ?? const Color(0xFF0F766E)).withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                badgeText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: badgeColor ?? const Color(0xFF0F766E),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          height: 1.35,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _section(BuildContext context, String title, List<Widget> children, bool isDark) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ),
      ...children,
    ];
  }
}
