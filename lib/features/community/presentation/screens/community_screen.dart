import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/luxury_segmented_bar.dart';
import 'package:canivue/features/community/presentation/controllers/community_controller.dart';
import 'package:canivue/features/community/presentation/widgets/post_card.dart';

/// Owner shell "Community" tab — Threads/Facebook-style knowledge feed plus
/// disease-specific communities (brief §23-24).
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: LuxurySegmentedBar(segments: const ['Feed', 'Communities'], selectedIndex: _tab, onChanged: (i) => setState(() => _tab = i)),
          ),
          Expanded(child: _tab == 0 ? const _FeedTab() : const _CommunitiesTab()),
        ],
      ),
    );
  }
}

class _FeedTab extends ConsumerWidget {
  const _FeedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(communityFeedControllerProvider);

    return feedAsync.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(20),
        children: List.generate(3, (_) => const Padding(padding: EdgeInsets.only(bottom: 16), child: SkeletonBox(height: 140))),
      ),
      error: (_, _) => ErrorState(message: "We couldn't load the feed.", onRetry: () => ref.invalidate(communityFeedControllerProvider)),
      data: (posts) {
        if (posts.isEmpty) {
          return const EmptyState(icon: Icons.groups_outlined, title: 'No posts yet', message: 'Join a disease community or follow a topic to see posts here.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: posts.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) => PostCard(
            post: posts[index],
            onLike: () => ref.read(communityFeedControllerProvider.notifier).toggleLike(posts[index].id),
            onSave: () => ref.read(communityFeedControllerProvider.notifier).toggleSave(posts[index].id),
          ),
        );
      },
    );
  }
}

class _CommunitiesTab extends ConsumerWidget {
  const _CommunitiesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communitiesAsync = ref.watch(communitiesControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return communitiesAsync.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(20),
        children: List.generate(4, (_) => const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBox(height: 84))),
      ),
      error: (_, _) => ErrorState(message: "We couldn't load communities.", onRetry: () => ref.invalidate(communitiesControllerProvider)),
      data: (communities) {
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: communities.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final community = communities[index];
            return Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: AppRadius.xlRadius,
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(community.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(community.description, style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                        const SizedBox(height: 6),
                        Text('${community.memberCount} members', style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () => ref.read(communitiesControllerProvider.notifier).toggleJoin(community.id),
                    style: community.joined ? OutlinedButton.styleFrom(foregroundColor: isDark ? AppColors.darkMutedText : AppColors.lightMutedText) : null,
                    child: Text(community.joined ? 'Joined' : 'Join'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
