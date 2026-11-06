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
      commentCount: 2,
      shareCount: 12,
      comments: [
        PostComment(
          id: 'comm-101',
          authorName: 'Marcus T.',
          authorInitials: 'MT',
          content: 'Thank you doctor! My golden retriever started scratching his paws yesterday. Will call the clinic.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
          isVeterinarian: false,
          likeCount: 8,
          likedByMe: false,
        ),
        PostComment(
          id: 'comm-102',
          authorName: 'Dr. Robert Miller',
          authorInitials: 'RM',
          content: 'Wiping paws with a damp cloth after outdoor walks also removes pollen contact significantly.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          isVeterinarian: true,
          likeCount: 15,
          likedByMe: true,
        ),
      ],
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
      commentCount: 1,
      shareCount: 3,
      comments: [
        PostComment(
          id: 'comm-201',
          authorName: 'Sarah Jenkins',
          authorInitials: 'SJ',
          content: 'Amazing progress! Baby carrots and cucumber slices are lifesavers for hungry labs!',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          isVeterinarian: false,
          likeCount: 4,
        ),
      ],
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
      commentCount: 1,
      shareCount: 27,
      comments: [
        PostComment(
          id: 'comm-301',
          authorName: 'Elena Rostova',
          authorInitials: 'ER',
          content: 'This made a huge difference for our 11yo German Shepherd. Two short 15min strolls instead of one long hour walk.',
          createdAt: DateTime.now().subtract(const Duration(hours: 18)),
          isVeterinarian: false,
          likeCount: 12,
        ),
      ],
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
      commentCount: 2,
      shareCount: 1,
      comments: [
        PostComment(
          id: 'comm-401',
          authorName: 'Dr. Amara Osei',
          authorInitials: 'AO',
          content: 'Mix 25% new food with 75% old food for days 1-3, 50/50 for days 4-6, and 75/25 for days 7-9. Adding a spoonful of pure pumpkin puree helps settle the digestive tract.',
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 20)),
          isVeterinarian: true,
          likeCount: 19,
          likedByMe: true,
        ),
        PostComment(
          id: 'comm-402',
          authorName: 'James K.',
          authorInitials: 'JK',
          content: 'Thank you Dr. Osei! Will try the pumpkin puree today.',
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 16)),
          isVeterinarian: false,
          likeCount: 2,
        ),
      ],
    ),
  ];

  final List<DiseaseCommunity> _communities = [
    const DiseaseCommunity(
      id: 'comm-1',
      name: 'Skin Allergies',
      description: 'Share experiences and vet-verified advice on canine allergies, hot spots, atopic dermatitis, and dermatology.',
      memberCount: 8420,
      joined: true,
      leadVetName: 'Dr. Amara Osei, DVM',
      leadVetRole: 'Canine Dermatology Fellow',
      coverEmoji: '🐕',
      members: [
        CommunityMember(
          id: 'mem-1',
          name: 'Dr. Amara Osei',
          initials: 'AO',
          roleDescription: 'Group Lead & Verified Veterinarian',
          isVeterinarian: true,
          joinedDate: 'Leader since Jan 2025',
        ),
        CommunityMember(
          id: 'mem-2',
          name: 'Dr. Robert Miller',
          initials: 'RM',
          roleDescription: 'Clinical Advisor',
          isVeterinarian: true,
          joinedDate: 'Joined March 2025',
        ),
        CommunityMember(
          id: 'mem-3',
          name: 'Marcus Thorne',
          initials: 'MT',
          roleDescription: 'Pet Parent',
          isVeterinarian: false,
          dogName: 'Cooper',
          dogBreed: 'Golden Retriever',
          joinedDate: 'Member for 6 months',
        ),
        CommunityMember(
          id: 'mem-4',
          name: 'Elena Rostova',
          initials: 'ER',
          roleDescription: 'Pet Parent',
          isVeterinarian: false,
          dogName: 'Zeus',
          dogBreed: 'German Shepherd',
          joinedDate: 'Member for 1 year',
        ),
        CommunityMember(
          id: 'mem-5',
          name: 'Priya Sharma',
          initials: 'PS',
          roleDescription: 'Pet Parent',
          isVeterinarian: false,
          dogName: 'Milo',
          dogBreed: 'Beagle',
          joinedDate: 'Joined recently',
        ),
      ],
    ),
    const DiseaseCommunity(
      id: 'comm-2',
      name: 'Arthritis',
      description: 'Support, physical therapy tips, and mobility exercises for senior dogs with osteoarthritis and hip dysplasia.',
      memberCount: 5310,
      leadVetName: 'Dr. Robert Miller, DVM',
      leadVetRole: 'Canine Orthopedic Specialist',
      coverEmoji: '🦴',
      members: [
        CommunityMember(
          id: 'mem-21',
          name: 'Dr. Robert Miller',
          initials: 'RM',
          roleDescription: 'Orthopedic Lead & Verified Vet',
          isVeterinarian: true,
          joinedDate: 'Lead since Feb 2025',
        ),
        CommunityMember(
          id: 'mem-22',
          name: 'David Vance',
          initials: 'DV',
          roleDescription: 'Pet Parent',
          dogName: 'Rocky',
          dogBreed: 'Rottweiler',
          joinedDate: 'Member for 8 months',
        ),
        CommunityMember(
          id: 'mem-23',
          name: 'Claire Dupont',
          initials: 'CD',
          roleDescription: 'Pet Parent',
          dogName: 'Bella',
          dogBreed: 'Labrador',
          joinedDate: 'Joined 2 weeks ago',
        ),
      ],
    ),
    const DiseaseCommunity(
      id: 'comm-3',
      name: 'Obesity',
      description: 'Body Condition Score (BCS) tracking, portion control, vet-approved low-calorie treats, and cardio routines.',
      memberCount: 6900,
      leadVetName: 'Dr. Sarah Jenkins, DVM',
      leadVetRole: 'Veterinary Nutritionist',
      coverEmoji: '🥗',
      members: [
        CommunityMember(
          id: 'mem-31',
          name: 'Dr. Sarah Jenkins',
          initials: 'SJ',
          roleDescription: 'Nutrition Lead & Verified Vet',
          isVeterinarian: true,
          joinedDate: 'Lead since Nov 2024',
        ),
        CommunityMember(
          id: 'mem-32',
          name: 'Priya M.',
          initials: 'PM',
          roleDescription: 'Pet Parent',
          dogName: 'Bruno',
          dogBreed: 'Chocolate Labrador',
          joinedDate: 'Member for 3 months',
        ),
      ],
    ),
    const DiseaseCommunity(
      id: 'comm-4',
      name: 'Diabetes',
      description: 'Managing canine diabetes — blood glucose monitoring, insulin schedules, and carbohydrate-controlled diets.',
      memberCount: 2140,
      coverEmoji: '🩸',
      members: [
        CommunityMember(
          id: 'mem-41',
          name: 'Dr. Amara Osei',
          initials: 'AO',
          roleDescription: 'Endocrine Advisor',
          isVeterinarian: true,
        ),
      ],
    ),
    const DiseaseCommunity(
      id: 'comm-5',
      name: 'Heart Conditions',
      description: 'Cardiac telemetry, resting respiratory rates, low-sodium nutrition, and heart murmur monitoring.',
      memberCount: 1870,
      coverEmoji: '❤️',
      members: [
        CommunityMember(
          id: 'mem-51',
          name: 'Dr. Robert Miller',
          initials: 'RM',
          roleDescription: 'Cardiology Advisor',
          isVeterinarian: true,
        ),
      ],
    ),
    const DiseaseCommunity(
      id: 'comm-6',
      name: 'Digestive Problems',
      description: 'Gastrointestinal sensitivity, pancreatitis recovery, food elimination trials, and gut microbiome health.',
      memberCount: 4630,
      coverEmoji: '🥣',
      members: [
        CommunityMember(
          id: 'mem-61',
          name: 'Dr. Sarah Jenkins',
          initials: 'SJ',
          roleDescription: 'GI Lead',
          isVeterinarian: true,
        ),
        CommunityMember(
          id: 'mem-62',
          name: 'James K.',
          initials: 'JK',
          roleDescription: 'Pet Parent',
          dogName: 'Archie',
          dogBreed: 'French Bulldog',
        ),
      ],
    ),
  ];

  @override
  Future<List<CommunityPost>> fetchFeed() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_feed);
  }

  @override
  Future<List<DiseaseCommunity>> fetchCommunities() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_communities);
  }

  @override
  Future<DiseaseCommunity> fetchCommunityDetail(String communityId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final community = _communities.firstWhere(
      (c) => c.id == communityId || c.name.toLowerCase() == communityId.toLowerCase(),
      orElse: () => _communities.first,
    );
    return community;
  }

  @override
  Future<List<CommunityMember>> fetchCommunityMembers(String communityId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final comm = await fetchCommunityDetail(communityId);
    return comm.members;
  }

  @override
  Future<CommunityPost> toggleLike(String postId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _feed.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');
    final post = _feed[index];
    final updated = post.copyWith(
      likedByMe: !post.likedByMe,
      likeCount: post.likedByMe ? post.likeCount - 1 : post.likeCount + 1,
    );
    _feed[index] = updated;
    return updated;
  }

  @override
  Future<CommunityPost> toggleSave(String postId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _feed.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');
    final updated = _feed[index].copyWith(savedByMe: !_feed[index].savedByMe);
    _feed[index] = updated;
    return updated;
  }

  @override
  Future<DiseaseCommunity> toggleJoin(String communityId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _communities.indexWhere((c) => c.id == communityId || c.name.toLowerCase() == communityId.toLowerCase());
    if (index == -1) throw Exception('Community not found');
    final community = _communities[index];
    final updated = community.copyWith(
      joined: !community.joined,
      memberCount: community.joined ? community.memberCount - 1 : community.memberCount + 1,
    );
    _communities[index] = updated;
    return updated;
  }

  @override
  Future<CommunityPost> createPost({
    required String content,
    required String communityTag,
    required String authorName,
    required String authorInitials,
    required bool isVeterinarian,
    String? imageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 180));
    final newPost = CommunityPost(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      authorName: authorName,
      authorInitials: authorInitials,
      isVeterinarian: isVeterinarian,
      communityTag: communityTag,
      content: content,
      createdAt: DateTime.now(),
      likeCount: 0,
      commentCount: 0,
      shareCount: 0,
      likedByMe: false,
      savedByMe: false,
      comments: const [],
      imageUrl: imageUrl,
    );
    _feed.insert(0, newPost);
    return newPost;
  }

  @override
  Future<PostComment> addComment({
    required String postId,
    required String content,
    required String authorName,
    required String authorInitials,
    required bool isVeterinarian,
  }) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final index = _feed.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');

    final newComment = PostComment(
      id: 'comment-${DateTime.now().millisecondsSinceEpoch}',
      authorName: authorName,
      authorInitials: authorInitials,
      content: content,
      createdAt: DateTime.now(),
      isVeterinarian: isVeterinarian,
      likeCount: 0,
      likedByMe: false,
    );

    final post = _feed[index];
    final updatedComments = [...post.comments, newComment];
    final updatedPost = post.copyWith(
      comments: updatedComments,
      commentCount: updatedComments.length,
    );
    _feed[index] = updatedPost;
    return newComment;
  }

  @override
  Future<PostComment> toggleCommentLike({
    required String postId,
    required String commentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 80));
    final postIndex = _feed.indexWhere((p) => p.id == postId);
    if (postIndex == -1) throw Exception('Post not found');

    final post = _feed[postIndex];
    final commentIndex = post.comments.indexWhere((c) => c.id == commentId);
    if (commentIndex == -1) throw Exception('Comment not found');

    final comment = post.comments[commentIndex];
    final updatedComment = comment.copyWith(
      likedByMe: !comment.likedByMe,
      likeCount: comment.likedByMe ? comment.likeCount - 1 : comment.likeCount + 1,
    );

    final newComments = List<PostComment>.from(post.comments);
    newComments[commentIndex] = updatedComment;
    _feed[postIndex] = post.copyWith(comments: newComments);

    return updatedComment;
  }
}
