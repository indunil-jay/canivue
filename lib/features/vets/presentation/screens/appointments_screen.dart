import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/features/vets/domain/appointment.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';
import 'package:canivue/features/vets/presentation/controllers/appointment_controller.dart';
import 'package:canivue/features/vets/presentation/screens/vet_discovery_screen.dart';

Color _statusColor(BuildContext context, AppointmentStatus status) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return switch (status) {
    AppointmentStatus.confirmed || AppointmentStatus.upcoming => const Color(0xFF10B981),
    AppointmentStatus.completed => isDark ? AppColors.primaryOnDark : AppColors.primary,
    AppointmentStatus.requested || AppointmentStatus.inProgress => const Color(0xFFF59E0B),
    AppointmentStatus.cancelled || AppointmentStatus.noShow => isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
  };
}

/// Appointment history for a dog across requested, upcoming, completed, and past states.
class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key, required this.dogId, required this.dogName});

  final String dogId;
  final String dogName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider(dogId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: AmbientPawBackdrop(
        showPawWatermarks: true,
        showParticles: true,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Editorial Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : const Color(0xFF181A20),
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? const Color(0x4414B8A6) : const Color(0xFFBFE7DC),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('📅', style: TextStyle(fontSize: 11)),
                                const SizedBox(width: 4),
                                Text(
                                  'SCHEDULED SESSIONS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? AppColors.primaryOnDark : AppColors.primary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$dogName\'s Visits',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // New Booking Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => VetDiscoveryScreen(dogId: dogId, dogName: dogName),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'Book',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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

              // 2. Appointments List
              Expanded(
                child: appointmentsAsync.when(
                  loading: () => ListView(
                    padding: const EdgeInsets.all(20),
                    children: List.generate(
                      3,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: SkeletonBox(height: 84, borderRadius: BorderRadius.all(Radius.circular(22))),
                      ),
                    ),
                  ),
                  error: (_, _) => ErrorState(
                    message: "We couldn't load appointments.",
                    onRetry: () => ref.invalidate(appointmentsProvider(dogId)),
                  ),
                  data: (appointments) {
                    if (appointments.isEmpty) {
                      return EmptyState(
                        icon: Icons.event_busy_rounded,
                        title: 'No appointments yet',
                        message: 'Book a veterinary consultation for $dogName to view it here.',
                        actionLabel: 'Find a Vet',
                        onAction: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VetDiscoveryScreen(dogId: dogId, dogName: dogName),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                      itemCount: appointments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        final color = _statusColor(context, appointment.status);
                        final isVideo = appointment.consultationType == ConsultationType.video;

                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: color.withValues(alpha: 0.3)),
                                ),
                                child: Icon(
                                  isVideo ? Icons.videocam_rounded : Icons.local_hospital_rounded,
                                  color: color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appointment.vetName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      DateFormat('EEE, MMM d · h:mm a').format(appointment.dateTime),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isVideo ? 'Video Consultation' : 'In-Clinic Visit',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: color.withValues(alpha: 0.35)),
                                ),
                                child: Text(
                                  appointment.status.label,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: color,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
