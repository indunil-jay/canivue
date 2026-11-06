import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/features/vet_portal/presentation/controllers/vet_portal_controller.dart';

/// Availability management for veterinarians — configure weekly clinic and telehealth schedule.
class VetAvailabilityScreen extends ConsumerWidget {
  const VetAvailabilityScreen({super.key});

  static const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availabilityAsync = ref.watch(vetAvailabilityControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          'Clinic Availability',
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
        child: availabilityAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: List.generate(
              7,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: SkeletonBox(height: 56, borderRadius: BorderRadius.all(Radius.circular(16))),
              ),
            ),
          ),
          error: (_, _) => ErrorState(
            message: "We couldn't load availability.",
            onRetry: () => ref.invalidate(vetAvailabilityControllerProvider),
          ),
          data: (availability) => ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            children: [
              Text(
                'Toggle the days you are available for video telehealth and in-clinic physical consultations.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              for (final day in _days)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.2,
                    ),
                  ),
                  child: SwitchListTile(
                    value: availability[day] ?? false,
                    onChanged: (v) {
                      HapticFeedback.lightImpact();
                      ref.read(vetAvailabilityControllerProvider.notifier).setDay(day, v);
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    activeColor: const Color(0xFF10B981),
                    title: Text(
                      day,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      (availability[day] ?? false) ? 'Accepting appointments' : 'Off duty',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: (availability[day] ?? false)
                            ? const Color(0xFF10B981)
                            : (isDark ? AppColors.darkMutedText : AppColors.lightMutedText),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
