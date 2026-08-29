import 'package:canivue/features/community/domain/community_post.dart';

abstract class CommunityRepository {
  Future<List<CommunityPost>> fetchFeed();

  Future<List<DiseaseCommunity>> fetchCommunities();

  Future<CommunityPost> toggleLike(String postId);

  Future<CommunityPost> toggleSave(String postId);

  Future<DiseaseCommunity> toggleJoin(String communityId);
}
