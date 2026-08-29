import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/community/data/fake_community_repository.dart';
import 'package:canivue/features/community/domain/community_post.dart';
import 'package:canivue/features/community/domain/community_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) => FakeCommunityRepository());

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
}

final communityFeedControllerProvider = AsyncNotifierProvider<CommunityFeedController, List<CommunityPost>>(CommunityFeedController.new);

class CommunitiesController extends AsyncNotifier<List<DiseaseCommunity>> {
  @override
  Future<List<DiseaseCommunity>> build() {
    return ref.watch(communityRepositoryProvider).fetchCommunities();
  }

  Future<void> toggleJoin(String communityId) async {
    final updated = await ref.read(communityRepositoryProvider).toggleJoin(communityId);
    state = AsyncData([for (final c in state.value ?? const []) if (c.id == communityId) updated else c]);
  }
}

final communitiesControllerProvider = AsyncNotifierProvider<CommunitiesController, List<DiseaseCommunity>>(CommunitiesController.new);
