import 'package:canivue/features/vets/domain/vet_repository.dart';
import 'package:canivue/features/vets/domain/veterinarian.dart';

class FakeVetRepository implements VetRepository {
  static final List<Veterinarian> _vets = [
    const Veterinarian(
      id: 'vet-1',
      name: 'Dr. Sarah Jenkins',
      initials: 'SJ',
      verified: true,
      specialty: 'Internal Medicine',
      specialties: ['Internal Medicine', 'Preventive Care'],
      experienceYears: 11,
      rating: 4.9,
      reviewCount: 482,
      consultationCount: 3120,
      responseTimeMinutes: 8,
      consultationFeeUsd: 45,
      languages: ['English', 'Spanish'],
      distanceKm: 2.4,
      availableToday: true,
      consultationTypes: [ConsultationType.video, ConsultationType.inPerson],
      bio: 'Dr. Jenkins focuses on preventive care and early detection of chronic conditions in dogs of all breeds.',
      clinics: ['Bay Area Vet'],
      qualifications: ['DVM, UC Davis', 'Certified in Canine Rehabilitation'],
      followUpRatePercent: 92,
      recommendationsAcceptedPercent: 88,
    ),
    const Veterinarian(
      id: 'vet-2',
      name: 'Dr. Robert Miller',
      initials: 'RM',
      verified: true,
      specialty: 'Orthopedics',
      specialties: ['Orthopedics', 'Sports Medicine'],
      experienceYears: 15,
      rating: 4.8,
      reviewCount: 356,
      consultationCount: 2740,
      responseTimeMinutes: 15,
      consultationFeeUsd: 60,
      languages: ['English'],
      distanceKm: 5.1,
      availableToday: false,
      consultationTypes: [ConsultationType.video, ConsultationType.inPerson],
      bio: 'Specializing in joint health, mobility and post-surgical rehabilitation for active and working dogs.',
      clinics: ['Sunset Animal Clinic'],
      qualifications: ['DVM, Cornell University', 'Board-Certified Veterinary Surgeon'],
      followUpRatePercent: 85,
      recommendationsAcceptedPercent: 90,
    ),
    const Veterinarian(
      id: 'vet-3',
      name: 'Dr. Amara Osei',
      initials: 'AO',
      verified: true,
      specialty: 'Dermatology',
      specialties: ['Dermatology', 'Allergy & Immunology'],
      experienceYears: 8,
      rating: 4.7,
      reviewCount: 214,
      consultationCount: 1560,
      responseTimeMinutes: 5,
      consultationFeeUsd: 40,
      languages: ['English', 'French'],
      distanceKm: 1.2,
      availableToday: true,
      consultationTypes: [ConsultationType.video, ConsultationType.chat],
      bio: 'Focused on skin conditions, seasonal allergies and nutrition-related dermatology in dogs.',
      clinics: ['Oakwood Vet'],
      qualifications: ['DVM, Ohio State University'],
      followUpRatePercent: 79,
      recommendationsAcceptedPercent: 83,
    ),
    const Veterinarian(
      id: 'vet-4',
      name: 'Dr. Liam Chen',
      initials: 'LC',
      verified: false,
      specialty: 'General Practice',
      specialties: ['General Practice', 'Nutrition'],
      experienceYears: 4,
      rating: 4.5,
      reviewCount: 68,
      consultationCount: 410,
      responseTimeMinutes: 20,
      consultationFeeUsd: 30,
      languages: ['English', 'Mandarin'],
      distanceKm: 8.7,
      availableToday: true,
      consultationTypes: [ConsultationType.chat, ConsultationType.video],
      bio: 'General wellness, nutrition planning and routine checkups for dogs of every life stage.',
      clinics: ['Canivue Care Network'],
      qualifications: ['DVM, Colorado State University'],
      followUpRatePercent: 70,
      recommendationsAcceptedPercent: 75,
    ),
  ];

  @override
  Future<List<Veterinarian>> search(String query, VetSearchFilters filters) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return _vets.where((vet) {
      final matchesQuery = query.trim().isEmpty ||
          vet.name.toLowerCase().contains(query.toLowerCase()) ||
          vet.specialty.toLowerCase().contains(query.toLowerCase());
      final matchesSpecialty = filters.specialty == null || vet.specialties.contains(filters.specialty);
      final matchesAvailability = !filters.availableTodayOnly || vet.availableToday;
      final matchesType = filters.consultationType == null || vet.consultationTypes.contains(filters.consultationType);
      return matchesQuery && matchesSpecialty && matchesAvailability && matchesType;
    }).toList();
  }

  @override
  Future<Veterinarian> fetchVet(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _vets.firstWhere((vet) => vet.id == id);
  }
}
