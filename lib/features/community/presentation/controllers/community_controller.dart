import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/community/data/fake_community_repository.dart';
import 'package:canivue/features/community/domain/community_post.dart';
import 'package:canivue/features/community/domain/community_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) => FakeCommunityRepository());

/// Filter topic selected in the feed (null or 'All' means no filter).
final communitySelectedFilterProvider = StateProvider<String>((ref) => 'All');

class CommunityFeedController extends AsyncNotifier<List<CommunityPost>> {
  @override
  Future<List<CommunityPost>> build() {
    return ref.watch(communityRepositoryProvider).fetchFeed();
  }

  Future<void> toggleLike(String postId) async {
    final updated = await ref.read(communityRepositoryProvider).toggleLike(postId);
    state = AsyncData([for (final p in state.value ?? const []) if (p.id == postId) updated else p]);
  }

  Future<void> toggleSave(String postId) async {
    final updated = await ref.read(communityRepositoryProvider).toggleSave(postId);
    state = AsyncData([for (final p in state.value ?? const []) if (p.id == postId) updated else p]);
  }

  Future<CommunityPost> createPost({
    required String content,
    required String communityTag,
    required String authorName,
    required String authorInitials,
    required bool isVeterinarian,
    String? imageUrl,
  }) async {
    final newPost = await ref.read(communityRepositoryProvider).createPost(
          content: content,
          communityTag: communityTag,
          authorName: authorName,
          authorInitials: authorInitials,
          isVeterinarian: isVeterinarian,
          imageUrl: imageUrl,
        );
    state = AsyncData([newPost, ...(state.value ?? const [])]);
    return newPost;
  }

  Future<void> addComment({
    required String postId,
    required String content,
    required String authorName,
    required String authorInitials,
    required bool isVeterinarian,
  }) async {
    final comment = await ref.read(communityRepositoryProvider).addComment(
          postId: postId,
          content: content,
          authorName: authorName,
          authorInitials: authorInitials,
          isVeterinarian: isVeterinarian,
        );

    final currentPosts = state.value ?? const [];
    state = AsyncData([
      for (final p in currentPosts)
        if (p.id == postId)
          p.copyWith(
            comments: [...p.comments, comment],
            commentCount: p.commentCount + 1,
          )
        else
          p
    ]);
  }

  Future<void> toggleCommentLike(String postId, String commentId) async {
    final updatedComment = await ref.read(communityRepositoryProvider).toggleCommentLike(
          postId: postId,
          commentId: commentId,
        );

    final currentPosts = state.value ?? const [];
    state = AsyncData([
      for (final p in currentPosts)
        if (p.id == postId)
          p.copyWith(
            comments: [
              for (final c in p.comments)
                if (c.id == commentId) updatedComment else c
            ],
          )
        else
          p
    ]);
  }
}

final communityFeedControllerProvider =
    AsyncNotifierProvider<CommunityFeedController, List<CommunityPost>>(CommunityFeedController.new);

class CommunitiesController extends AsyncNotifier<List<DiseaseCommunity>> {
  @override
  Future<List<DiseaseCommunity>> build() {
    return ref.watch(communityRepositoryProvider).fetchCommunities();
  }

  Future<void> toggleJoin(String communityId) async {
    final updated = await ref.read(communityRepositoryProvider).toggleJoin(communityId);
    state = AsyncData([for (final c in state.value ?? const []) if (c.id == communityId || c.name == communityId) updated else c]);
  }
}

final communitiesControllerProvider =
    AsyncNotifierProvider<CommunitiesController, List<DiseaseCommunity>>(CommunitiesController.new);

final communityDetailProvider = FutureProvider.family<DiseaseCommunity, String>((ref, communityId) async {
  return ref.watch(communityRepositoryProvider).fetchCommunityDetail(communityId);
});
