import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/medical_records/data/fake_medical_records_repository.dart';
import 'package:canivue/features/medical_records/domain/medical_record.dart';
import 'package:canivue/features/medical_records/domain/medical_records_repository.dart';

final medicalRecordsRepositoryProvider = Provider<MedicalRecordsRepository>((ref) => FakeMedicalRecordsRepository());

class MedicalRecordsController extends FamilyAsyncNotifier<List<MedicalRecord>, String> {
  late final String _dogId;

  @override
  Future<List<MedicalRecord>> build(String dogId) {
    _dogId = dogId;
    return ref.watch(medicalRecordsRepositoryProvider).fetchRecords(dogId);
  }

  Future<void> uploadDocument(String title, String filePath) async {
    final repo = ref.read(medicalRecordsRepositoryProvider);
    final record = await repo.addDocument(_dogId, title, filePath);
    state = AsyncData([record, ...(state.value ?? const [])]);
  }
}

final medicalRecordsControllerProvider = AsyncNotifierProvider.family<MedicalRecordsController, List<MedicalRecord>, String>(
  MedicalRecordsController.new,
);
