import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/preventive_care/data/fake_care_task_repository.dart';
import 'package:canivue/features/preventive_care/domain/care_task.dart';
import 'package:canivue/features/preventive_care/domain/care_task_repository.dart';

final careTaskRepositoryProvider = Provider<CareTaskRepository>((ref) => FakeCareTaskRepository());

class CareTaskController extends FamilyAsyncNotifier<List<CareTask>, String> {
  @override
  Future<List<CareTask>> build(String dogId) {
    return ref.watch(careTaskRepositoryProvider).fetchTasks(dogId);
  }

  Future<void> markDone(String taskId) async {
    final updated = await ref.read(careTaskRepositoryProvider).markDone(taskId);
    state = AsyncData([for (final t in state.value ?? const []) if (t.id == taskId) updated else t]);
  }
}

final careTaskControllerProvider = AsyncNotifierProvider.family<CareTaskController, List<CareTask>, String>(CareTaskController.new);
