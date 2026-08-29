/// WhatsApp-style veterinary messaging (brief §19, §26).
class Conversation {
  const Conversation({
    required this.id,
    required this.vetId,
    required this.vetName,
    required this.vetInitials,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.online,
  });

  final String id;
  final String vetId;
  final String vetName;
  final String vetInitials;
  final String lastMessagePreview;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool online;
}
