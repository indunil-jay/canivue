import 'package:canivue/features/pets/models/pet_model.dart';

/// Source of a dog owner's registered dogs. `FakeDogRepository` backs this
/// today; a real implementation later talks to the backend without any
/// presentation-layer changes (see the `canivue-architecture` skill).
abstract class DogRepository {
  Future<List<Pet>> fetchDogs();
}
