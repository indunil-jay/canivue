import 'package:canivue/features/vet_portal/domain/vet_dashboard_summary.dart';
import 'package:canivue/features/vet_portal/domain/vet_patient.dart';
import 'package:canivue/features/vet_portal/domain/vet_portal_repository.dart';
import 'package:canivue/features/vet_portal/domain/vet_reputation.dart';

class FakeVetPortalRepository implements VetPortalRepository {
  final Map<String, bool> _availability = {
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': true,
    'Saturday': false,
    'Sunday': false,
  };

  @override
  Future<VetDashboardSummary> fetchDashboard(String vetName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return VetDashboardSummary(
      vetName: vetName,
      todaySchedule: const [
        ScheduleEntry(time: '9:00 AM', ownerName: 'Alex Taylor', dogName: 'Buddy', type: 'Video Call', confirmed: true),
        ScheduleEntry(time: '11:30 AM', ownerName: 'Priya M.', dogName: 'Milo', type: 'In Person', confirmed: true),
        ScheduleEntry(time: '2:00 PM', ownerName: 'James K.', dogName: 'Rocky', type: 'Video Call', confirmed: false),
        ScheduleEntry(time: '4:30 PM', ownerName: 'Sofia R.', dogName: 'Bella', type: 'In Person', confirmed: true),
      ],
      waitingConsultationCount: 2,
      criticalAlertCount: 1,
      newPatientCount: 3,
      recentMessages: const [
        RecentMessagePreview(ownerName: 'Alex Taylor', preview: 'Thank you! Buddy seems to be doing much better.', timeAgo: '30m ago'),
        RecentMessagePreview(ownerName: 'Priya M.', preview: 'Should I keep him on the same dosage?', timeAgo: '2h ago'),
        RecentMessagePreview(ownerName: 'James K.', preview: 'Uploaded the lab results you requested.', timeAgo: '5h ago'),
      ],
    );
  }

  @override
  Future<List<VetPatient>> fetchPatients() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    return [
      VetPatient(
        dogId: 'pet-1',
        dogName: 'Buddy',
        breed: 'Golden Retriever',
        ageFormatted: '3 yrs 2 mos',
        ownerName: 'Alex Taylor',
        lastVisit: now.subtract(const Duration(days: 12)),
        needsFollowUp: true,
        hasCriticalAlert: false,
        allergies: const ['Wheat (mild)'],
        existingConditions: const ['Mild hip dysplasia (monitoring)'],
        currentMedications: const ['Joint Support Chews'],
      ),
      VetPatient(
        dogId: 'pet-2',
        dogName: 'Luna',
        breed: 'German Shepherd',
        ageFormatted: '1 yr 6 mos',
        ownerName: 'Alex Taylor',
        lastVisit: now.subtract(const Duration(days: 40)),
        needsFollowUp: false,
        hasCriticalAlert: true,
        allergies: const [],
        existingConditions: const [],
        currentMedications: const [],
      ),
      VetPatient(
        dogId: 'pet-4',
        dogName: 'Milo',
        breed: 'Beagle',
        ageFormatted: '4 yrs',
        ownerName: 'Priya M.',
        lastVisit: now.subtract(const Duration(days: 5)),
        needsFollowUp: true,
        hasCriticalAlert: false,
        allergies: const ['Chicken protein'],
        existingConditions: const ['Obesity — active weight management'],
        currentMedications: const ['Prescription weight-control diet'],
      ),
      VetPatient(
        dogId: 'pet-5',
        dogName: 'Rocky',
        breed: 'Boxer',
        ageFormatted: '6 yrs',
        ownerName: 'James K.',
        lastVisit: now.subtract(const Duration(days: 90)),
        needsFollowUp: false,
        hasCriticalAlert: false,
        allergies: const [],
        existingConditions: const ['Arthritis'],
        currentMedications: const ['Anti-inflammatory (as needed)'],
      ),
      VetPatient(
        dogId: 'pet-6',
        dogName: 'Bella',
        breed: 'French Bulldog',
        ageFormatted: '2 yrs',
        ownerName: 'Sofia R.',
        lastVisit: now.subtract(const Duration(days: 20)),
        needsFollowUp: false,
        hasCriticalAlert: false,
        allergies: const [],
        existingConditions: const [],
        currentMedications: const [],
      ),
    ];
  }

  @override
  Future<VetReputation> fetchReputation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    return VetReputation(
      averageRating: 4.9,
      totalConsultations: 3120,
      recommendationsAcceptedPercent: 88,
      repeatConsultationPercent: 74,
      reviews: [
        PatientReview(ownerName: 'Alex T.', rating: 5, comment: 'Extremely thorough and explained everything clearly.', date: now.subtract(const Duration(days: 6))),
        PatientReview(ownerName: 'Priya M.', rating: 5, comment: 'Buddy loves her! Great with anxious dogs.', date: now.subtract(const Duration(days: 20))),
        PatientReview(ownerName: 'James K.', rating: 4, comment: 'Very knowledgeable, appointment ran a bit long.', date: now.subtract(const Duration(days: 35))),
      ],
    );
  }

  @override
  Future<Map<String, bool>> fetchAvailability() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Map.unmodifiable(_availability);
  }

  @override
  Future<Map<String, bool>> setAvailability(String day, bool available) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _availability[day] = available;
    return Map.unmodifiable(_availability);
  }
}
