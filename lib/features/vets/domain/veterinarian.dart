enum ConsultationType { video, inPerson, chat }

extension ConsultationTypeLabel on ConsultationType {
  String get label => switch (this) {
        ConsultationType.video => 'Video Call',
        ConsultationType.inPerson => 'In Person',
        ConsultationType.chat => 'Chat',
      };
}

/// Veterinary discovery/profile domain (brief §16-17).
class Veterinarian {
  const Veterinarian({
    required this.id,
    required this.name,
    required this.initials,
    required this.verified,
    required this.specialty,
    required this.specialties,
    required this.experienceYears,
    required this.rating,
    required this.reviewCount,
    required this.consultationCount,
    required this.responseTimeMinutes,
    required this.consultationFeeUsd,
    required this.languages,
    required this.distanceKm,
    required this.availableToday,
    required this.consultationTypes,
    required this.bio,
    required this.clinics,
    required this.qualifications,
    required this.followUpRatePercent,
    required this.recommendationsAcceptedPercent,
  });

  final String id;
  final String name;
  final String initials;
  final bool verified;

  /// Primary specialty shown on the card, e.g. "Dermatology".
  final String specialty;
  final List<String> specialties;
  final int experienceYears;

  /// 0-5.
  final double rating;
  final int reviewCount;
  final int consultationCount;
  final int responseTimeMinutes;
  final double consultationFeeUsd;
  final List<String> languages;
  final double distanceKm;
  final bool availableToday;
  final List<ConsultationType> consultationTypes;
  final String bio;
  final List<String> clinics;
  final List<String> qualifications;
  final int followUpRatePercent;
  final int recommendationsAcceptedPercent;
}
