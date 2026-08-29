import 'package:canivue/features/preventive_care/domain/care_task.dart';
import 'package:canivue/features/preventive_care/domain/care_task_repository.dart';

class FakeCareTaskRepository implements CareTaskRepository {
  final Map<String, List<CareTask>> _tasks = {};

  List<CareTask> _seedFor(String dogId) {
    final now = DateTime.now();
    return [
      CareTask(id: 't-$dogId-1', dogId: dogId, category: CareTaskCategory.vaccination, title: 'Rabies booster', dueDate: now.add(const Duration(days: 9))),
      CareTask(id: 't-$dogId-2', dogId: dogId, category: CareTaskCategory.deworming, title: 'Deworming treatment', dueDate: now.subtract(const Duration(days: 1))),
      CareTask(id: 't-$dogId-3', dogId: dogId, category: CareTaskCategory.fleaTick, title: 'Flea & tick prevention', dueDate: now.add(const Duration(days: 5))),
      CareTask(id: 't-$dogId-4', dogId: dogId, category: CareTaskCategory.dental, title: 'Dental cleaning', dueDate: now.add(const Duration(days: 30))),
      CareTask(id: 't-$dogId-5', dogId: dogId, category: CareTaskCategory.grooming, title: 'Grooming appointment', dueDate: now.add(const Duration(days: 14))),
      CareTask(id: 't-$dogId-6', dogId: dogId, category: CareTaskCategory.annualCheck, title: 'Annual wellness exam', dueDate: now.add(const Duration(days: 60))),
      CareTask(id: 't-$dogId-7', dogId: dogId, category: CareTaskCategory.weightGoal, title: 'Weight check-in', dueDate: now.add(const Duration(days: 3))),
      CareTask(id: 't-$dogId-8', dogId: dogId, category: CareTaskCategory.medication, title: 'Joint supplement refill', dueDate: now.add(const Duration(days: 2))),
    ];
  }

  Future<List<CareTask>> _current(String dogId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _tasks.putIfAbsent(dogId, () => _seedFor(dogId));
  }

  @override
  Future<List<CareTask>> fetchTasks(String dogId) async {
    final tasks = await _current(dogId);
    final sorted = List<CareTask>.from(tasks)..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return sorted;
  }

  @override
  Future<CareTask> markDone(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (final entry in _tasks.entries) {
      final index = entry.value.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final updated = entry.value[index].copyWith(completed: true);
        entry.value[index] = updated;
        return updated;
      }
    }
    throw StateError('Task not found: $taskId');
  }
}
