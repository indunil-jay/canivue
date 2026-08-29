/// AI disease-prediction domain (brief §11-13). Every prediction is
/// explicitly decision-support, never a definitive diagnosis — that
/// disclaimer is carried in the UI, not just this comment.
library;

enum PredictionStatus { monitoring, lowRisk, moderateRisk, highRisk, resolved, vetReviewRecommended }

extension PredictionStatusLabel on PredictionStatus {
  String get label => switch (this) {
        PredictionStatus.monitoring => 'Monitoring',
        PredictionStatus.lowRisk => 'Low Risk',
        PredictionStatus.moderateRisk => 'Moderate Risk',
        PredictionStatus.highRisk => 'High Risk',
        PredictionStatus.resolved => 'Resolved',
        PredictionStatus.vetReviewRecommended => 'Vet Review Recommended',
      };
}

/// One contributing model's independent read on the case, before fusion
/// into the combined prediction — the basis of the explainability view.
class ModelContribution {
  const ModelContribution({required this.modelName, required this.contributionPercent});

  final String modelName;
  final double contributionPercent;
}

class Prediction {
  const Prediction({
    required this.id,
    required this.dogId,
    required this.title,
    required this.category,
    required this.status,
    required this.combinedRiskPercent,
    required this.confidencePercent,
    required this.predictionDate,
    required this.modelVersion,
    required this.affectedIndicators,
    required this.recommendedNextStep,
    required this.modelContributions,
    required this.dataQualityNote,
    required this.historicalComparisonNote,
    this.outcomeNote,
  });

  final String id;
  final String dogId;

  /// e.g. "Possible Early Respiratory Condition"
  final String title;

  /// e.g. "Respiratory"
  final String category;
  final PredictionStatus status;

  /// 0-100, the fused/combined risk score.
  final double combinedRiskPercent;

  /// 0-100, overall model confidence in this prediction.
  final double confidencePercent;
  final DateTime predictionDate;
  final String modelVersion;
  final List<String> affectedIndicators;
  final String recommendedNextStep;
  final List<ModelContribution> modelContributions;
  final String dataQualityNote;
  final String historicalComparisonNote;

  /// Follow-up outcome once known (e.g. "Vet confirmed mild bronchitis").
  final String? outcomeNote;
}
