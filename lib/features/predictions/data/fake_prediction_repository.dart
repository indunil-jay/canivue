import 'package:canivue/features/predictions/domain/prediction.dart';
import 'package:canivue/features/predictions/domain/prediction_repository.dart';

/// Deterministic-per-dog fake predictions. One dog variant deliberately has
/// no active prediction, so the "no predictions" empty state (brief §36)
/// actually gets exercised rather than only ever showing the happy path.
class FakePredictionRepository implements PredictionRepository {
  @override
  Future<Prediction?> fetchLatest(String dogId) async {
    await Future.delayed(const Duration(milliseconds: 550));

    final variant = dogId.hashCode % 3;
    if (variant == 2) return null;

    final now = DateTime.now();

    if (variant == 0) {
      return Prediction(
        id: 'pred-$dogId-latest',
        dogId: dogId,
        title: 'Possible Early Respiratory Condition',
        category: 'Respiratory',
        status: PredictionStatus.moderateRisk,
        combinedRiskPercent: 84,
        confidencePercent: 88,
        predictionDate: now.subtract(const Duration(hours: 6)),
        modelVersion: 'canivue-fusion-v2.3',
        affectedIndicators: const ['Respiratory Rate', 'Activity Level', 'Coughing Frequency'],
        recommendedNextStep: 'Schedule a veterinary consultation within the next few days to evaluate further.',
        modelContributions: const [
          ModelContribution(modelName: 'Respiratory Model', contributionPercent: 91),
          ModelContribution(modelName: 'Historical Health Model', contributionPercent: 88),
          ModelContribution(modelName: 'Activity Model', contributionPercent: 82),
          ModelContribution(modelName: 'Temperature Model', contributionPercent: 74),
          ModelContribution(modelName: 'Behavior Model', contributionPercent: 68),
        ],
        dataQualityNote: 'High — 12 days of continuous smart-collar data plus 2 AI health checks.',
        historicalComparisonNote: 'Respiratory rate is 22% above this dog\'s 30-day baseline, sustained for 3 days.',
      );
    }

    return Prediction(
      id: 'pred-$dogId-latest',
      dogId: dogId,
      title: 'Mild Activity Decline Detected',
      category: 'Behavioral',
      status: PredictionStatus.monitoring,
      combinedRiskPercent: 41,
      confidencePercent: 76,
      predictionDate: now.subtract(const Duration(hours: 14)),
      modelVersion: 'canivue-fusion-v2.3',
      affectedIndicators: const ['Activity Level', 'Sleep Duration'],
      recommendedNextStep: 'No immediate action needed — Canivue will keep monitoring over the next 7 days.',
      modelContributions: const [
        ModelContribution(modelName: 'Activity Model', contributionPercent: 58),
        ModelContribution(modelName: 'Behavior Model', contributionPercent: 47),
        ModelContribution(modelName: 'Historical Health Model', contributionPercent: 39),
      ],
      dataQualityNote: 'Moderate — some smart-collar gaps over the past week.',
      historicalComparisonNote: 'Activity is 9% below baseline — within normal week-to-week variation for most dogs.',
    );
  }

  @override
  Future<List<Prediction>> fetchHistory(String dogId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final latest = await fetchLatest(dogId);

    final history = <Prediction>[
      ?latest,
      Prediction(
        id: 'pred-$dogId-1',
        dogId: dogId,
        title: 'Elevated Resting Heart Rate',
        category: 'Cardiovascular',
        status: PredictionStatus.resolved,
        combinedRiskPercent: 62,
        confidencePercent: 81,
        predictionDate: now.subtract(const Duration(days: 18)),
        modelVersion: 'canivue-fusion-v2.2',
        affectedIndicators: const ['Heart Rate', 'Activity Level'],
        recommendedNextStep: 'Vet visit completed — condition resolved.',
        modelContributions: const [
          ModelContribution(modelName: 'Historical Health Model', contributionPercent: 79),
          ModelContribution(modelName: 'Activity Model', contributionPercent: 55),
        ],
        dataQualityNote: 'High — full smart-collar coverage.',
        historicalComparisonNote: 'Heart rate returned to baseline after 5 days.',
        outcomeNote: 'Vet confirmed mild dehydration; resolved after increased water intake.',
      ),
      Prediction(
        id: 'pred-$dogId-2',
        dogId: dogId,
        title: 'Possible Joint Discomfort',
        category: 'Musculoskeletal',
        status: PredictionStatus.vetReviewRecommended,
        combinedRiskPercent: 70,
        confidencePercent: 84,
        predictionDate: now.subtract(const Duration(days: 47)),
        modelVersion: 'canivue-fusion-v2.1',
        affectedIndicators: const ['Movement Pattern', 'Restlessness'],
        recommendedNextStep: 'Vet review recommended to assess joint health.',
        modelContributions: const [
          ModelContribution(modelName: 'Behavior Model', contributionPercent: 73),
          ModelContribution(modelName: 'Activity Model', contributionPercent: 66),
        ],
        dataQualityNote: 'High — consistent daily tracking.',
        historicalComparisonNote: 'Gait irregularity 15% above baseline over 10 days.',
        outcomeNote: 'Follow-up consultation scheduled.',
      ),
    ];

    history.sort((a, b) => b.predictionDate.compareTo(a.predictionDate));
    return history;
  }
}
