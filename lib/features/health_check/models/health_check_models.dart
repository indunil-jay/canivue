import 'package:flutter/material.dart';

/// The four-tier risk categorisation used by the Disease Progression &
/// Risk Prediction Engine (DPRPE), matching the proposal's thresholds:
/// 0-29 Low, 30-59 Moderate, 60-84 High, 85-100 Critical.
enum RiskLevel { low, moderate, high, critical }

extension RiskLevelX on RiskLevel {
  static RiskLevel fromScore(double score) {
    if (score >= 85) return RiskLevel.critical;
    if (score >= 60) return RiskLevel.high;
    if (score >= 30) return RiskLevel.moderate;
    return RiskLevel.low;
  }

  String get label => switch (this) {
        RiskLevel.low => 'Low',
        RiskLevel.moderate => 'Moderate',
        RiskLevel.high => 'High',
        RiskLevel.critical => 'Critical',
      };

  Color get color => switch (this) {
        RiskLevel.low => const Color(0xFF16A34A),
        RiskLevel.moderate => const Color(0xFFF59E0B),
        RiskLevel.high => const Color(0xFFEA580C),
        RiskLevel.critical => const Color(0xFFDC2626),
      };

  String get recommendation => switch (this) {
        RiskLevel.low => 'Continue routine at-home monitoring.',
        RiskLevel.moderate => 'Schedule a routine vet check-up within 1–2 weeks.',
        RiskLevel.high => 'Veterinary consultation recommended within 24–48 hours.',
        RiskLevel.critical => 'Seek urgent veterinary care as soon as possible.',
      };
}

/// One evidence stream (image, wearable sensor, or symptom text) that fed
/// the Confidence-Weighted Adaptive Fusion mechanism.
class ModalityResult {
  const ModalityResult({
    required this.name,
    required this.icon,
    required this.available,
    required this.confidencePercent,
    required this.qualityPercent,
    required this.contributionPercent,
  });

  final String name;
  final IconData icon;
  final bool available;
  final double confidencePercent;
  final double qualityPercent;
  final double contributionPercent;
}

/// Output of the Confidence-Weighted Adaptive Fusion mechanism.
class FusionOutput {
  const FusionOutput({
    required this.condition,
    required this.finalConfidencePercent,
    required this.severityLabel,
    required this.modalities,
    required this.notes,
  });

  final String condition;
  final double finalConfidencePercent;
  final String severityLabel;
  final List<ModalityResult> modalities;

  /// Missing/low-quality modality warnings, e.g. "Sensor information was
  /// unavailable. The prediction used the image and symptom description."
  final List<String> notes;
}

/// One weighted contributor inside the DPRPE progression-risk calculation.
class RiskFactor {
  const RiskFactor({
    required this.label,
    required this.scorePercent,
    required this.weightPercent,
    required this.contributionPoints,
  });

  final String label;
  final double scorePercent;
  final double weightPercent;
  final double contributionPoints;
}

/// Output of the Disease Progression & Risk Prediction Engine.
class ProgressionOutput {
  const ProgressionOutput({
    required this.horizonDays,
    required this.riskPercent,
    required this.riskLevel,
    required this.factors,
    required this.mainReasons,
    required this.recommendation,
    this.missingDataNote,
  });

  final int horizonDays;
  final double riskPercent;
  final RiskLevel riskLevel;
  final List<RiskFactor> factors;
  final List<String> mainReasons;
  final String recommendation;
  final String? missingDataNote;
}

/// Full, owner-facing result of a single AI health check run.
class HealthCheckResult {
  const HealthCheckResult({
    required this.petName,
    required this.fusion,
    required this.progression,
    required this.generatedAt,
  });

  final String petName;
  final FusionOutput fusion;
  final ProgressionOutput progression;
  final DateTime generatedAt;

  static const String safetyNotice =
      'This is a preliminary decision-support result and does not replace an examination by a licensed veterinarian.';
}
