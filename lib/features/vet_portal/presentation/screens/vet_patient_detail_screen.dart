import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/empty_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/features/health/presentation/widgets/metric_chart_card.dart';
import 'package:canivue/features/predictions/presentation/controllers/prediction_controller.dart';
import 'package:canivue/features/predictions/presentation/widgets/prediction_card.dart';
import 'package:canivue/features/vet_portal/domain/vet_patient.dart';
import 'package:canivue/features/vets/domain/appointment.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';
import 'package:canivue/features/vets/presentation/controllers/appointment_controller.dart';

/// Professional patient view for veterinarians: medical info, multi-modal
/// prediction review, wearable trends, and past appointments.
class VetPatientDetailScreen extends ConsumerWidget {
  const VetPatientDetailScreen({super.key, required this.patient});

  final VetPatient patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final predictionAsync = ref.watch(latestPredictionProvider(patient.dogId));
    final appointmentsAsync = ref.watch(appointmentsProvider(patient.dogId));

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
          '${patient.dogName}\'s Chart',
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
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          children: [
            // Hero Patient Banner
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
                    child: const Center(
                      child: Text('🐶', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${patient.dogName} · ${patient.breed}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${patient.ageFormatted} · Owner: ${patient.ownerName}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Critical Alert Banner if needed
            if (patient.hasCriticalAlert)
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0x2EF43F5E) : const Color(0xFFFDF2F0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: Color(0xFFF43F5E), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Clinical Alert',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: const Color(0xFFF43F5E),
                            ),
                          ),
                          Text(
                            'Continuous smart-collar telemetry flagged elevated resting vitals.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : const Color(0xFF57534E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Medical Info Card
            _sectionLabel('Medical Conditions & Allergies', isDark),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _chipRow(context, 'Allergies', patient.allergies, const Color(0xFFF43F5E), isDark),
                  const SizedBox(height: 14),
                  _chipRow(context, 'Existing Conditions', patient.existingConditions, const Color(0xFFF59E0B), isDark),
                  const SizedBox(height: 14),
                  _chipRow(context, 'Current Medications', patient.currentMedications, const Color(0xFF10B981), isDark),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI Prediction
            _sectionLabel('AI Diagnostic Telemetry', isDark),
            const SizedBox(height: 8),
            predictionAsync.when(
              loading: () => const SkeletonBox(height: 160, borderRadius: BorderRadius.all(Radius.circular(24))),
              error: (_, _) => const SizedBox.shrink(),
              data: (prediction) => prediction == null
                  ? const EmptyState(
                      icon: Icons.auto_awesome_outlined,
                      title: 'No active predictions',
                      message: 'AI neural diagnostics show no high-risk conditions currently.',
                    )
                  : PredictionCard(prediction: prediction),
            ),
            const SizedBox(height: 20),

            // Health Trends
            _sectionLabel('Wearable Telemetry Trends', isDark),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: MetricChartCard(dogId: patient.dogId),
              ),
            ),
            const SizedBox(height: 20),

            // Appointment History
            _sectionLabel('Consultation History', isDark),
            const SizedBox(height: 8),
            appointmentsAsync.when(
              loading: () => const SkeletonBox(height: 80, borderRadius: BorderRadius.all(Radius.circular(20))),
              error: (_, _) => const SizedBox.shrink(),
              data: (appointments) {
                if (appointments.isEmpty) {
                  return const EmptyState(
                    icon: Icons.event_busy_rounded,
                    title: 'No past visits',
                    message: 'Past visits and notes for this patient will be recorded here.',
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        for (int i = 0; i < appointments.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ListTile(
                            leading: Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                appointments[i].consultationType == ConsultationType.video
                                    ? Icons.videocam_rounded
                                    : Icons.local_hospital_rounded,
                                color: const Color(0xFF0F766E),
                                size: 18,
                              ),
                            ),
                            title: Text(
                              DateFormat('MMMM d, yyyy').format(appointments[i].dateTime),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            subtitle: Text(
                              appointments[i].notes.isEmpty ? appointments[i].status.label : appointments[i].notes,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }

  Widget _chipRow(BuildContext context, String label, List<String> items, Color color, bool isDark) {
    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'None reported',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.18 : 0.09),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    item,
                    style: GoogleFonts.plusJakartaSans(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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
