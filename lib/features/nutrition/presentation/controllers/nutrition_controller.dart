import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/nutrition/data/fake_nutrition_repository.dart';
import 'package:canivue/features/nutrition/domain/nutrition_profile.dart';
import 'package:canivue/features/nutrition/domain/nutrition_repository.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) => FakeNutritionRepository());

final nutritionProfileProvider = FutureProvider.family<NutritionProfile, String>((ref, dogId) {
  return ref.watch(nutritionRepositoryProvider).fetchProfile(dogId);
});
