import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/vet_portal/domain/vet_reputation.dart';
import 'package:canivue/features/vet_portal/presentation/controllers/vet_portal_controller.dart';
import 'package:canivue/features/vet_portal/presentation/screens/vet_availability_screen.dart';

/// The "Profile" tab of the vet shell — professional profile, feedback &
/// reputation (brief §17, §35), availability management and preferences.
class VetProfessionalProfileScreen extends ConsumerWidget {
  const VetProfessionalProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final vetName = user?.name.isNotEmpty == true ? user!.name : 'Doctor';
    final reputationAsync = ref.watch(vetReputationProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Professional Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: AppRadius.xlRadius),
            child: Row(
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
                  child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(vetName, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                        ],
                      ),
                      Text(user?.email ?? '', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: AppRadius.pillRadius),
                        child: const Text('Verified Veterinarian', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          reputationAsync.when(
            loading: () => SkeletonBox(height: 100, borderRadius: AppRadius.xlRadius),
            error: (_, _) => ErrorState(message: "We couldn't load reputation stats.", onRetry: () => ref.invalidate(vetReputationProvider)),
            data: (reputation) => _ReputationSection(reputation: reputation),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _navTile(context, Icons.event_available_rounded, 'Availability', 'Manage your weekly consultation hours', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VetAvailabilityScreen()))),
          _navTile(context, Icons.notifications_outlined, 'Notification Preferences', 'Appointment reminders & alerts', () => AppFeedback.showToast(context, title: 'Preferences', message: 'Coming soon.', type: ToastType.info)),
          _navTile(context, Icons.security_rounded, 'Privacy & Security', 'Sessions, 2FA and data controls', () => AppFeedback.showToast(context, title: 'Privacy & Security', message: 'Coming soon.', type: ToastType.info)),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await AppFeedback.showLuxuryDialog(
                  context,
                  title: 'Log Out',
                  message: 'Are you sure you want to log out of Canivue?',
                  confirmText: 'Log Out',
                  cancelText: 'Cancel',
                  icon: Icons.logout_rounded,
                  accentColor: const Color(0xFFF43F5E),
                  iconGradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFFB7185)]),
                );
                if (confirmed == true) {
                  ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) context.go('/sign-in');
                }
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.red.shade200), padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
        tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        leading: Icon(icon, color: isDark ? AppColors.primaryOnDark : AppColors.primary),
        title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _ReputationSection extends StatelessWidget {
  const _ReputationSection({required this.reputation});

  final VetReputation reputation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Feedback & Reputation', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: _statTile(context, '${reputation.averageRating}', 'Avg Rating', Icons.star_rounded, const Color(0xFFF59E0B))),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _statTile(context, '${reputation.totalConsultations}', 'Consultations', Icons.forum_rounded, isDark ? AppColors.primaryOnDark : AppColors.primary)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: _statTile(context, '${reputation.recommendationsAcceptedPercent}%', 'Recs Accepted', Icons.thumb_up_rounded, isDark ? AppColors.successOnDark : AppColors.success)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _statTile(context, '${reputation.repeatConsultationPercent}%', 'Repeat Patients', Icons.repeat_rounded, isDark ? AppColors.intelligenceOnDark : AppColors.intelligence)),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Recent Reviews', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        for (final review in reputation.reviews) _reviewTile(context, review),
      ],
    );
  }

  Widget _statTile(BuildContext context, String value, String label, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: AppRadius.mdRadius, border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
        ],
      ),
    );
  }

  Widget _reviewTile(BuildContext context, PatientReview review) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: AppRadius.mdRadius, border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review.ownerName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star_rounded : Icons.star_border_rounded, size: 14, color: const Color(0xFFF59E0B))),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(review.comment, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(DateFormat('MMM d, yyyy').format(review.date), style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText)),
        ],
      ),
    );
  }
}
