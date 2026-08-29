import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/predictions/data/fake_prediction_repository.dart';
import 'package:canivue/features/predictions/domain/prediction.dart';
import 'package:canivue/features/predictions/domain/prediction_repository.dart';

final predictionRepositoryProvider = Provider<PredictionRepository>((ref) => FakePredictionRepository());

final latestPredictionProvider = FutureProvider.family<Prediction?, String>((ref, dogId) {
  return ref.watch(predictionRepositoryProvider).fetchLatest(dogId);
});

final predictionHistoryProvider = FutureProvider.family<List<Prediction>, String>((ref, dogId) {
  return ref.watch(predictionRepositoryProvider).fetchHistory(dogId);
});
