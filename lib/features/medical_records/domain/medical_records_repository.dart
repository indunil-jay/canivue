import 'package:canivue/features/medical_records/domain/medical_record.dart';

abstract class MedicalRecordsRepository {
  Future<List<MedicalRecord>> fetchRecords(String dogId);

  Future<MedicalRecord> addDocument(String dogId, String title, String filePath);
}
