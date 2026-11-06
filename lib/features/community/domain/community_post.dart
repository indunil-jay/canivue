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
    String? joinedDate,
  }) : _joinedDate = joinedDate;

  final String id;
  final String name;
  final String initials;
  final String roleDescription;
  final bool isVeterinarian;
  final String? dogName;
  final String? dogBreed;
  final String? _joinedDate;

  String get joinedDate => _joinedDate ?? 'Active member';
}

/// Comment on a community post with like & reaction support.
class PostComment {
  const PostComment({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    required this.content,
    DateTime? createdAt,
    this.isVeterinarian = false,
    this.likeCount = 0,
    this.likedByMe = false,
  }) : _createdAt = createdAt;

  final String id;
  final String authorName;
  final String authorInitials;
  final String content;
  final DateTime? _createdAt;
  final bool isVeterinarian;
  final int likeCount;
  final bool likedByMe;

  DateTime get createdAt => _createdAt ?? DateTime.now();

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
    List<PostComment>? comments,
    this.imageUrl,
  }) : _comments = comments;

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
  final List<PostComment>? _comments;
  final String? imageUrl;

  List<PostComment> get comments => _comments ?? const [];

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
    String? leadVetName,
    String? leadVetRole,
    String? coverEmoji,
    List<String>? rules,
    List<CommunityMember>? members,
  })  : _leadVetName = leadVetName,
        _leadVetRole = leadVetRole,
        _coverEmoji = coverEmoji,
        _rules = rules,
        _members = members;

  final String id;
  final String name;
  final String description;
  final int memberCount;
  final bool joined;
  final String? _leadVetName;
  final String? _leadVetRole;
  final String? _coverEmoji;
  final List<String>? _rules;
  final List<CommunityMember>? _members;

  String get leadVetName => _leadVetName ?? 'Dr. Amara Osei, DVM';
  String get leadVetRole => _leadVetRole ?? 'Clinical Dermatology Specialist';
  String get coverEmoji => _coverEmoji ?? '🐾';
  List<String> get rules => _rules ?? const [
    'Share honest pet care experiences and recovery journeys.',
    'Veterinary advice requires a verified license badge.',
    'Always consult your veterinarian before administering prescription medication.',
    'Be respectful, supportive, and kind to fellow pet parents.',
  ];
  List<CommunityMember> get members => _members ?? const [];

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
