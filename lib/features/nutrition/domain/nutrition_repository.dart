import 'package:canivue/features/nutrition/domain/nutrition_profile.dart';

abstract class NutritionRepository {
  Future<NutritionProfile> fetchProfile(String dogId);
}
