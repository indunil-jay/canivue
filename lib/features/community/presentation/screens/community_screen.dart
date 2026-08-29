import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';

/// Owner shell "Community" tab. Will grow into the Threads/Facebook-style
/// knowledge feed and disease communities (brief §23-24) in a later
/// milestone.
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: const EmptyState(
        icon: Icons.groups_outlined,
        title: 'No community posts yet',
        message: 'Join a disease community or follow a topic to see posts, questions and vet-verified advice here.',
      ),
    );
  }
}
