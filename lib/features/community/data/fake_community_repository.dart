import 'package:canivue/features/community/domain/community_post.dart';
import 'package:canivue/features/community/domain/community_repository.dart';

class FakeCommunityRepository implements CommunityRepository {
  final List<CommunityPost> _feed = [
    CommunityPost(
      id: 'post-1',
      authorName: 'Dr. Amara Osei',
      authorInitials: 'AO',
      isVeterinarian: true,
      communityTag: 'Skin Allergies',
      content: 'Seasonal allergies are picking up this month. Watch for excessive paw licking and redness behind the ears — early antihistamine treatment helps a lot.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      likeCount: 128,
      commentCount: 24,
      shareCount: 12,
    ),
    CommunityPost(
      id: 'post-2',
      authorName: 'Priya M.',
      authorInitials: 'PM',
      isVeterinarian: false,
      communityTag: 'Obesity',
      content: 'Started a weight management plan with my vet for my labrador. Down 1.5kg in a month! Swapping treats for baby carrots really helped.',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      likeCount: 64,
      commentCount: 11,
      shareCount: 3,
    ),
    CommunityPost(
      id: 'post-3',
      authorName: 'Dr. Robert Miller',
      authorInitials: 'RM',
      isVeterinarian: true,
      communityTag: 'Arthritis',
      content: 'For senior dogs with joint stiffness: gentle, consistent daily walks are often better than sporadic bursts of high-intensity activity.',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      likeCount: 210,
      commentCount: 38,
      shareCount: 27,
    ),
    CommunityPost(
      id: 'post-4',
      authorName: 'James K.',
      authorInitials: 'JK',
      isVeterinarian: false,
      communityTag: 'Digestive Problems',
      content: 'Anyone else\'s dog get an upset stomach switching foods? What worked for the transition period?',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      likeCount: 19,
      commentCount: 15,
      shareCount: 1,
    ),
  ];

  final List<DiseaseCommunity> _communities = [
    DiseaseCommunity(id: 'comm-1', name: 'Skin Allergies', description: 'Share experiences and vet-verified advice on allergies and dermatology.', memberCount: 8420, joined: true),
    DiseaseCommunity(id: 'comm-2', name: 'Arthritis', description: 'Support and tips for dogs with joint pain and mobility issues.', memberCount: 5310),
    DiseaseCommunity(id: 'comm-3', name: 'Obesity', description: 'Weight management, nutrition and exercise plans.', memberCount: 6900),
    DiseaseCommunity(id: 'comm-4', name: 'Diabetes', description: 'Managing canine diabetes — insulin, diet and monitoring.', memberCount: 2140),
    DiseaseCommunity(id: 'comm-5', name: 'Heart Conditions', description: 'Cardiac health, medication and lifestyle discussions.', memberCount: 1870),
    DiseaseCommunity(id: 'comm-6', name: 'Digestive Problems', description: 'GI issues, food sensitivities and diet transitions.', memberCount: 4630),
  ];

  @override
  Future<List<CommunityPost>> fetchFeed() async {
    await Future.delayed(const Duration(milliseconds: 550));
    return List.unmodifiable(_feed);
  }

  @override
  Future<List<DiseaseCommunity>> fetchCommunities() async {
    await Future.delayed(const Duration(milliseconds: 450));
    return List.unmodifiable(_communities);
  }

  @override
  Future<CommunityPost> toggleLike(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _feed.indexWhere((p) => p.id == postId);
    final post = _feed[index];
    final updated = post.copyWith(likedByMe: !post.likedByMe, likeCount: post.likedByMe ? post.likeCount - 1 : post.likeCount + 1);
    _feed[index] = updated;
    return updated;
  }

  @override
  Future<CommunityPost> toggleSave(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _feed.indexWhere((p) => p.id == postId);
    final updated = _feed[index].copyWith(savedByMe: !_feed[index].savedByMe);
    _feed[index] = updated;
    return updated;
  }

  @override
  Future<DiseaseCommunity> toggleJoin(String communityId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _communities.indexWhere((c) => c.id == communityId);
    final community = _communities[index];
    final joined = !community.joined;
    final updated = community.copyWith(joined: joined, memberCount: joined ? community.memberCount + 1 : community.memberCount - 1);
    _communities[index] = updated;
    return updated;
  }
}
