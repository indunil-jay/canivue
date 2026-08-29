import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/vet_portal/presentation/controllers/vet_portal_controller.dart';

/// Availability management (brief §17) — which days this vet accepts
/// consultations.
class VetAvailabilityScreen extends ConsumerWidget {
  const VetAvailabilityScreen({super.key});

  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availabilityAsync = ref.watch(vetAvailabilityControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Availability')),
      body: availabilityAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: List.generate(7, (_) => const Padding(padding: EdgeInsets.only(bottom: 10), child: SkeletonBox(height: 56))),
        ),
        error: (_, _) => ErrorState(message: "We couldn't load availability.", onRetry: () => ref.invalidate(vetAvailabilityControllerProvider)),
        data: (availability) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Toggle the days you\'re available for video and in-person consultations.',
              style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final day in _days)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: SwitchListTile(
                  value: availability[day] ?? false,
                  onChanged: (v) => ref.read(vetAvailabilityControllerProvider.notifier).setDay(day, v),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
                  tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                  title: Text(day, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: Text((availability[day] ?? false) ? 'Accepting consultations' : 'Unavailable'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
