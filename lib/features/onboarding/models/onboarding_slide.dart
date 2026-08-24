class OnboardingSlide {
  const OnboardingSlide({
    required this.imageAsset,
    required this.badge,
    required this.title,
    required this.description,
  });

  final String imageAsset;
  final String badge;
  final String title;
  final String description;
}

const List<OnboardingSlide> onboardingSlides = [
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_welcome.jpg',
    badge: '🐾 Welcome',
    title: 'All Your Pets,\nOne Loving Home',
    description:
        'Canivue brings every one of your pet\'s details, photos and memories together in a single, beautiful place.',
  ),
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_track.jpg',
    badge: '📊 Track',
    title: 'Monitor Health\n& Activity Daily',
    description:
        'Log vitals, weight, walks and moods so you always know exactly how your best friend is doing.',
  ),
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_records.jpg',
    badge: '💉 Remind',
    title: 'Never Miss a\nVaccination Again',
    description:
        'Smart reminders for vaccines, medication and vet visits keep your pet safe, healthy and on schedule.',
  ),
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_join.jpg',
    badge: '🎉 Join In',
    title: 'Join Thousands of\nHappy Pet Parents',
    description:
        'Create your free Canivue account and start building your pet\'s health story today.',
  ),
];
