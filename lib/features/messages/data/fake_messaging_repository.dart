import 'dart:async';

import 'package:canivue/features/messages/domain/conversation.dart';
import 'package:canivue/features/messages/domain/message.dart';
import 'package:canivue/features/messages/domain/messaging_repository.dart';

/// In-memory conversations with a simulated vet auto-reply, so the chat
/// screen has a real incoming-message moment instead of only ever showing
/// what the owner typed.
class FakeMessagingRepository implements MessagingRepository {
  final Map<String, List<ChatMessage>> _messages = {
    'conv-1': [
      ChatMessage(
        id: 'm1',
        sender: MessageSender.vet,
        text: 'Hi Alex! Thanks for booking a follow-up for Buddy.',
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm2',
        sender: MessageSender.vet,
        text: 'Consultation summary from your last visit',
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        status: MessageStatus.read,
        kind: MessageKind.consultationSummary,
      ),
      ChatMessage(
        id: 'm3',
        sender: MessageSender.owner,
        text: 'Thank you! Buddy seems to be doing much better.',
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
        status: MessageStatus.read,
      ),
    ],
  };

  final Map<String, StreamController<ChatMessage>> _incoming = {};

  @override
  Future<List<Conversation>> fetchConversations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Conversation(
        id: 'conv-1',
        vetId: 'vet-1',
        vetName: 'Dr. Sarah Jenkins',
        vetInitials: 'SJ',
        lastMessagePreview: _messages['conv-1']!.last.text,
        lastMessageAt: _messages['conv-1']!.last.timestamp,
        unreadCount: 0,
        online: true,
      ),
    ];
  }

  @override
  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 450));
    return List.unmodifiable(_messages[conversationId] ?? const []);
  }

  @override
  Future<ChatMessage> sendMessage(String conversationId, String text) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final message = ChatMessage(
      id: 'm-${DateTime.now().microsecondsSinceEpoch}',
      sender: MessageSender.owner,
      text: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );
    _messages.putIfAbsent(conversationId, () => []).add(message);

    // Simulate the vet reading, then replying, without blocking the sender.
    Future.delayed(const Duration(seconds: 2), () {
      final reply = ChatMessage(
        id: 'm-${DateTime.now().microsecondsSinceEpoch}-r',
        sender: MessageSender.vet,
        text: "Got it — I'll take a look and get back to you shortly.",
        timestamp: DateTime.now(),
        status: MessageStatus.delivered,
      );
      _messages.putIfAbsent(conversationId, () => []).add(reply);
      _incoming[conversationId]?.add(reply);
    });

    return message;
  }

  @override
  Stream<ChatMessage> watchIncoming(String conversationId) {
    return _incoming.putIfAbsent(conversationId, () => StreamController<ChatMessage>.broadcast()).stream;
  }
}
