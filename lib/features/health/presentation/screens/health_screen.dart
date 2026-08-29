import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';

/// Owner shell "Health" tab. Will grow into the full health-monitoring
/// experience (vitals, charts, AI predictions, timeline — brief §9-13) in a
/// later milestone; for now it's a real, intentional empty state rather than
/// a "coming soon" stub.
class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health')),
      body: const EmptyState(
        icon: Icons.monitor_heart_outlined,
        title: 'No health data yet',
        message: 'Connect a smart collar or run an AI health check to start building your dog\'s health timeline.',
      ),
    );
  }
}
