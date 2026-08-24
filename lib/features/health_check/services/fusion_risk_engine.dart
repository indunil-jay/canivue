import 'package:flutter/material.dart';
import 'package:canivue/features/health_check/models/health_check_models.dart';
import 'package:canivue/features/pets/models/pet_model.dart';

/// A deterministic, on-device implementation of the two algorithms
/// described in the "Adaptive Multimodal AI System for Canine Disease
/// Detection and Progression Risk Prediction" proposal:
///
///  1. The Confidence-Weighted Adaptive Fusion mechanism, which combines
///     an image, wearable-sensor, and symptom-text stream by weighting
///     each by (model confidence x input quality) rather than a fixed
///     split, and gracefully drops any modality that is unavailable.
///  2. The Disease Progression & Risk Prediction Engine (DPRPE), which
///     takes the fused diagnosis and combines it with behavioural trend,
///     symptom progression, breed susceptibility, medical history, and
///     age to forecast a seven-day deterioration risk.
///
/// There is no real vision/IMU/NLP model behind this — those require a
/// trained backend that is out of scope for this Flutter client — so the
/// per-modality "confidence" and "quality" figures are computed from
/// simple, explainable heuristics over the text the owner enters and the
/// pet's own profile. The fusion and progression *math* itself mirrors
/// the proposal's worked examples exactly.
class FusionRiskEngine {
  const FusionRiskEngine._();

  static const int _progressionHorizonDays = 7;

  /// Keyword -> suspected condition & baseline severity. Checked in order;
  /// the first match wins, mirroring a simple symptom-classification model.
  static const List<(List<String>, String, double)> _conditionRules = [
    (['ear', 'shaking head', 'head shaking'], 'Suspected Ear Infection', 70),
    (['itch', 'scratch', 'rash', 'red skin', 'redness', 'hair loss', 'bald'], 'Suspected Skin Infection', 72),
    (['limp', 'joint', 'stiff', 'won\'t walk', 'leg'], 'Suspected Joint Strain', 60),
    (['vomit', 'diarrhea', 'diarrhoea', 'not eating', 'appetite'], 'Suspected Digestive Upset', 58),
    (['cough', 'sneeze', 'breath', 'wheeze', 'nose'], 'Suspected Respiratory Concern', 62),
    (['lethargic', 'tired', 'low energy', 'sleeping a lot'], 'Suspected Systemic Infection', 65),
    (['wound', 'bleeding', 'cut', 'swelling', 'swollen'], 'Suspected Wound / Inflammation', 74),
  ];

  static const List<String> _worseningWords = [
    'worse', 'worsening', 'spreading', 'more', 'increased', 'increasing', 'severe', 'bleeding', 'weeks', 'days'
  ];

  /// Very small breed -> disease-susceptibility lookup, standing in for the
  /// "veterinarian-reviewed breed knowledge base" described in the proposal.
  static double _breedRiskFor(String breed) {
    final b = breed.toLowerCase();
    if (b.contains('bulldog') || b.contains('pug')) return 75; // brachycephalic / skin folds
    if (b.contains('retriever') || b.contains('labrador')) return 68; // skin & ear prone
    if (b.contains('shepherd')) return 60; // joint susceptibility
    if (b.contains('poodle') || b.contains('terrier')) return 55;
    return 48;
  }

  static double _ageRiskFor(int ageYears) {
    if (ageYears >= 8) return 78;
    if (ageYears >= 5) return 58;
    if (ageYears <= 1) return 42; // puppies carry their own (different) vulnerability
    return 32;
  }

  static double _historyRiskFor(Pet pet) {
    var score = 35.0;
    final hasAllergies = pet.allergies.any(
      (a) => a.trim().isNotEmpty && !a.toLowerCase().contains('none'),
    );
    if (hasAllergies) score += 25;
    final notes = pet.specialNotes.toLowerCase();
    if (notes.contains('recur') || notes.contains('sensitive') || notes.contains('chronic')) {
      score += 20;
    }
    return score.clamp(0, 100);
  }

