import 'package:canivue/features/predictions/domain/prediction.dart';

abstract class PredictionRepository {
  /// The current/most recent active prediction, if any (not every dog has
  /// one at any given time — see brief §36, design for "no predictions").
  Future<Prediction?> fetchLatest(String dogId);

  Future<List<Prediction>> fetchHistory(String dogId);
}
