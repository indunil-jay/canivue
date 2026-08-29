import 'package:canivue/features/pets/domain/dog_repository.dart';
import 'package:canivue/features/pets/models/pet_model.dart';

/// In-memory [DogRepository] backed by [Pet.samplePets], with a simulated
/// network delay so loading states are real rather than instant.
class FakeDogRepository implements DogRepository {
  @override
  Future<List<Pet>> fetchDogs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(Pet.samplePets);
  }
}
