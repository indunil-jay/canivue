class VaccinationRecord {
  const VaccinationRecord({required this.name, required this.dateGiven, this.nextDueDate});

  final String name;
  final DateTime dateGiven;
  final DateTime? nextDueDate;
}

class MedicationRecord {
  const MedicationRecord({required this.name, required this.dosage, required this.frequency});

  final String name;
  final String dosage;
  final String frequency;
}

class InsuranceInfo {
  const InsuranceInfo({required this.provider, required this.policyNumber, required this.expiryDate});

  final String provider;
  final String policyNumber;
  final DateTime expiryDate;
}

class Pet {
  final String id;
  final String name;
  final String breed;
  final String species; // Dog, Cat, etc.
  final int ageYears;
  final int ageMonths;
  final String gender; // Male, Female
  final double weightKg;
  final String color;
  final String microchipId;
  final String avatarEmoji;
  final String? imagePath;
  final String? assetImagePath;
  final DateTime birthDate;
  final bool isNeutered;
  final String bloodGroup;
  final List<String> allergies;
  final String primaryVet;
  final String specialNotes;
  final List<String> existingConditions;
  final List<VaccinationRecord> vaccinations;
  final List<MedicationRecord> medications;
  final InsuranceInfo? insurance;

  const Pet({
    required this.id,
    required this.name,
    required this.breed,
    this.species = 'Dog',
    required this.ageYears,
    required this.ageMonths,
    required this.gender,
    required this.weightKg,
    this.color = 'Golden',
    this.microchipId = '985141002348123',
    this.avatarEmoji = '🐶',
    this.imagePath,
    this.assetImagePath,
    required this.birthDate,
    this.isNeutered = true,
    this.bloodGroup = 'DEA 1.1+',
    this.allergies = const ['Chicken protein (mild)'],
    this.primaryVet = 'Dr. Sarah Smith (Oakwood Vet)',
    this.specialNotes = 'Very friendly, loves playing fetch, needs daily joint supplements.',
    this.existingConditions = const [],
    this.vaccinations = const [],
    this.medications = const [],
    this.insurance,
  });

  String get ageFormatted {
    if (ageYears > 0 && ageMonths > 0) {
      return '$ageYears yrs $ageMonths mos';
    } else if (ageYears > 0) {
      return '$ageYears yrs';
    } else {
      return '$ageMonths mos';
    }
  }

  Pet copyWith({
    String? id,
    String? name,
    String? breed,
    String? species,
    int? ageYears,
    int? ageMonths,
    String? gender,
    double? weightKg,
    String? color,
    String? microchipId,
    String? avatarEmoji,
    String? imagePath,
    String? assetImagePath,
    DateTime? birthDate,
    bool? isNeutered,
    String? bloodGroup,
    List<String>? allergies,
    String? primaryVet,
    String? specialNotes,
    List<String>? existingConditions,
    List<VaccinationRecord>? vaccinations,
    List<MedicationRecord>? medications,
    InsuranceInfo? insurance,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      species: species ?? this.species,
      ageYears: ageYears ?? this.ageYears,
      ageMonths: ageMonths ?? this.ageMonths,
      gender: gender ?? this.gender,
      weightKg: weightKg ?? this.weightKg,
      color: color ?? this.color,
      microchipId: microchipId ?? this.microchipId,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      imagePath: imagePath ?? this.imagePath,
      assetImagePath: assetImagePath ?? this.assetImagePath,
      birthDate: birthDate ?? this.birthDate,
      isNeutered: isNeutered ?? this.isNeutered,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      primaryVet: primaryVet ?? this.primaryVet,
      specialNotes: specialNotes ?? this.specialNotes,
      existingConditions: existingConditions ?? this.existingConditions,
      vaccinations: vaccinations ?? this.vaccinations,
      medications: medications ?? this.medications,
      insurance: insurance ?? this.insurance,
    );
  }

