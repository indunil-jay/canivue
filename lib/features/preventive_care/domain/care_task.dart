/// Proactive/preventive healthcare (brief §21) — the full "What's Due"
/// list, beyond the couple of items previewed on the Home dashboard.
enum CareTaskCategory { vaccination, deworming, fleaTick, dental, grooming, annualCheck, weightGoal, medication }

extension CareTaskCategoryLabel on CareTaskCategory {
  String get label => switch (this) {
        CareTaskCategory.vaccination => 'Vaccination',
        CareTaskCategory.deworming => 'Deworming',
        CareTaskCategory.fleaTick => 'Flea & Tick Prevention',
        CareTaskCategory.dental => 'Dental Care',
        CareTaskCategory.grooming => 'Grooming',
        CareTaskCategory.annualCheck => 'Annual Health Check',
        CareTaskCategory.weightGoal => 'Weight Goal',
        CareTaskCategory.medication => 'Medication',
      };
}

class CareTask {
  const CareTask({
    required this.id,
    required this.dogId,
    required this.category,
    required this.title,
    required this.dueDate,
    this.completed = false,
  });

  final String id;
  final String dogId;
  final CareTaskCategory category;
  final String title;
  final DateTime dueDate;
  final bool completed;

  bool get isOverdue => !completed && dueDate.isBefore(DateTime.now());

  CareTask copyWith({bool? completed}) => CareTask(
        id: id,
        dogId: dogId,
        category: category,
        title: title,
        dueDate: dueDate,
        completed: completed ?? this.completed,
      );
}
