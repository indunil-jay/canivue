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
    badge: '🐾 Welcome to Canivue',
    stepLabel: '01 / 04',
    title: 'All Your Pets,\nOne Loving Home',
    description:
        'Canivue is your adaptive multimodal AI companion for canine care — uniting photos, smart-collar activity, symptoms and medical history in one secure home.',
    icon: Icons.pets_rounded,
    accentColor: Color(0xFF38BDF8), // Sky Blue Accent
    primaryGradient: LinearGradient(
      colors: [Color(0xFF0066FF), Color(0xFF00B4D8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFF061126), // Midnight Slate Blue
        Color(0xFF0A2540), // Deep Navy
        Color(0xFF003882), // Royal Indigo
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [
        Color(0x28FFFFFF), // 16% Frosted White Glass
        Color(0x140066FF), // Soft Blue tint
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    featureTags: ['Multi-Pet Profiles', 'Real Photo Gallery', 'Instant ID Info'],
  ),
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_track.jpg',
    badge: '🧠 Multimodal AI',
    stepLabel: '02 / 04',
    title: 'Snap, Speak &\nLet AI Fuse the Clues',
    description:
        'Photograph a symptom, sync your smart collar\'s motion data, and describe what you\'re seeing. Our confidence-weighted adaptive fusion engine analyses all three together for a far more reliable read than any single input alone.',
    icon: Icons.biotech_rounded,
    accentColor: Color(0xFF22D3EE), // Cyan / Turquoise Accent
    primaryGradient: LinearGradient(
      colors: [Color(0xFF0284C7), Color(0xFF06B6D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFF041926), // Marine Midnight
        Color(0xFF06334D), // Deep Cyan Teal
        Color(0xFF0369A1), // Ocean Cyan
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [
        Color(0x28FFFFFF),
        Color(0x140284C7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    featureTags: ['Photo Analysis', 'Smart Collar Sync', 'Confidence-Weighted Fusion'],
  ),
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_records.jpg',
    badge: '📈 Risk Forecast',
    stepLabel: '03 / 04',
    title: 'Know What\'s Coming,\nNot Just What\'s Wrong',
    description:
        'Our Disease Progression & Risk Prediction Engine (DPRPE) studies behavioural trends, breed, age and history to forecast a 7-day risk score — with plain-language reasons and clear vet-urgency guidance.',
    icon: Icons.timeline_rounded,
    accentColor: Color(0xFF818CF8), // Periwinkle / Violet Indigo Accent
    primaryGradient: LinearGradient(
      colors: [Color(0xFF4F46E5), Color(0xFF38BDF8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFF0A0F2B), // Deep Space Indigo
        Color(0xFF1E1B4B), // Midnight Violet
        Color(0xFF1D4ED8), // Royal Sapphire
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
    featureTags: ['7-Day Risk Score', 'Explainable Factors', 'Vet Urgency Guidance'],
  ),
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_join.jpg',
    badge: '🎉 Vibrant Community',
    stepLabel: '04 / 04',
    title: 'Join Thousands of\nHappy Pet Parents',
    description:
        'Join pet parents using AI-assisted, explainable insights to catch problems early and bridge the gap to trusted tele-veterinary care.',
    icon: Icons.auto_awesome_rounded,
    accentColor: Color(0xFF34D399), // Emerald Mint Accent
    primaryGradient: LinearGradient(
      colors: [Color(0xFF0066FF), Color(0xFF10B981)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFF051726), // Deep Teal Midnight
        Color(0xFF0B3047), // Deep Teal Slate
        Color(0xFF047857), // Forest Emerald Blue
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
    featureTags: ['100% Free Setup', 'Cloud Protected', 'Emergency ID'],
  ),
];