  static List<Pet> get samplePets => [
        Pet(
          id: 'pet-1',
          name: 'Buddy',
          breed: 'Golden Retriever',
          species: 'Dog',
          ageYears: 3,
          ageMonths: 2,
          gender: 'Male',
          weightKg: 28.5,
          color: 'Golden Honey',
          microchipId: '985141002348123',
          avatarEmoji: '🐕',
          assetImagePath: 'assets/images/pets/luna.jpg',
          birthDate: DateTime(2023, 6, 12),
          isNeutered: true,
          bloodGroup: 'DEA 1.1+',
          allergies: const ['Wheat (mild)'],
          primaryVet: 'Dr. Sarah Jenkins (Bay Area Vet)',
          specialNotes: 'Active and energetic, loves swimming and retriever training.',
          existingConditions: const ['Mild hip dysplasia (monitoring)'],
          vaccinations: [
            VaccinationRecord(name: 'Rabies', dateGiven: DateTime(2025, 6, 1), nextDueDate: DateTime(2026, 6, 1)),
            VaccinationRecord(name: 'DHPP', dateGiven: DateTime(2025, 3, 15), nextDueDate: DateTime(2026, 3, 15)),
          ],
          medications: const [
            MedicationRecord(name: 'Joint Support Chews', dosage: '1 chew', frequency: 'Daily'),
          ],
          insurance: InsuranceInfo(provider: 'PetGuard Plus', policyNumber: 'PG-88213', expiryDate: DateTime(2026, 12, 31)),
        ),
        Pet(
          id: 'pet-2',
          name: 'Luna',
          breed: 'German Shepherd',
          species: 'Dog',
          ageYears: 1,
          ageMonths: 6,
          gender: 'Female',
          weightKg: 24.0,
          color: 'Black & Tan',
          microchipId: '985141009876543',
          avatarEmoji: '🐶',
          assetImagePath: 'assets/images/pets/max.jpg',
          birthDate: DateTime(2025, 2, 20),
          isNeutered: true,
          bloodGroup: 'DEA 1.1-',
          allergies: const ['None reported'],
          primaryVet: 'Dr. Robert Miller (Sunset Animal Clinic)',
          specialNotes: 'Highly intelligent, protective, in intermediate agility training.',
          existingConditions: const [],
          vaccinations: [
            VaccinationRecord(name: 'Rabies', dateGiven: DateTime(2025, 8, 20), nextDueDate: DateTime(2026, 8, 20)),
          ],
          medications: const [],
          insurance: null,
        ),
        Pet(
          id: 'pet-3',
          name: 'Charlie',
          breed: 'French Bulldog',
          species: 'Dog',
          ageYears: 2,
          ageMonths: 0,
          gender: 'Male',
          weightKg: 12.2,
          color: 'Brindle',
          microchipId: '985141005544332',
          avatarEmoji: '🐾',
          assetImagePath: 'assets/images/pets/rocky.jpg',
          birthDate: DateTime(2024, 8, 15),
          isNeutered: true,
          bloodGroup: 'DEA 1.2+',
          allergies: const ['Chicken protein'],
          primaryVet: 'Dr. Sarah Jenkins (Bay Area Vet)',
          specialNotes: 'Prefers cool indoor spaces, sensitive respiratory system.',
          existingConditions: const ['Brachycephalic airway syndrome (mild)'],
          vaccinations: [
            VaccinationRecord(name: 'Rabies', dateGiven: DateTime(2025, 1, 10), nextDueDate: DateTime(2026, 1, 10)),
            VaccinationRecord(name: 'Bordetella', dateGiven: DateTime(2025, 7, 2), nextDueDate: DateTime(2026, 1, 2)),
          ],
          medications: const [],
          insurance: InsuranceInfo(provider: 'Canivue Care', policyNumber: 'CV-40217', expiryDate: DateTime(2026, 6, 30)),
        ),
      ];
}
