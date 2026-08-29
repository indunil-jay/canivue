import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';

/// Owner shell "Messages" tab. Will grow into WhatsApp-style veterinary
/// conversations (brief §19, §26) in a later milestone.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const EmptyState(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'No messages yet',
        message: 'Conversations with your veterinarian will show up here once you book a consultation.',
      ),
    );
  }
}
