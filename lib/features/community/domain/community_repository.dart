import 'package:canivue/features/community/domain/community_post.dart';

abstract class CommunityRepository {
  Future<List<CommunityPost>> fetchFeed();

  Future<List<DiseaseCommunity>> fetchCommunities();

  Future<DiseaseCommunity> fetchCommunityDetail(String communityId);

  Future<List<CommunityMember>> fetchCommunityMembers(String communityId);

  Future<CommunityPost> toggleLike(String postId);

  Future<CommunityPost> toggleSave(String postId);

  Future<DiseaseCommunity> toggleJoin(String communityId);

  Future<CommunityPost> createPost({
    required String content,
    required String communityTag,
    required String authorName,
    required String authorInitials,
    required bool isVeterinarian,
    String? imageUrl,
  });

  Future<PostComment> addComment({
    required String postId,
    required String content,
    required String authorName,
    required String authorInitials,
    required bool isVeterinarian,
  });

  Future<PostComment> toggleCommentLike({
    required String postId,
    required String commentId,
  });
}
