import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/domain/app_user.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/community/presentation/controllers/community_controller.dart';
import 'package:canivue/features/community/presentation/screens/community_detail_screen.dart';
import 'package:canivue/features/community/presentation/widgets/create_post_sheet.dart';
import 'package:canivue/features/community/presentation/widgets/post_card.dart';
import 'package:canivue/features/community/presentation/widgets/post_comments_sheet.dart';
import 'package:canivue/features/pets/presentation/controllers/dogs_controller.dart';

/// Threads/Facebook-style feed combining general community discussion with
/// vet-verified professional medical advice (brief §23-24).
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  int _tab = 0; // 0 = Feed, 1 = Communities

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: AmbientPawBackdrop(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Header Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: _buildHeader(context, isDark),
              ),

              // 2. Segmented Pill Tab Bar (Feed vs Communities)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF1EDE6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _tabButton(
                          title: 'Feed & Discussions',
                          icon: Icons.dynamic_feed_rounded,
                          selected: _tab == 0,
                          isDark: isDark,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _tab = 0);
                          },
                        ),
                      ),
                      Expanded(
                        child: _tabButton(
                          title: 'Disease Groups',
                          icon: Icons.groups_rounded,
                          selected: _tab == 1,
                          isDark: isDark,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _tab = 1);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 3. Tab Contents
              Expanded(
                child: _tab == 0
                    ? _FeedTab(
                        onOpenCreatePost: () => CreatePostSheet.show(context),
                      )
                    : _CommunitiesTab(
                        onSelectCommunity: (communityName) {
                          ref.read(communitySelectedFilterProvider.notifier).state = communityName;
                          setState(() => _tab = 0);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x228B5CF6) : AppColors.pastelLilac,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0x448B5CF6) : const Color(0xFFE2D9FC),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🐾', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    Text(
                      'CANINE COMMUNITY',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7A67EE),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Knowledge & Care',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        // Create Post Pill Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              CreatePostSheet.show(context);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Post',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabButton({
    required String title,
    required IconData icon,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? AppColors.darkCard : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected
                  ? (isDark ? Colors.white : const Color(0xFF181A20))
                  : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12.5,
                color: selected
                    ? (isDark ? Colors.white : const Color(0xFF181A20))
                    : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedTab extends ConsumerWidget {
  const _FeedTab({required this.onOpenCreatePost});

  final VoidCallback onOpenCreatePost;

  static const List<String> _filters = [
    'All',
    '🩺 Vet Advice',
    'Skin Allergies',
    'Arthritis',
    'Obesity',
    'Digestive Problems',
    'Saved 🔖',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(communityFeedControllerProvider);
    final activeFilter = ref.watch(communitySelectedFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = ref.watch(authControllerProvider);
    final activeDog = ref.watch(activeDogProvider).value;
    final authorName = user?.name.isNotEmpty == true
        ? user!.name
        : (activeDog != null ? '${activeDog.name}\'s Family' : 'Liam Parker');
    final isVet = user?.role == UserRole.veterinarian;

    return Column(
      children: [
        // Topic Filter Scrollable Pills
        Container(
          height: 38,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = activeFilter == filter || (filter == 'All' && activeFilter == 'All');

              return ChoiceChip(
                label: Text(
                  filter,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
                selected: isSelected,
                selectedColor: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                backgroundColor: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF1F5F9),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                showCheckmark: false,
                onSelected: (val) {
                  if (val) {
                    HapticFeedback.selectionClick();
                    ref.read(communitySelectedFilterProvider.notifier).state = filter;
                  }
                },
              );
            },
          ),
        ),

        // Posts List or States
        Expanded(
          child: feedAsync.when(
            loading: () => ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: SkeletonBox(height: 140, borderRadius: BorderRadius.all(Radius.circular(24))),
                ),
              ),
            ),
            error: (_, _) => ErrorState(
              message: "We couldn't load the feed.",
              onRetry: () => ref.invalidate(communityFeedControllerProvider),
            ),
            data: (allPosts) {
              // Apply active filter
              final filteredPosts = allPosts.where((p) {
                if (activeFilter == 'All') return true;
                if (activeFilter == '🩺 Vet Advice') return p.isVeterinarian;
                if (activeFilter == 'Saved 🔖') return p.savedByMe;
                return p.communityTag.toLowerCase() == activeFilter.toLowerCase();
              }).toList();

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => ref.invalidate(communityFeedControllerProvider),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 110),
                  children: [
                    // Quick Composer Card at the top of feed
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 38,
                                width: 38,
                                decoration: BoxDecoration(
                                  gradient: isVet
                                      ? AppColors.primaryGradient
                                      : const LinearGradient(
                                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                        ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    onOpenCreatePost();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF6F4EE),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'What\'s on your mind? Share tips or ask vets...',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(
                            height: 1,
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _quickAction(
                                icon: Icons.help_outline_rounded,
                                label: 'Ask Question',
                                color: const Color(0xFF0F766E),
                                onTap: onOpenCreatePost,
                              ),
                              _quickAction(
                                icon: Icons.tips_and_updates_outlined,
                                label: 'Share Tip',
                                color: const Color(0xFFD97706),
                                onTap: onOpenCreatePost,
                              ),
                              _quickAction(
                                icon: Icons.photo_library_outlined,
                                label: 'Add Photo',
                                color: const Color(0xFF7A67EE),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  onOpenCreatePost();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (filteredPosts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: EmptyState(
                          icon: Icons.forum_outlined,
                          title: activeFilter == 'Saved 🔖' ? 'No saved posts' : 'No posts in this topic',
                          message: activeFilter == 'Saved 🔖'
                              ? 'Tap the bookmark icon on any post to save it here for quick reference.'
                              : 'Be the first to share an update or question in $activeFilter!',
                        ),
                      )
                    else
                      for (final post in filteredPosts) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: PostCard(
                            post: post,
                            onLike: () => ref.read(communityFeedControllerProvider.notifier).toggleLike(post.id),
                            onSave: () => ref.read(communityFeedControllerProvider.notifier).toggleSave(post.id),
                            onComment: () => PostCommentsSheet.show(context, post),
                            onTopicTap: (tag) async {
                              final communities = ref.read(communitiesControllerProvider).value ?? [];
                              final match = communities.firstWhere(
                                (c) => c.name.toLowerCase() == tag.toLowerCase(),
                                orElse: () => communities.first,
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CommunityDetailScreen(community: match),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunitiesTab extends ConsumerWidget {
  const _CommunitiesTab({required this.onSelectCommunity});

  final ValueChanged<String> onSelectCommunity;

  static const List<Color> _pastels = [
    AppColors.pastelMint,
    AppColors.pastelAmber,
    AppColors.pastelLilac,
    AppColors.pastelSky,
  ];

  static const List<Color> _accents = [
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF7A67EE),
    Color(0xFF0284C7),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communitiesAsync = ref.watch(communitiesControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return communitiesAsync.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(20),
        children: List.generate(
          4,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SkeletonBox(height: 96, borderRadius: BorderRadius.all(Radius.circular(20))),
          ),
        ),
      ),
      error: (_, _) => ErrorState(
        message: "We couldn't load the disease communities.",
        onRetry: () => ref.invalidate(communitiesControllerProvider),
      ),
      data: (communities) => ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        itemCount: communities.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final c = communities[index];
          final accent = _accents[index % _accents.length];
          final pastel = _pastels[index % _pastels.length];

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CommunityDetailScreen(community: c),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: isDark ? accent.withValues(alpha: 0.2) : pastel,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            c.coverEmoji.isNotEmpty ? c.coverEmoji : '🐾',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    c.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${c.memberCount} members · Group Lead: ${(c.leadVetName.isNotEmpty ? c.leadVetName : 'Dr. Amara Osei').split(',').first}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(communitiesControllerProvider.notifier).toggleJoin(c.id);
                          AppFeedback.showToast(
                            context,
                            title: c.joined ? 'Left Group' : 'Joined! 🐾',
                            message: c.joined ? 'You left ${c.name}.' : 'You are now a member of ${c.name}.',
                            type: c.joined ? ToastType.info : ToastType.success,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: c.joined
                                ? (isDark ? const Color(0x2210B981) : AppColors.pastelMint)
                                : (isDark ? AppColors.charcoalBlack : const Color(0xFF181A20)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            c.joined ? 'Joined' : 'Join',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: c.joined
                                  ? (isDark ? const Color(0xFF34D399) : const Color(0xFF0F766E))
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    c.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // View Group Hub Action
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.groups_rounded, size: 14, color: Color(0xFF0F766E)),
                            const SizedBox(width: 5),
                            Text(
                              'Open Group Hub & Members',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F766E),
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.arrow_forward_rounded, size: 13, color: Color(0xFF0F766E)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Filter in feed
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onSelectCommunity(c.name);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                          child: Text(
                            'Feed',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
