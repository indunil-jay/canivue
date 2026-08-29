import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/messages/presentation/screens/messages_screen.dart';
import 'package:canivue/features/vets/presentation/screens/vet_discovery_screen.dart';

/// Critical-event flow (brief §32) — calm but urgent, always explains what
/// was detected and why it may matter without making a definitive medical
/// claim, and always gives an actionable next step.
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({
    super.key,
    required this.dogId,
    required this.dogName,
    this.whatHappened = 'Elevated heart rate detected',
    this.whyConcerning,
  });

  final String dogId;
  final String dogName;
  final String whatHappened;
  final String? whyConcerning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final urgentColor = isDark ? AppColors.errorOnDark : AppColors.error;
    final why = whyConcerning ??
        "$dogName's heart rate has been significantly above baseline for the past 30 minutes, which can indicate pain, stress, heat exposure, or a cardiac issue.";

    return Scaffold(
      appBar: AppBar(title: const Text('Health Alert')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: urgentColor.withValues(alpha: isDark ? 0.16 : 0.08),
              borderRadius: AppRadius.xlRadius,
              border: Border.all(color: urgentColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: urgentColor, size: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(whatHappened, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: urgentColor)),
                      const SizedBox(height: 2),
                      Text('$dogName · Detected just now', style: theme.textTheme.labelSmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Why This May Be Concerning', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Text(why, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xxl),
          Text('Current Readings', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _readingTile(context, 'Heart Rate', '142 bpm', urgentColor)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _readingTile(context, 'Temperature', '39.8°C', urgentColor)),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Recommended Immediate Action', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          _actionStep(context, 1, 'Check on $dogName — look for signs of distress, panting, or discomfort.'),
          _actionStep(context, 2, 'Move to a cool, quiet area and offer water.'),
          _actionStep(context, 3, 'Contact your veterinarian if the reading doesn\'t normalize within 15-20 minutes.'),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground, borderRadius: AppRadius.mdRadius),
            child: Text(
              'This is AI decision-support, not a definitive diagnosis. When in doubt, contact a veterinarian.',
              style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => VetDiscoveryScreen(dogId: dogId, dogName: dogName))),
            icon: const Icon(Icons.local_hospital_rounded),
            label: const Text('Contact Veterinarian'),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MessagesScreen())),
            icon: const Icon(Icons.emergency_rounded),
            label: const Text('Emergency Veterinary Services'),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => AppFeedback.showToast(context, title: 'Health report ready', message: 'A shareable summary was prepared for your veterinarian.', type: ToastType.success),
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text('Share Health Report'),
          ),
        ],
      ),
    );
  }

  Widget _readingTile(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: AppRadius.mdRadius, border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _actionStep(BuildContext context, int number, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(color: isDark ? AppColors.primaryOnDark : AppColors.primary, shape: BoxShape.circle),
            child: Center(child: Text('$number', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
