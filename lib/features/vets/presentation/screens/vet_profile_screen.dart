import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';
import 'package:canivue/features/vets/presentation/controllers/vet_controller.dart';
import 'package:canivue/features/vets/presentation/screens/booking_screen.dart';

/// Detailed veterinarian profile: credentials, reviews, clinics, languages,
/// fee breakdown, and consultation scheduling.
class VetProfileScreen extends ConsumerWidget {
  const VetProfileScreen({
    super.key,
    required this.vetId,
    required this.dogId,
    required this.dogName,
  });

  final String vetId;
  final String dogId;
  final String dogName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vetAsync = ref.watch(vetDetailProvider(vetId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF181A20),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Doctor Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: false,
        child: vetAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SkeletonBox(height: 160, borderRadius: BorderRadius.all(Radius.circular(24))),
                SizedBox(height: 16),
                SkeletonBox(height: 180, borderRadius: BorderRadius.all(Radius.circular(24))),
              ],
            ),
          ),
          error: (_, _) => ErrorState(
            message: "We couldn't load this profile.",
            onRetry: () => ref.invalidate(vetDetailProvider(vetId)),
          ),
          data: (vet) => _ProfileBody(vet: vet, dogId: dogId, dogName: dogName),
        ),
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
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
                height: 74,
                width: 74,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    vet.initials,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                ),
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
                            vet.name,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (vet.verified) ...[
                          const SizedBox(width: 5),
                          const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vet.specialty,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Color(0xFFFDCB58), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${vet.rating} (${vet.reviewCount} reviews)',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Key Stats Row
        Row(
          children: [
            Expanded(child: _statTile(context, '${vet.experienceYears}y', 'Experience', isDark)),
            const SizedBox(width: 10),
            Expanded(child: _statTile(context, '${vet.consultationCount}', 'Consults', isDark)),
            const SizedBox(width: 10),
            Expanded(child: _statTile(context, '${vet.followUpRatePercent}%', 'Follow-up', isDark)),
          ],
        ),
        const SizedBox(height: 20),

        // About Doctor
        Text(
          'About Doctor',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            ),
          ),
          child: Text(
            vet.bio,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Chips: Specialties, Languages, Clinics
        _labelledChips(context, 'Specialties & Modalities', vet.specialties, isDark),
        const SizedBox(height: 14),
        _labelledChips(context, 'Languages Spoken', vet.languages, isDark),
        const SizedBox(height: 14),
        _labelledChips(context, 'Affiliated Clinics & Hospitals', vet.clinics, isDark),
        const SizedBox(height: 20),

        // Fee Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Standard Consultation Fee',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${vet.consultationFeeUsd.toStringAsFixed(0)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (vet.availableToday ? const Color(0xFF10B981) : const Color(0xFF64748B))
                      .withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  vet.availableToday ? '● Available Today' : '● Next Available Soon',
                  style: GoogleFonts.plusJakartaSans(
                    color: vet.availableToday ? const Color(0xFF10B981) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Action Buttons Row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  AppFeedback.showToast(
                    context,
                    title: 'Direct Chat 💬',
                    message: 'Initiating consultation thread with ${vet.name}.',
                    type: ToastType.info,
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: Text(
                  'Message',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.primaryOnDark : AppColors.primary,
                  side: BorderSide(
                    color: isDark ? AppColors.primaryOnDark : AppColors.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(vet: vet, dogId: dogId, dogName: dogName),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: Text(
                  'Book Now',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statTile(BuildContext context, String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelledChips(BuildContext context, String label, List<String> items, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMintSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0x4414B8A6) : const Color(0xFFD3EFE8),
                    ),
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryOnDark : AppColors.primary,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
