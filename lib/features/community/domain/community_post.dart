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

  CommunityPost copyWith({bool? likedByMe, bool? savedByMe, int? likeCount}) {
    return CommunityPost(
      id: id,
      authorName: authorName,
      authorInitials: authorInitials,
      isVeterinarian: isVeterinarian,
      communityTag: communityTag,
      content: content,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount,
      shareCount: shareCount,
      likedByMe: likedByMe ?? this.likedByMe,
      savedByMe: savedByMe ?? this.savedByMe,
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
  });

  final String id;
  final String name;
  final String description;
  final int memberCount;
  final bool joined;

  DiseaseCommunity copyWith({bool? joined, int? memberCount}) {
    return DiseaseCommunity(id: id, name: name, description: description, memberCount: memberCount ?? this.memberCount, joined: joined ?? this.joined);
  }
}
