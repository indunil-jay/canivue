import 'package:canivue/features/medical_records/domain/medical_record.dart';
import 'package:canivue/features/medical_records/domain/medical_records_repository.dart';

class FakeMedicalRecordsRepository implements MedicalRecordsRepository {
  final Map<String, List<MedicalRecord>> _records = {};

  List<MedicalRecord> _seedFor(String dogId) {
    final now = DateTime.now();
    return [
      MedicalRecord(
        id: 'rec-$dogId-1',
        dogId: dogId,
        type: MedicalRecordType.diagnosis,
        title: 'Annual wellness exam',
        description: 'No abnormalities found. Weight and vitals within normal range.',
        date: now.subtract(const Duration(days: 40)),
      ),
      MedicalRecord(
        id: 'rec-$dogId-2',
        dogId: dogId,
        type: MedicalRecordType.prescription,
        title: 'Joint support supplement',
        description: '1 chew daily with food, ongoing.',
        date: now.subtract(const Duration(days: 40)),
      ),
      MedicalRecord(
        id: 'rec-$dogId-3',
        dogId: dogId,
        type: MedicalRecordType.labResult,
        title: 'Bloodwork panel',
        description: 'Complete blood count and metabolic panel — all values normal.',
        date: now.subtract(const Duration(days: 95)),
      ),
      MedicalRecord(
        id: 'rec-$dogId-4',
        dogId: dogId,
        type: MedicalRecordType.note,
        title: 'Vet note',
        description: 'Owner reported mild seasonal itchiness; advised to monitor.',
        date: now.subtract(const Duration(days: 110)),
      ),
    ];
  }

  Future<List<MedicalRecord>> _current(String dogId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _records.putIfAbsent(dogId, () => _seedFor(dogId));
  }

  @override
  Future<List<MedicalRecord>> fetchRecords(String dogId) async {
    final records = await _current(dogId);
    final sorted = List<MedicalRecord>.from(records)..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  @override
  Future<MedicalRecord> addDocument(String dogId, String title, String filePath) async {
    await _current(dogId);
    await Future.delayed(const Duration(milliseconds: 400));
    final record = MedicalRecord(
      id: 'rec-${DateTime.now().microsecondsSinceEpoch}',
      dogId: dogId,
      type: MedicalRecordType.document,
      title: title,
      description: 'Uploaded by owner.',
      date: DateTime.now(),
      attachmentPath: filePath,
    );
    _records[dogId]!.add(record);
    return record;
  }
}
