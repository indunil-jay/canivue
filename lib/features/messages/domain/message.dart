enum MessageSender { owner, vet }

enum MessageStatus { sent, delivered, read }

enum MessageKind { text, consultationSummary }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.kind = MessageKind.text,
  });

  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;
  final MessageKind kind;
}
