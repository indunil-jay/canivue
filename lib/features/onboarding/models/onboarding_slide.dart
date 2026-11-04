import 'package:flutter/material.dart';

class OnboardingSlide {
  const OnboardingSlide({
    required this.imageAsset,
    required this.badge,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.backgroundGradient,
    required this.tileBackingColor,
    this.badgeEmoji = '🐶',
  });

  final String imageAsset;
  final String badge;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final LinearGradient backgroundGradient;
  final Color tileBackingColor;
  final String badgeEmoji;
}

const List<OnboardingSlide> onboardingSlides = [
  // Slide 1: Intelligent Canine Sanctuary (Image 1 Warm Amber & Violet style)
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/dog_slide_1.jpg',
    badge: 'Intelligent Canine Care',
    badgeEmoji: '🐶',
    title: 'Your Dog\'s Health,\nAll in One Place',
    description:
        'Sync collar activity, symptom logs, and medical milestones into a single canine sanctuary.',
    icon: Icons.pets_rounded,
    accentColor: Color(0xFFF59E0B), // Warm Amber
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFFFFAE33), // Radiant Sunshine Amber
        Color(0xFFFFCC33),
        Color(0xFFFFF3D6),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    tileBackingColor: Color(0xFF6B66FF), // Contrast Violet Card (Image 1)
  ),

  // Slide 2: Multimodal AI & Vision Telemetry (Image 2 Teal Mint & Tangerine style)
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/dog_slide_2.jpg',
    badge: 'Multimodal AI Vision',
    badgeEmoji: '🔍',
    title: 'Snap, Speak &\nDetect Issues Early',
    description:
        'Photograph symptoms and fuse motion telemetry to catch canine health concerns early.',
    icon: Icons.biotech_rounded,
    accentColor: Color(0xFF10B981), // Emerald Mint
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFF4ECDC4), // Vibrant Teal Mint
        Color(0xFF68D8D6),
        Color(0xFFE0FAF7),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    tileBackingColor: Color(0xFFFF9F1C), // Tangerine Orange Card (Image 2)
  ),

  // Slide 3: Predictive AI & Disease Progression Engine (Image 3 Violet & Butter Yellow style)
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/dog_slide_3.jpg',
    badge: 'Predictive Health Engine',
    badgeEmoji: '🔮',
    title: 'Know What\'s Coming,\nNot Just What\'s Wrong',
    description:
        'Evaluate breed risks and vitals to forecast health trajectories before symptoms emerge.',
    icon: Icons.timeline_rounded,
    accentColor: Color(0xFF8B5CF6), // Royal Violet
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFFC77DFF), // Dreamy Violet
        Color(0xFFE0AAFF),
        Color(0xFFFAF5FF),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    tileBackingColor: Color(0xFFFFD166), // Butter Yellow Card (Image 3)
  ),

  // Slide 4: Connected Care & Vet Collaboration (Image 4 Fresh Seafoam & Coral style)
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/dog_slide_4.jpg',
    badge: 'Veterinary Collaboration',
    badgeEmoji: '🩺',
    title: 'Bridge the Gap to\nTrusted Vet Care',
    description:
        'Generate structured health digests and share verified biometric history with your vet.',
    icon: Icons.auto_awesome_rounded,
    accentColor: Color(0xFF06B6D4), // Cyan Sky Blue
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFF56CFE1), // Fresh Seafoam
        Color(0xFF72EFDD),
        Color(0xFFE8FCFA),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    tileBackingColor: Color(0xFFFF6B6B), // Coral Pink Card (Image 4)
  ),
];
