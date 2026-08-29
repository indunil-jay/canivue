import 'package:canivue/features/messages/domain/conversation.dart';
import 'package:canivue/features/messages/domain/message.dart';

abstract class MessagingRepository {
  Future<List<Conversation>> fetchConversations();

  Future<List<ChatMessage>> fetchMessages(String conversationId);

  Future<ChatMessage> sendMessage(String conversationId, String text);

  /// Emits an auto-reply a short while after a message is sent, so the chat
  /// screen has a real typing-indicator/incoming-message moment to render.
  Stream<ChatMessage> watchIncoming(String conversationId);
}
