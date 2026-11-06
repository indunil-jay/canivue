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
        text: 'Hi Alex! Dr. Sarah Jenkins here. How has Buddy been doing since starting the allergen-free diet?',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm2',
        sender: MessageSender.owner,
        text: 'Hi Dr. Sarah! Buddy stopped itching his ears as much, but we had a small flare up yesterday after a park run.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm3',
        sender: MessageSender.owner,
        text: 'Live collar telemetry sync',
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        status: MessageStatus.read,
        kind: MessageKind.liveTelemetryShare,
        dogName: 'Buddy',
        heartRate: 78,
        vitalityScore: 92,
        temperature: 38.3,
      ),
      ChatMessage(
        id: 'm4',
        sender: MessageSender.vet,
        text: 'Those collar vitals look excellent! Resting heart rate of 78 bpm is right in the ideal zone. Here is the formal clinical plan:',
        timestamp: DateTime.now().subtract(const Duration(hours: 16)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm5',
        sender: MessageSender.vet,
        text: 'Clinical Consultation Summary',
        timestamp: DateTime.now().subtract(const Duration(hours: 16)),
        status: MessageStatus.read,
        kind: MessageKind.consultationSummary,
        summaryDiagnosis: 'Mild Grass Pollen Contact Dermatitis',
        summaryTreatment: 'Topical soothing mousse 1x daily + paw wipe after park runs. Continue hypoallergenic diet.',
        summaryFollowUp: 'Scheduled follow-up in 10 days via video check-up.',
      ),
      ChatMessage(
        id: 'm6',
        sender: MessageSender.owner,
        text: 'Thank you so much Dr. Sarah! Will start the paw wiping immediately.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: MessageStatus.read,
      ),
    ],
  };

  final Map<String, StreamController<ChatMessage>> _incoming = {};

  @override
  Future<List<Conversation>> fetchConversations() async {
    await Future.delayed(const Duration(milliseconds: 250));
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
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_messages[conversationId] ?? const []);
  }

  @override
  Future<ChatMessage> sendMessage(String conversationId, String text) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final message = ChatMessage(
      id: 'm-${DateTime.now().microsecondsSinceEpoch}',
      sender: MessageSender.owner,
      text: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );
    _messages.putIfAbsent(conversationId, () => []).add(message);

    // Intelligent simulated vet reply based on keywords
    Future.delayed(const Duration(milliseconds: 1800), () {
      final replyText = _generateSmartReply(text);
      final reply = ChatMessage(
        id: 'm-${DateTime.now().microsecondsSinceEpoch}-r',
        sender: MessageSender.vet,
        text: replyText,
        timestamp: DateTime.now(),
        status: MessageStatus.delivered,
      );
      _messages.putIfAbsent(conversationId, () => []).add(reply);
      _incoming[conversationId]?.add(reply);
    });

    return message;
  }

  @override
  Future<ChatMessage> sendTelemetry(
    String conversationId, {
    required String dogName,
    required int heartRate,
    required int vitalityScore,
    required double temperature,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final message = ChatMessage(
      id: 'm-telemetry-${DateTime.now().microsecondsSinceEpoch}',
      sender: MessageSender.owner,
      text: 'Shared live biometric telemetry for $dogName',
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      kind: MessageKind.liveTelemetryShare,
      dogName: dogName,
      heartRate: heartRate,
      vitalityScore: vitalityScore,
      temperature: temperature,
    );
    _messages.putIfAbsent(conversationId, () => []).add(message);

    // Doctor auto responds acknowledging the vitals
    Future.delayed(const Duration(milliseconds: 2000), () {
      final reply = ChatMessage(
        id: 'm-${DateTime.now().microsecondsSinceEpoch}-r',
        sender: MessageSender.vet,
        text: 'Received live telemetry for $dogName! Heart rate ($heartRate bpm) and temperature ($temperature°C) look stable and within safe clinical thresholds.',
        timestamp: DateTime.now(),
        status: MessageStatus.delivered,
      );
      _messages.putIfAbsent(conversationId, () => []).add(reply);
      _incoming[conversationId]?.add(reply);
    });

    return message;
  }

  @override
  Future<ChatMessage> sendPhoto(
    String conversationId, {
    required String label,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final message = ChatMessage(
      id: 'm-photo-${DateTime.now().microsecondsSinceEpoch}',
      sender: MessageSender.owner,
      text: 'Photo attachment: $label',
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      kind: MessageKind.photoAttachment,
      photoLabel: label,
    );
    _messages.putIfAbsent(conversationId, () => []).add(message);

    Future.delayed(const Duration(milliseconds: 2200), () {
      final reply = ChatMessage(
        id: 'm-${DateTime.now().microsecondsSinceEpoch}-r',
        sender: MessageSender.vet,
        text: 'Examining the image carefully. There is mild localized redness, but no signs of secondary bacterial infection. Keep the area clean and dry.',
        timestamp: DateTime.now(),
        status: MessageStatus.delivered,
      );
      _messages.putIfAbsent(conversationId, () => []).add(reply);
      _incoming[conversationId]?.add(reply);
    });

    return message;
  }

  String _generateSmartReply(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('pain') || lower.contains('limp') || lower.contains('joint')) {
      return 'Joint stiffness can fluctuate with activity and weather. Ensure resting surfaces are warm and padded. I am reviewing his recent gait analysis.';
    } else if (lower.contains('food') || lower.contains('eat') || lower.contains('diet') || lower.contains('vomit')) {
      return 'Keep him hydrated with fresh water. If the appetite doesn\'t return by tonight, we can prescribe an anti-nausea gastrointestinal paste.';
    } else if (lower.contains('appointment') || lower.contains('visit') || lower.contains('call') || lower.contains('video')) {
      return 'I have availability tomorrow morning at 10:30 AM for a live video check-up. Feel free to book directly or let me know if that time works.';
    }
    return 'Thank you for the update! I\'ve logged this in his patient file. Keep monitoring his hydration and activity levels closely today.';
  }

  @override
  Stream<ChatMessage> watchIncoming(String conversationId) {
    return _incoming.putIfAbsent(conversationId, () => StreamController<ChatMessage>.broadcast()).stream;
  }
}
