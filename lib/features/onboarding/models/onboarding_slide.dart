import 'package:flutter/material.dart';

class OnboardingSlide {
  const OnboardingSlide({
    required this.imageAsset,
    required this.badge,
    required this.stepLabel,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.primaryGradient,
    required this.backgroundGradient,
    required this.cardGradient,
    required this.featureTags,
  });

  final String imageAsset;
  final String badge;
  final String stepLabel;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final LinearGradient primaryGradient;
  final LinearGradient backgroundGradient;
  final LinearGradient cardGradient;
  final List<String> featureTags;
}

const List<OnboardingSlide> onboardingSlides = [
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_welcome.jpg',
    badge: 'Intelligent Canine Care',
    stepLabel: '01 / 04',
    title: 'Your Dog\'s Health,\nAll in One Place',
    description:
        'Unite smart collar activity, photos, symptoms, and vet records into one intelligent canine dashboard.',
    icon: Icons.pets_rounded,
    accentColor: Color(0xFF2DD4BF), // Bright Teal Accent
    primaryGradient: LinearGradient(
      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFF0A1413),
        Color(0xFF0F1F1B),
        Color(0xFF123330),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [
        Color(0x28FFFFFF),
        Color(0x140F766E),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    featureTags: ['Dog Profiles', 'Smart Collar Sync', 'Health History'],
  ),
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_track.jpg',
    badge: 'Multimodal AI',
    stepLabel: '02 / 04',
    title: 'Snap, Speak &\nDetect Issues Early',
    description:
        'Photograph symptoms and describe changes. Our AI fuses image cues with collar telemetry for early alerts.',
    icon: Icons.biotech_rounded,
    accentColor: Color(0xFF06B6B0), // Teal-Cyan Accent
    primaryGradient: LinearGradient(
      colors: [Color(0xFF0E7490), Color(0xFF06B6B0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFF04191A),
        Color(0xFF0A2E2E),
        Color(0xFF0B4F4A),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [
        Color(0x28FFFFFF),
        Color(0x140E7490),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    featureTags: ['Photo Scanner', 'Telemetry Sync', 'Smart Fusion'],
  ),
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_records.jpg',
    badge: 'Risk Forecast',
    stepLabel: '03 / 04',
    title: '7-Day Forecast &\nClear Vet Guidance',
    description:
        'Predictive models evaluate breed, age, and activity trends to forecast health risks with plain reasons.',
    icon: Icons.timeline_rounded,
    accentColor: Color(0xFFA5B4FC), // Intelligence Indigo Accent
    primaryGradient: LinearGradient(
      colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFF0A0F2B),
        Color(0xFF1E1B4B),
        Color(0xFF1D4ED8),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [
        Color(0x28FFFFFF),
        Color(0x144F46E5),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    featureTags: ['7-Day Risk Score', 'Breed Trends', 'Vet Urgency Guide'],
  ),
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_join.jpg',
    badge: 'Connected Care',
    stepLabel: '04 / 04',
    title: 'Bridge the Gap to\nTrusted Vet Care',
    description:
        'Generate structured, explainable health summaries ready to share with your vet whenever needed.',
    icon: Icons.auto_awesome_rounded,
    accentColor: Color(0xFF34D399), // Emerald Mint Accent
    primaryGradient: LinearGradient(
      colors: [Color(0xFF0F766E), Color(0xFF10B981)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFF051C1A),
        Color(0xFF0B342F),
        Color(0xFF047857),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [
        Color(0x28FFFFFF),
        Color(0x1410B981),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    featureTags: ['Vet-Ready Export', 'Cloud Protected', 'Emergency ID'],
  ),
];
