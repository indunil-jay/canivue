import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/features/health_check/models/health_check_models.dart';

/// Owner-facing explainable output of a single AI Health Check run, showing
/// both mechanisms from the proposal: the fused current-condition result
/// (with per-modality contribution breakdown) and the DPRPE seven-day
/// progression-risk forecast with its explained contributing factors.
class HealthCheckResultScreen extends StatelessWidget {
  const HealthCheckResultScreen({super.key, required this.result});

  final HealthCheckResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fusion = result.fusion;
    final progression = result.progression;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Health Check Results',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                  // Header: predicted condition + fused confidence
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${result.petName} · ${fusion.severityLabel} severity',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                fusion.condition,
                                style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                              ),
                            ],
                          ),
                        ),
                        _ConfidenceRing(confidence: fusion.finalConfidencePercent),
                      ],
                    ),
                  ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.12, end: 0),
                  const SizedBox(height: 20),

                  // Adaptive fusion breakdown
                  _Card(
                    title: 'Confidence-Weighted Fusion',
                    icon: Icons.hub_rounded,
                    theme: theme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How each evidence stream contributed to the fused result:',
                          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 14),
                        ...fusion.modalities.map((m) => _ModalityRow(modality: m)),
                        if (fusion.notes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          const Divider(height: 20),
                          ...fusion.notes.map(
                            (note) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.warningAmber),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(note, style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(duration: 380.ms, delay: 80.ms).slideY(begin: 0.12, end: 0),
                  const SizedBox(height: 16),

                  // DPRPE risk card
                  _Card(
                    title: 'Disease Progression Risk (DPRPE)',
                    icon: Icons.timeline_rounded,
                    theme: theme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${progression.riskPercent.toStringAsFixed(1)}%',
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: progression.riskLevel.color),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                'risk within ${progression.horizonDays} days',
                                style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: progression.riskLevel.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: progression.riskLevel.color.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                '${progression.riskLevel.label} Risk',
                                style: TextStyle(color: progression.riskLevel.color, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (progression.riskPercent / 100).clamp(0, 1),
                            minHeight: 10,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(progression.riskLevel.color),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Main contributing factors',
                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ...progression.factors.map((f) => _RiskFactorRow(factor: f)),
                        if (progression.missingDataNote != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.warningAmber),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  progression.missingDataNote!,
                                  style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
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
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'The risk is mainly influenced by ${progression.mainReasons.join(', ').toLowerCase()}.',
                              style: const TextStyle(fontSize: 12.5, height: 1.4, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(duration: 380.ms, delay: 160.ms).slideY(begin: 0.12, end: 0),
                  const SizedBox(height: 16),

                  // Recommendation
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: progression.riskLevel.color.withValues(alpha: 0.08),
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
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 380.ms, delay: 220.ms).slideY(begin: 0.12, end: 0),
                  const SizedBox(height: 16),

                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 5)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
                      label: const Text('Book Vet Consultation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          HealthCheckResult.safetyNotice,
                          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant, height: 1.4),
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
  const _Card({required this.title, required this.icon, required this.child, required this.theme});
  final String title;
  final IconData icon;
  final Widget child;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
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
  const _ModalityRow({required this.modality});
  final ModalityResult modality;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final available = modality.available;
    final color = available ? AppTheme.primaryBlue : colorScheme.onSurfaceVariant.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(modality.icon, size: 18, color: color),
          const SizedBox(width: 10),
          SizedBox(
            width: 78,
            child: Text(
              modality.name,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: available ? null : colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (modality.contributionPercent / 100).clamp(0, 1),
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
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
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskFactorRow extends StatelessWidget {
  const _RiskFactorRow({required this.factor});
  final RiskFactor factor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(factor.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
                  backgroundColor: colorScheme.surfaceContainerHighest,
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
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceRing extends StatelessWidget {
  const _ConfidenceRing({required this.confidence});
  final double confidence;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      width: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 68,
            width: 68,
            child: CircularProgressIndicator(
              value: (confidence / 100).clamp(0, 1),
              strokeWidth: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          Text(
            '${confidence.toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
