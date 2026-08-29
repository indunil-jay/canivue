import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/messages/data/fake_messaging_repository.dart';
import 'package:canivue/features/messages/domain/conversation.dart';
import 'package:canivue/features/messages/domain/message.dart';
import 'package:canivue/features/messages/domain/messaging_repository.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) => FakeMessagingRepository());

final conversationsProvider = FutureProvider<List<Conversation>>((ref) {
  return ref.watch(messagingRepositoryProvider).fetchConversations();
});

class ChatController extends FamilyAsyncNotifier<List<ChatMessage>, String> {
  late final String _conversationId;
  StreamSubscription<ChatMessage>? _sub;

  @override
  Future<List<ChatMessage>> build(String conversationId) async {
    _conversationId = conversationId;
    final repo = ref.watch(messagingRepositoryProvider);
    final initial = await repo.fetchMessages(conversationId);

    _sub?.cancel();
    _sub = repo.watchIncoming(conversationId).listen((message) {
      state = AsyncData([...(state.value ?? const []), message]);
    });
    ref.onDispose(() => _sub?.cancel());

    return initial;
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    final repo = ref.read(messagingRepositoryProvider);
    final sent = await repo.sendMessage(_conversationId, text.trim());
    state = AsyncData([...(state.value ?? const []), sent]);
  }
}

final chatControllerProvider = AsyncNotifierProvider.family<ChatController, List<ChatMessage>, String>(ChatController.new);

/// Whether the vet is "typing" — a purely cosmetic timer tied to sending a
/// message, mirroring the fake repository's ~2s auto-reply delay.
final vetTypingProvider = StateProvider.family<bool, String>((ref, conversationId) => false);
