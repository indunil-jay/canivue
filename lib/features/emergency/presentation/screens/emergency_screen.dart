import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/messages/presentation/screens/messages_screen.dart';
import 'package:canivue/features/vets/presentation/screens/vet_discovery_screen.dart';

/// Critical canine telemetry alert screen: explains detected biometrics clearly,
/// provides immediate stabilization steps, and direct emergency routing.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const urgentColor = Color(0xFFF43F5E);
    final why = whyConcerning ??
        "$dogName's heart rate has been significantly above baseline for the past 30 minutes, which can indicate pain, stress, heat exposure, or an acute cardiac issue.";

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
          'Health Alert',
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
            // Alert Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x2EF43F5E) : const Color(0xFFFDF2F0),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: urgentColor.withValues(alpha: 0.4), width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: urgentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_rounded, color: urgentColor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          whatHappened,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: urgentColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$dogName · Detected via smart collar just now',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : const Color(0xFF57534E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _sectionLabel('Clinical Context', isDark),
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
                why,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            _sectionLabel('Current Biometric Telemetry', isDark),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _readingTile(context, 'Heart Rate', '142 bpm', urgentColor, isDark)),
                const SizedBox(width: 12),
                Expanded(child: _readingTile(context, 'Temperature', '39.8°C', urgentColor, isDark)),
              ],
            ),
            const SizedBox(height: 20),

            _sectionLabel('Immediate Stabilization Steps', isDark),
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
              child: Column(
                children: [
                  _actionStep(context, 1, 'Check on $dogName — look for signs of distress, excessive panting, or pale gums.', isDark),
                  const SizedBox(height: 12),
                  _actionStep(context, 2, 'Move to a cool, quiet room and offer fresh water.', isDark),
                  const SizedBox(height: 12),
                  _actionStep(context, 3, 'If readings do not stabilize in 15–20 minutes, initiate immediate vet triage.', isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Call / Contact Vet
            FilledButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => VetDiscoveryScreen(dogId: dogId, dogName: dogName)),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppColors.charcoalBlack : const Color(0xFF181A20),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 3,
              ),
              icon: const Icon(Icons.local_hospital_rounded, size: 18, color: Colors.white),
              label: Text(
                'Contact Veterinarian',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                AppFeedback.showToast(
                  context,
                  title: 'Report Generated 📄',
                  message: 'A telemetry summary has been generated for your clinic.',
                  type: ToastType.success,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? AppColors.primaryOnDark : AppColors.primary,
                side: BorderSide(color: isDark ? AppColors.primaryOnDark : AppColors.primary, width: 1.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.ios_share_rounded, size: 18),
              label: Text(
                'Export Diagnostic Telemetry',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
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

  Widget _readingTile(BuildContext context, String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionStep(BuildContext context, int number, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF0F766E).withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF0F766E),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
