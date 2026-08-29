/// Secure digital veterinary record (brief §20) — diagnoses, prescriptions,
/// lab results, notes and uploaded documents/images, shown chronologically.
enum MedicalRecordType { diagnosis, prescription, labResult, note, document }

class MedicalRecord {
  const MedicalRecord({
    required this.id,
    required this.dogId,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    this.attachmentPath,
  });

  final String id;
  final String dogId;
  final MedicalRecordType type;
  final String title;
  final String description;
  final DateTime date;

  /// Local file path for an uploaded document/image, if any.
  final String? attachmentPath;
}
