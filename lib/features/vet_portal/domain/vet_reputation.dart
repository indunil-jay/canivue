/// Feedback & reputation (brief §35).
class PatientReview {
  const PatientReview({required this.ownerName, required this.rating, required this.comment, required this.date});

  final String ownerName;
  final int rating;
  final String comment;
  final DateTime date;
}

class VetReputation {
  const VetReputation({
    required this.averageRating,
    required this.totalConsultations,
    required this.recommendationsAcceptedPercent,
    required this.repeatConsultationPercent,
    required this.reviews,
  });

  final double averageRating;
  final int totalConsultations;
  final int recommendationsAcceptedPercent;
  final int repeatConsultationPercent;
  final List<PatientReview> reviews;
}
