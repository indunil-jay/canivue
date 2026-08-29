import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';
import 'package:canivue/features/vets/presentation/controllers/vet_controller.dart';
import 'package:canivue/features/vets/presentation/screens/booking_screen.dart';

/// Detailed veterinarian profile (brief §17): qualifications, specialties,
/// clinics, languages, fee, ratings, consultation stats, and the entry
/// point into booking.
class VetProfileScreen extends ConsumerWidget {
  const VetProfileScreen({super.key, required this.vetId, required this.dogId, required this.dogName});

  final String vetId;
  final String dogId;
  final String dogName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vetAsync = ref.watch(vetDetailProvider(vetId));

    return Scaffold(
      appBar: AppBar(title: const Text('Veterinarian Profile')),
      body: vetAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(20),
          child: Column(children: [SkeletonBox(height: 160), SizedBox(height: 16), SkeletonBox(height: 200)]),
        ),
        error: (_, _) => ErrorState(message: "We couldn't load this profile.", onRetry: () => ref.invalidate(vetDetailProvider(vetId))),
        data: (vet) => _ProfileBody(vet: vet, dogId: dogId, dogName: dogName),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.vet, required this.dogId, required this.dogName});

  final Veterinarian vet;
  final String dogId;
  final String dogName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: AppRadius.xlRadius),
          child: Row(
            children: [
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
                child: Center(child: Text(vet.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24))),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(vet.name, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))),
                        if (vet.verified) ...[const SizedBox(width: 6), const Icon(Icons.verified_rounded, color: Colors.white, size: 18)],
                      ],
                    ),
                    Text(vet.specialty, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('${vet.rating} (${vet.reviewCount} reviews)', style: theme.textTheme.labelSmall?.copyWith(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          children: [
            Expanded(child: _statTile(context, '${vet.experienceYears} yrs', 'Experience')),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _statTile(context, '${vet.consultationCount}', 'Consultations')),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _statTile(context, '${vet.followUpRatePercent}%', 'Follow-up Rate')),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('About', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(vet.bio, style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xxl),
        _labelledChips(context, 'Specialties', vet.specialties),
        const SizedBox(height: AppSpacing.lg),
        _labelledChips(context, 'Languages', vet.languages),
        const SizedBox(height: AppSpacing.lg),
        _labelledChips(context, 'Qualifications', vet.qualifications),
        const SizedBox(height: AppSpacing.lg),
        _labelledChips(context, 'Clinics', vet.clinics),
        const SizedBox(height: AppSpacing.xxl),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: AppRadius.xlRadius,
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Consultation Fee', style: theme.textTheme.bodySmall?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    Text('\$${vet.consultationFeeUsd.toStringAsFixed(0)}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text(
                vet.availableToday ? 'Available today' : 'Next available soon',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: vet.availableToday ? (isDark ? AppColors.successOnDark : AppColors.success) : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => AppFeedback.showToast(context, title: 'Messaging', message: 'Veterinary messaging arrives in a future update.', type: ToastType.info),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text('Message'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BookingScreen(vet: vet, dogId: dogId, dogName: dogName)),
                ),
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: const Text('Book Consultation'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statTile(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground,
        borderRadius: AppRadius.mdRadius,
      ),
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
        ],
      ),
    );
  }

  Widget _labelledChips(BuildContext context, String label, List<String> items) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((item) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground,
                      borderRadius: AppRadius.pillRadius,
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Text(item, style: theme.textTheme.labelSmall),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
