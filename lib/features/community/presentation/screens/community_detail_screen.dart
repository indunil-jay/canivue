import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/core/widgets/canivue_paw_bone_logo.dart';
import 'package:canivue/features/community/domain/community_post.dart';
import 'package:canivue/features/community/presentation/controllers/community_controller.dart';
import 'package:canivue/features/community/presentation/widgets/create_post_sheet.dart';
import 'package:canivue/features/community/presentation/widgets/post_card.dart';
import 'package:canivue/features/community/presentation/widgets/post_comments_sheet.dart';

/// Dedicated Facebook Group-style community hub for a specific canine disease/topic.
/// Features Group Posts, Member Directory, Verified Vet Leads, and Community Rules.
class CommunityDetailScreen extends ConsumerStatefulWidget {
  const CommunityDetailScreen({super.key, required this.community});

  final DiseaseCommunity community;

  @override
  ConsumerState<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Watch live community state for dynamic joined/memberCount updates
    final communities = ref.watch(communitiesControllerProvider).value ?? [];
    final community = communities.firstWhere(
      (c) => c.id == widget.community.id || c.name == widget.community.name,
      orElse: () => widget.community,
    );

    // Watch live feed filtered to this community
    final allPosts = ref.watch(communityFeedControllerProvider).value ?? [];
    final communityPosts = allPosts.where((p) => p.communityTag.toLowerCase() == community.name.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Hero Group Header Sliver
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
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
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.share_outlined,
                      color: isDark ? Colors.white : const Color(0xFF181A20),
                      size: 20,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Clipboard.setData(ClipboardData(text: 'Join the ${community.name} canine support group on Canivue!'));
                      AppFeedback.showToast(
                        context,
                        title: 'Group Link Copied 📋',
                        message: 'Share this community link with other pet parents.',
                        type: ToastType.success,
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildGroupHero(context, community, isDark),
                ),
              ),

              // Group Segmented Tab Bar (Posts vs Members)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabHeaderDelegate(
                  child: Container(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF1EDE6),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: isDark ? AppColors.charcoalBlack : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: isDark ? Colors.white : const Color(0xFF181A20),
                        unselectedLabelColor: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w800),
                        unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600),
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(text: 'Discussions (${communityPosts.length})'),
                          Tab(text: 'Members (${community.members.isNotEmpty ? community.members.length : 5})'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // 1. Group Posts Tab
              _buildPostsTab(context, community, communityPosts, isDark),

              // 2. Group Members & Vets Tab
              _buildMembersTab(context, community, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHero(BuildContext context, DiseaseCommunity community, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F1E29), const Color(0xFF081219)]
              : [const Color(0xFFFAF7F2), const Color(0xFFF2ECE1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? const Color(0x3314B8A6) : const Color(0xFFBFE7DC),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    community.coverEmoji.isNotEmpty ? community.coverEmoji : '🐾',
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
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
                            community.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF10B981)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${community.memberCount} Pet Parents & Vets · Canine Sanctuary',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Community Summary
          Text(
            community.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              height: 1.35,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 14),

          // Join / Leave Button & Quick Post Action
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    ref.read(communitiesControllerProvider.notifier).toggleJoin(community.id);
                    AppFeedback.showToast(
                      context,
                      title: community.joined ? 'Left Community' : 'Joined ${community.name}! 🐾',
                      message: community.joined
                          ? 'You will no longer receive notifications from this group.'
                          : 'Welcome to the group! Feel free to introduce your dog.',
                      type: community.joined ? ToastType.info : ToastType.success,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: community.joined
                        ? (isDark ? const Color(0x2210B981) : AppColors.pastelMint)
                        : (isDark ? AppColors.charcoalBlack : const Color(0xFF181A20)),
                    foregroundColor: community.joined
                        ? const Color(0xFF0F766E)
                        : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: Icon(
                    community.joined ? Icons.check_circle_rounded : Icons.group_add_rounded,
                    size: 17,
                  ),
                  label: Text(
                    community.joined ? 'Joined Member' : 'Join Group',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  CreatePostSheet.show(context, initialTopic: community.name);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : const Color(0xFF181A20),
                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                label: Text(
                  'Post',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab(
    BuildContext context,
    DiseaseCommunity community,
    List<CommunityPost> posts,
    bool isDark,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 90),
      children: [
        // Pinned Lead Vet Welcome Notice
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x1814B8A6) : AppColors.pastelMint,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0x3314B8A6) : const Color(0xFFCCEBE3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F766E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.push_pin_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'PINNED CLINICAL ANNOUNCEMENT',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          (community.leadVetName.isNotEmpty ? community.leadVetName : 'Dr. Amara Osei').split(',').first,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome to the ${community.name} community. Please post observations, photos of symptoms, or medication experiences. Verified doctors actively triage this feed daily.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        height: 1.4,
                        color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Quick Post Prompt Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const CanivuePawBoneLogo(size: 26, color: Color(0xFF0F766E)),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    CreatePostSheet.show(context, initialTopic: community.name);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF6F4EE),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'Write to ${community.name}...',
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
        ),
        const SizedBox(height: 14),

        // Feed Posts
        if (posts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: EmptyState(
              icon: Icons.forum_outlined,
              title: 'No discussions yet',
              message: 'Be the first pet parent to ask a question or share advice in ${community.name}!',
            ),
          )
        else
          for (final post in posts) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: PostCard(
                post: post,
                onLike: () => ref.read(communityFeedControllerProvider.notifier).toggleLike(post.id),
                onSave: () => ref.read(communityFeedControllerProvider.notifier).toggleSave(post.id),
                onComment: () => PostCommentsSheet.show(context, post),
              ),
            ),
          ],
      ],
    );
  }

  Widget _buildMembersTab(
    BuildContext context,
    DiseaseCommunity community,
    bool isDark,
  ) {
    final members = community.members;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 90),
      children: [
        // Community Guidelines Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.gavel_rounded, size: 16, color: Color(0xFF0F766E)),
                  const SizedBox(width: 8),
                  Text(
                    'COMMUNITY RULES & SAFETY',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: const Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final rule in community.rules)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🐾 ', style: TextStyle(fontSize: 11)),
                      Expanded(
                        child: Text(
                          rule,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            height: 1.35,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Lead Doctor Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x1814B8A6) : AppColors.pastelMint,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? const Color(0x3314B8A6) : const Color(0xFFBFE7DC),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.medical_services_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          community.leadVetName,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      community.leadVetRole,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF0F766E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Group Lead',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F766E),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Members Heading
        Text(
          'COMMUNITY MEMBERS (${members.length})',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          ),
        ),
        const SizedBox(height: 10),

        // Member Tiles
        for (final m in members) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: m.isVeterinarian
                        ? AppColors.primaryGradient
                        : const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      m.initials,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            m.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          if (m.isVeterinarian) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.dogName != null ? 'Parent of ${m.dogName} (${m.dogBreed})' : m.roleDescription,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  m.joinedDate,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SliverTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabHeaderDelegate({required this.child});
  final Widget child;

  @override
  double get minExtent => 54;
  @override
  double get maxExtent => 54;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverTabHeaderDelegate oldDelegate) => true;
}
