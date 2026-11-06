import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/pets/data/fake_dog_repository.dart';
import 'package:canivue/features/pets/domain/dog_repository.dart';
import 'package:canivue/features/pets/models/pet_model.dart';

final dogRepositoryProvider = Provider<DogRepository>((ref) => FakeDogRepository());

/// All of the signed-in owner's dogs with full CRUD capabilities.
class DogsNotifier extends AsyncNotifier<List<Pet>> {
  @override
  Future<List<Pet>> build() {
    return ref.watch(dogRepositoryProvider).fetchDogs();
  }

  Future<void> addDog(Pet pet) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(dogRepositoryProvider).addDog(pet);
      ref.read(activeDogIdProvider.notifier).state = pet.id;
      return ref.read(dogRepositoryProvider).fetchDogs();
    });
  }

  Future<void> updateDog(Pet pet) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(dogRepositoryProvider).updateDog(pet);
      return ref.read(dogRepositoryProvider).fetchDogs();
    });
  }

  Future<void> deleteDog(String petId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(dogRepositoryProvider).deleteDog(petId);
      final remaining = await ref.read(dogRepositoryProvider).fetchDogs();
      if (ref.read(activeDogIdProvider) == petId) {
        ref.read(activeDogIdProvider.notifier).state = remaining.isNotEmpty ? remaining.first.id : null;
      }
      return remaining;
    });
  }
}

final dogsProvider = AsyncNotifierProvider<DogsNotifier, List<Pet>>(DogsNotifier.new);

/// The explicitly-selected dog id, if the owner has switched away from the
/// default. `null` means "use the first dog" — see [activeDogProvider].
final activeDogIdProvider = StateProvider<String?>((ref) => null);

/// The dog the rest of the app (home, health, etc.) is currently showing.
/// Wraps [dogsProvider]'s `AsyncValue` so screens naturally get real
/// loading/error/empty states instead of only the happy path.
final activeDogProvider = Provider<AsyncValue<Pet?>>((ref) {
  final dogsAsync = ref.watch(dogsProvider);
  final activeId = ref.watch(activeDogIdProvider);

  return dogsAsync.whenData((dogs) {
    if (dogs.isEmpty) return null;
    if (activeId == null) return dogs.first;
    return dogs.firstWhere((dog) => dog.id == activeId, orElse: () => dogs.first);
  });
});
