/// A dog as seen from the veterinarian's side (brief §33-34) — the owner's
/// `Pet`/dog entity plus the clinical context a vet actually works from.
class VetPatient {
  const VetPatient({
    required this.dogId,
    required this.dogName,
    required this.breed,
    required this.ageFormatted,
    required this.ownerName,
    required this.lastVisit,
    required this.needsFollowUp,
    required this.hasCriticalAlert,
    required this.allergies,
    required this.existingConditions,
    required this.currentMedications,
  });

  final String dogId;
  final String dogName;
  final String breed;
  final String ageFormatted;
  final String ownerName;
  final DateTime lastVisit;
  final bool needsFollowUp;
  final bool hasCriticalAlert;
  final List<String> allergies;
  final List<String> existingConditions;
  final List<String> currentMedications;
}
