/// Member of a canine disease group / community.
class CommunityMember {
  const CommunityMember({
    required this.id,
    required this.name,
    required this.initials,
    required this.roleDescription,
    this.isVeterinarian = false,
    this.dogName,
    this.dogBreed,
    this.joinedDate = 'Active member',
  });

  final String id;
  final String name;
  final String initials;
  final String roleDescription;
  final bool isVeterinarian;
  final String? dogName;
  final String? dogBreed;
  final String joinedDate;
}

/// Comment on a community post with like & reaction support.
class PostComment {
  const PostComment({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    required this.content,
    required this.createdAt,
    this.isVeterinarian = false,
    this.likeCount = 0,
    this.likedByMe = false,
  });

  final String id;
  final String authorName;
  final String authorInitials;
  final String content;
  final DateTime createdAt;
  final bool isVeterinarian;
  final int likeCount;
  final bool likedByMe;

  PostComment copyWith({int? likeCount, bool? likedByMe}) {
    return PostComment(
      id: id,
      authorName: authorName,
      authorInitials: authorInitials,
      content: content,
      createdAt: createdAt,
      isVeterinarian: isVeterinarian,
      likeCount: likeCount ?? this.likeCount,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }
}

/// Social/knowledge feed (brief §23-24) — Threads/Facebook-style posts,
/// clearly distinguishing verified veterinary advice from general
/// community discussion.
class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    required this.isVeterinarian,
    required this.communityTag,
    required this.content,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    this.likedByMe = false,
    this.savedByMe = false,
    this.comments = const [],
    this.imageUrl,
  });

  final String id;
  final String authorName;
  final String authorInitials;
  final bool isVeterinarian;

  /// e.g. "Skin Allergies" — which community this was posted in.
  final String communityTag;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool likedByMe;
  final bool savedByMe;
  final List<PostComment> comments;
  final String? imageUrl;

  CommunityPost copyWith({
    bool? likedByMe,
    bool? savedByMe,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    List<PostComment>? comments,
  }) {
    return CommunityPost(
      id: id,
      authorName: authorName,
      authorInitials: authorInitials,
      isVeterinarian: isVeterinarian,
      communityTag: communityTag,
      content: content,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      likedByMe: likedByMe ?? this.likedByMe,
      savedByMe: savedByMe ?? this.savedByMe,
      comments: comments ?? this.comments,
      imageUrl: imageUrl,
    );
  }
}

class DiseaseCommunity {
  const DiseaseCommunity({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
    this.joined = false,
    this.leadVetName = 'Dr. Amara Osei, DVM',
    this.leadVetRole = 'Clinical Dermatology Specialist',
    this.coverEmoji = '🐾',
    this.rules = const [
      'Share honest pet care experiences and recovery journeys.',
      'Veterinary advice requires a verified license badge.',
      'Always consult your veterinarian before administering prescription medication.',
      'Be respectful, supportive, and kind to fellow pet parents.',
    ],
    this.members = const [],
  });

  final String id;
  final String name;
  final String description;
  final int memberCount;
  final bool joined;
  final String leadVetName;
  final String leadVetRole;
  final String coverEmoji;
  final List<String> rules;
  final List<CommunityMember> members;

  DiseaseCommunity copyWith({
    bool? joined,
    int? memberCount,
    List<CommunityMember>? members,
    String? leadVetName,
    String? leadVetRole,
    String? coverEmoji,
    List<String>? rules,
  }) {
    return DiseaseCommunity(
      id: id,
      name: name,
      description: description,
      memberCount: memberCount ?? this.memberCount,
      joined: joined ?? this.joined,
      leadVetName: leadVetName ?? this.leadVetName,
      leadVetRole: leadVetRole ?? this.leadVetRole,
      coverEmoji: coverEmoji ?? this.coverEmoji,
      rules: rules ?? this.rules,
      members: members ?? this.members,
    );
  }
}
