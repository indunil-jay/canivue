import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/messages/domain/message.dart';

/// Post-consultation summary shared into the thread (brief §19) —
/// visually distinct from a plain chat bubble so it reads as a structured
/// clinical veterinary record rather than ordinary text.
class ConsultationSummaryBubble extends StatefulWidget {
  const ConsultationSummaryBubble({super.key, this.message});

  final ChatMessage? message;

  @override
  State<ConsultationSummaryBubble> createState() => _ConsultationSummaryBubbleState();
}

class _ConsultationSummaryBubbleState extends State<ConsultationSummaryBubble> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final msg = widget.message;
    final diagnosis = msg?.summaryDiagnosis ?? 'Mild Seasonal Contact Dermatitis';
    final treatment = msg?.summaryTreatment ?? 'Antihistamine + soothing paw wipes 1x daily for 10 days';
    final followUp = msg?.summaryFollowUp ?? 'Follow-up in 10 days via video consultation';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0C1820) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? const Color(0x3314B8A6) : const Color(0xFFBFE7DC),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : const Color(0xFF0F766E)).withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Ribbon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x2214B8A6) : AppColors.pastelMint,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 28,
                    width: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F766E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.description_rounded, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CLINICAL CONSULTATION SUMMARY',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                        Text(
                          'Official Veterinary Record',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Record Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Diagnosis
                  _detailRow(
                    context,
                    icon: Icons.healing_rounded,
                    label: 'DIAGNOSIS',
                    value: diagnosis,
                    isDark: isDark,
                    highlight: true,
                  ),
                  const SizedBox(height: 12),

                  // Treatment & Medication
                  _detailRow(
                    context,
                    icon: Icons.medication_rounded,
                    label: 'TREATMENT & RX',
                    value: treatment,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),

                  // Follow-Up
                  _detailRow(
                    context,
                    icon: Icons.event_available_rounded,
                    label: 'FOLLOW-UP PLAN',
                    value: followUp,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Action Button: Save to Medical Records
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setState(() => _saved = !_saved);
                        AppFeedback.showToast(
                          context,
                          title: _saved ? 'Saved to Records 📁' : 'Removed',
                          message: _saved
                              ? 'Consultation summary archived to Buddy\'s medical chart.'
                              : 'Removed from quick records.',
                          type: ToastType.success,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _saved
                            ? (isDark ? const Color(0x2210B981) : AppColors.pastelMint)
                            : Colors.transparent,
                        foregroundColor: const Color(0xFF0F766E),
                        side: BorderSide(
                          color: _saved ? const Color(0xFF10B981) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(
                        _saved ? Icons.check_circle_rounded : Icons.bookmark_add_outlined,
                        size: 16,
                        color: const Color(0xFF0F766E),
                      ),
                      label: Text(
                        _saved ? 'Archived in Dog\'s Chart' : 'Save to Medical Records',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0F766E)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  height: 1.35,
                  fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                  color: highlight
                      ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E))
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
