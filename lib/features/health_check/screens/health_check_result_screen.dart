import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/core/widgets/luxury_biometric_ring.dart';
import 'package:canivue/features/health_check/models/health_check_models.dart';

class HealthCheckResultScreen extends StatelessWidget {
  const HealthCheckResultScreen({super.key, required this.result});

  final HealthCheckResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final fusion = result.fusion;
    final progression = result.progression;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Health Check Results',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 19,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Card: Predicted Condition + Fused Confidence Dial
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(
                              colors: [Color(0xFF0C2142), Color(0xFF091A36), Color(0xFF061126)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : AppTheme.heroGradient,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: isDark ? 0.4 : 0.35),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                                ),
                                child: Text(
                                  '${result.petName} · ${fusion.severityLabel} severity',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                fusion.condition,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Confidence-weighted multimodal diagnostic',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        LuxuryBiometricRing(
                          percentage: fusion.finalConfidencePercent,
                          size: 78,
                          strokeWidth: 7,
                          valueText: '${fusion.finalConfidencePercent.toInt()}',
                          unitText: '%',
                          label: 'Confidence',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Adaptive Fusion Breakdown
                  _Card(
                    title: 'Confidence-Weighted Fusion',
                    icon: Icons.hub_rounded,
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How each evidence stream contributed to the fused result:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...fusion.modalities.map((m) => _ModalityRow(modality: m, isDark: isDark)),
                        if (fusion.notes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Divider(
                            height: 20,
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                          ),
                          ...fusion.notes.map(
                            (note) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline_rounded, size: 15, color: AppTheme.warningAmber),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      note,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // DPRPE Risk Card
                  _Card(
                    title: 'Disease Progression Risk (DPRPE)',
                    icon: Icons.timeline_rounded,
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '${progression.riskPercent.toStringAsFixed(1)}%',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: progression.riskLevel.color,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'within ${progression.horizonDays}d',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: progression.riskLevel.color.withValues(alpha: isDark ? 0.2 : 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: progression.riskLevel.color.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                '${progression.riskLevel.label} Risk',
                                style: GoogleFonts.plusJakartaSans(
                                  color: progression.riskLevel.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (progression.riskPercent / 100).clamp(0, 1),
                            minHeight: 10,
                            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation(progression.riskLevel.color),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Main contributing factors',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...progression.factors.map((f) => _RiskFactorRow(factor: f, isDark: isDark)),
                        if (progression.missingDataNote != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.warningAmber),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  progression.missingDataNote!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: isDark ? Colors.white70 : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (progression.mainReasons.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              'The risk is mainly influenced by ${progression.mainReasons.join(', ').toLowerCase()}.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Recommendation
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: progression.riskLevel.color.withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border(left: BorderSide(color: progression.riskLevel.color, width: 4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.medical_services_rounded, color: progression.riskLevel.color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            progression.recommendation,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Book Vet Button
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Booking Vet Appointment...'), behavior: SnackBarBehavior.floating),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
                      label: Text(
                        'Book Vet Consultation',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: isDark ? Colors.white60 : colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          HealthCheckResult.safetyNotice,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.icon, required this.child, required this.isDark});
  final String title;
  final IconData icon;
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D2D).withValues(alpha: 0.85) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.primaryBlue.withValues(alpha: 0.2) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ModalityRow extends StatelessWidget {
  const _ModalityRow({required this.modality, required this.isDark});
  final ModalityResult modality;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final available = modality.available;
    final color = available ? AppTheme.primaryBlue : (isDark ? Colors.white30 : const Color(0xFF94A3B8));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              modality.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (modality.contributionPercent / 100).clamp(0, 1),
                minHeight: 8,
                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 44,
            child: Text(
              available ? '${modality.contributionPercent.toStringAsFixed(0)}%' : '—',
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskFactorRow extends StatelessWidget {
  const _RiskFactorRow({required this.factor, required this.isDark});
  final RiskFactor factor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              factor.label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (factor.scorePercent / 100).clamp(0, 1),
                  minHeight: 7,
                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.oceanBlue),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 54,
            child: Text(
              '+${factor.contributionPoints.toStringAsFixed(1)}',
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
