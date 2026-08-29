import 'package:canivue/features/preventive_care/domain/care_task.dart';

abstract class CareTaskRepository {
  Future<List<CareTask>> fetchTasks(String dogId);

  Future<CareTask> markDone(String taskId);
}