  static HealthCheckResult run({
    required Pet pet,
    required bool hasImage,
    required bool hasWearable,
    required String symptomText,
  }) {
    final text = symptomText.trim().toLowerCase();
    final wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;

    // ---- Step 1: individual "model" predictions -------------------------
    String condition = 'General Wellness Check';
    double baseSeverity = 30;
    for (final rule in _conditionRules) {
      final (keywords, label, severity) = rule;
      if (keywords.any(text.contains)) {
        condition = label;
        baseSeverity = severity;
        break;
      }
    }
    final matchedKeyword = condition != 'General Wellness Check';
    final worseningMentioned = _worseningWords.any(text.contains);

    // ---- Step 2 & 3: quality + confidence -> reliability per modality ---
    final modalities = <_Modality>[
      _Modality(
        name: 'Image',
        icon: Icons.photo_camera_rounded,
        available: hasImage,
        confidence: hasImage ? (matchedKeyword ? 92 : 74) : 0,
        quality: hasImage ? 88 : 0,
      ),
      _Modality(
        name: 'Smart Collar',
        icon: Icons.sensors_rounded,
        available: hasWearable,
        confidence: hasWearable ? (matchedKeyword ? 85 : 66) : 0,
        quality: hasWearable ? 82 : 0,
      ),
      _Modality(
        name: 'Symptom Text',
        icon: Icons.notes_rounded,
        available: text.isNotEmpty,
        confidence: text.isNotEmpty ? (matchedKeyword ? 80 : 55) : 0,
        quality: text.isNotEmpty ? (40 + (wordCount * 4)).clamp(0, 100).toDouble() : 0,
      ),
    ];

    final available = modalities.where((m) => m.available).toList();
    final totalReliability = available.fold<double>(0, (sum, m) => sum + m.reliability);

    final modalityResults = <ModalityResult>[];
    double finalConfidence = 0;
    for (final m in modalities) {
      final contribution = (m.available && totalReliability > 0) ? (m.reliability / totalReliability) * 100 : 0.0;
      if (m.available) {
        finalConfidence += (contribution / 100) * m.confidence;
      }
      modalityResults.add(
        ModalityResult(
          name: m.name,
          icon: m.icon,
          available: m.available,
          confidencePercent: m.confidence,
          qualityPercent: m.quality,
          contributionPercent: contribution,
        ),
      );
    }

    final notes = <String>[];
    if (!hasImage) notes.add('Image was unavailable — the result relies on the remaining inputs.');
    if (!hasWearable) notes.add('Smart-collar data was unavailable — the result relies on the remaining inputs.');
    if (text.isEmpty) notes.add('No symptom description was provided.');
    if (available.isEmpty) {
      finalConfidence = 0;
      notes.add('No inputs were available — add a photo, connect the collar, or describe a symptom to run a check.');
    }

    final severityLabel = baseSeverity >= 70
        ? 'Moderate–Severe'
        : baseSeverity >= 50
            ? 'Moderate'
            : 'Mild';

    final fusion = FusionOutput(
      condition: condition,
      finalConfidencePercent: finalConfidence,
      severityLabel: severityLabel,
      modalities: modalityResults,
      notes: notes,
    );

    // ---- DPRPE: Steps 1-12 -----------------------------------------------
    final behaviouralTrend = hasWearable ? (worseningMentioned ? 78.0 : 42.0) : 0.0;
    final symptomProgression = matchedKeyword ? (worseningMentioned ? 82.0 : 45.0) : 20.0;
    final breedRisk = _breedRiskFor(pet.breed);
    final historyRisk = _historyRiskFor(pet);
    final ageRisk = _ageRiskFor(pet.ageYears);

    final factorDefs = <(String, double, double, bool)>[
      ('Current disease severity', baseSeverity, 30, true),
      ('Behavioural trend (collar)', behaviouralTrend, 20, hasWearable),
      ('Symptom progression', symptomProgression, 25, true),
      ('Breed-related risk', breedRisk, 10, true),
      ('Medical history', historyRisk, 5, true),
      ('Age-related risk', ageRisk, 10, true),
    ];

    final availableFactors = factorDefs.where((f) => f.$4).toList();
    final totalWeight = availableFactors.fold<double>(0, (sum, f) => sum + f.$3);

    final factors = <RiskFactor>[];
    double progressionRisk = 0;
    for (final f in availableFactors) {
      final (label, score, weight, _) = f;
      final normalizedWeight = totalWeight > 0 ? (weight / totalWeight) * 100 : 0.0;
      final contribution = score * (normalizedWeight / 100);
      progressionRisk += contribution;
      factors.add(RiskFactor(
        label: label,
        scorePercent: score,
        weightPercent: normalizedWeight,
        contributionPoints: contribution,
      ));
    }
    factors.sort((a, b) => b.contributionPoints.compareTo(a.contributionPoints));

    final riskLevel = RiskLevelX.fromScore(progressionRisk);
    final mainReasons = factors.take(3).map((f) => f.label).toList();

    String? missingDataNote;
    if (!hasWearable) {
      missingDataNote =
          'Behavioural-trend data was unavailable. The progression risk was recalculated using the remaining factors.';
    }

    final progression = ProgressionOutput(
      horizonDays: _progressionHorizonDays,
      riskPercent: progressionRisk,
      riskLevel: riskLevel,
      factors: factors,
      mainReasons: mainReasons,
      recommendation: riskLevel.recommendation,
      missingDataNote: missingDataNote,
    );

    return HealthCheckResult(
      petName: pet.name,
      fusion: fusion,
      progression: progression,
      generatedAt: DateTime.now(),
    );
  }
}

class _Modality {
  _Modality({
    required this.name,
    required this.icon,
    required this.available,
    required this.confidence,
    required this.quality,
  });

  final String name;
  final IconData icon;
  final bool available;
  final double confidence;
  final double quality;

  double get reliability => available ? confidence * (quality / 100) : 0;
}
