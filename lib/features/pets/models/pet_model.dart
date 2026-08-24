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
  final DateTime birthDate;
  final bool isNeutered;
  final String bloodGroup;
  final List<String> allergies;
  final String primaryVet;
  final String specialNotes;

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
    required this.birthDate,
    this.isNeutered = true,
    this.bloodGroup = 'DEA 1.1+',
    this.allergies = const ['Chicken protein (mild)'],
    this.primaryVet = 'Dr. Sarah Smith (Oakwood Vet)',
    this.specialNotes = 'Very friendly, loves playing fetch, needs daily joint supplements.',
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
    DateTime? birthDate,
    bool? isNeutered,
    String? bloodGroup,
    List<String>? allergies,
    String? primaryVet,
    String? specialNotes,
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
      birthDate: birthDate ?? this.birthDate,
      isNeutered: isNeutered ?? this.isNeutered,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      primaryVet: primaryVet ?? this.primaryVet,
      specialNotes: specialNotes ?? this.specialNotes,
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
          birthDate: DateTime(2023, 6, 12),
          isNeutered: true,
          bloodGroup: 'DEA 1.1+',
          allergies: const ['Wheat (mild)'],
          primaryVet: 'Dr. Sarah Jenkins (Bay Area Vet)',
          specialNotes: 'Active and energetic, loves swimming and retriever training.',
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
          birthDate: DateTime(2025, 2, 20),
          isNeutered: true,
          bloodGroup: 'DEA 1.1-',
          allergies: const ['None reported'],
          primaryVet: 'Dr. Robert Miller (Sunset Animal Clinic)',
          specialNotes: 'Highly intelligent, protective, in intermediate agility training.',
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
          birthDate: DateTime(2024, 8, 15),
          isNeutered: true,
          bloodGroup: 'DEA 1.2+',
          allergies: const ['Chicken protein'],
          primaryVet: 'Dr. Sarah Jenkins (Bay Area Vet)',
          specialNotes: 'Prefers cool indoor spaces, sensitive respiratory system.',
        ),
      ];
}

