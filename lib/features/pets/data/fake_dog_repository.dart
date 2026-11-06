import 'package:canivue/features/pets/domain/dog_repository.dart';
import 'package:canivue/features/pets/models/pet_model.dart';

/// In-memory [DogRepository] backed by [Pet.samplePets], with simulated
/// network delays and full CRUD support.
class FakeDogRepository implements DogRepository {
  final List<Pet> _dogs = List.from(Pet.samplePets);

  @override
  Future<List<Pet>> fetchDogs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_dogs);
  }

  @override
  Future<void> addDog(Pet pet) async {
    await Future.delayed(const Duration(milliseconds: 350));
    _dogs.insert(0, pet);
  }

  @override
  Future<void> updateDog(Pet pet) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final index = _dogs.indexWhere((d) => d.id == pet.id);
    if (index != -1) {
      _dogs[index] = pet;
    } else {
      _dogs.add(pet);
    }
  }

  @override
  Future<void> deleteDog(String petId) async {
    await Future.delayed(const Duration(milliseconds: 350));
    _dogs.removeWhere((d) => d.id == petId);
  }
}
