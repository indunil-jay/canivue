import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/privacy/presentation/screens/privacy_security_screen.dart';
import 'package:canivue/features/vet_portal/domain/vet_reputation.dart';
import 'package:canivue/features/vet_portal/presentation/controllers/vet_portal_controller.dart';
import 'package:canivue/features/vet_portal/presentation/screens/vet_availability_screen.dart';

/// The "Profile" tab of the vet shell: verified credentials, reputation stats,
/// patient reviews, availability manager, and session security.
class VetProfessionalProfileScreen extends ConsumerWidget {
  const VetProfessionalProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final vetName = user?.name.isNotEmpty == true ? user!.name : 'Doctor';
    final reputationAsync = ref.watch(vetReputationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Doctor Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 110),
          children: [
            // Hero Doctor Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                vetName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                          ],
                        ),
                        Text(
                          user?.email ?? '',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Verified Veterinarian',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Reputation Section
            reputationAsync.when(
              loading: () => const SkeletonBox(height: 120, borderRadius: BorderRadius.all(Radius.circular(24))),
              error: (_, _) => ErrorState(
                message: "We couldn't load reputation stats.",
                onRetry: () => ref.invalidate(vetReputationProvider),
              ),
              data: (reputation) => _ReputationSection(reputation: reputation, isDark: isDark),
            ),
            const SizedBox(height: 20),

            // Quick Actions & Settings
            Text(
              'Practice Management',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _navTile(
              context,
              Icons.event_available_rounded,
              'Clinic Availability',
              'Manage your weekly consultation schedule',
              () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VetAvailabilityScreen())),
              isDark,
            ),
            _navTile(
              context,
              Icons.notifications_outlined,
              'Notification Preferences',
              'Appointment reminders & canine vital alerts',
              () => AppFeedback.showToast(context, title: 'Preferences', message: 'Configured automatically.', type: ToastType.info),
              isDark,
            ),
            _navTile(
              context,
              Icons.security_rounded,
              'Privacy & Security',
              'Active sessions, 2FA & medical data security',
              () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacySecurityScreen())),
              isDark,
            ),
            const SizedBox(height: 20),

            // Log Out Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final confirmed = await AppFeedback.showLuxuryDialog(
                    context,
                    title: 'Log Out',
                    message: 'Are you sure you want to log out of Canivue Clinical Portal?',
                    confirmText: 'Log Out',
                    cancelText: 'Cancel',
                    icon: Icons.logout_rounded,
                    accentColor: const Color(0xFFF43F5E),
                    iconGradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFFB7185)]),
                  );
                  if (confirmed == true && context.mounted) {
                    ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) context.go('/sign-in');
                  }
                },
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x22F43F5E) : const Color(0xFFFDF2F0),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, color: Color(0xFFF43F5E), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Log Out',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFF43F5E),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
      ),
      child: ListTile(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF0F766E), size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
      ),
    );
  }
}

class _ReputationSection extends StatelessWidget {
  const _ReputationSection({required this.reputation, required this.isDark});

  final VetReputation reputation;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clinical Reputation & Impact',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statTile(
                '${reputation.averageRating}',
                'Avg Rating',
                Icons.star_rounded,
                const Color(0xFFF59E0B),
                AppColors.pastelAmber,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statTile(
                '${reputation.totalConsultations}',
                'Consults',
                Icons.forum_rounded,
                const Color(0xFF0F766E),
                AppColors.pastelMint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statTile(
                '${reputation.recommendationsAcceptedPercent}%',
                'Accepted Recs',
                Icons.thumb_up_rounded,
                const Color(0xFF10B981),
                AppColors.pastelMintSoft,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statTile(
                '${reputation.repeatConsultationPercent}%',
                'Repeat Dogs',
                Icons.repeat_rounded,
                const Color(0xFF7A67EE),
                AppColors.pastelLilac,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Recent Patient Owner Reviews',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 10),
        for (final review in reputation.reviews) _reviewTile(context, review),
      ],
    );
  }

  Widget _statTile(String value, String label, IconData icon, Color color, Color pastelColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.12) : pastelColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF181A20),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF57534E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewTile(BuildContext context, dynamic review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review.ownerName,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  review.rating,
                  (_) => const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.comment,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
