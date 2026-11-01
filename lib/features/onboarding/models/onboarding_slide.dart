import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';

class OnboardingSlide {
  const OnboardingSlide({
    required this.imageAsset,
    required this.badge,
    required this.stepLabel,
    this.telemetryLabel,
    this.telemetryIcon,
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
  final String? telemetryLabel;
  final IconData? telemetryIcon;
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
  // Slide 1: Welcome & Unified Intelligent Dashboard
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_welcome.jpg',
    badge: 'Intelligent Canine Care',
    stepLabel: '01 / 04',
    telemetryLabel: 'Live Collar Sync',
    telemetryIcon: Icons.sensors_rounded,
    title: 'Your Dog\'s Health,\nAll in One Place',
    description:
        'Unite smart collar activity, symptoms, photos, and medical milestones into a single intelligent canine health sanctuary.',
    icon: Icons.pets_rounded,
    accentColor: AppColors.cyanAccent, // #00F2FE Electric Cyan
    primaryGradient: AppColors.auroraGradient,
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFF030A0E), // Deep Obsidian
        Color(0xFF061622),
        Color(0xFF0A2836),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [
        Color(0x38FFFFFF),
        Color(0x10FFFFFF),
        Color(0x2200F2FE),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    featureTags: ['Dog Profiles', 'Smart Collar Sync', 'Complete Health Record'],
  ),

  // Slide 2: Multimodal AI & Vision Telemetry
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_track.jpg',
    badge: 'Multimodal AI Vision',
    stepLabel: '02 / 04',
    telemetryLabel: 'Vision AI Active',
    telemetryIcon: Icons.center_focus_strong_rounded,
    title: 'Snap, Speak &\nDetect Issues Early',
    description:
        'Photograph a symptom, sync collar motion, and describe changes. Our adaptive neural AI fuses visual cues with telemetry to catch health concerns early.',
    icon: Icons.biotech_rounded,
    accentColor: AppColors.neonMint, // #00E5BE Luminous Mint
    primaryGradient: LinearGradient(
      colors: [
        Color(0xFF00F2FE),
        Color(0xFF00E5BE),
        Color(0xFF10B981),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFF020C0E),
        Color(0xFF041D20),
        Color(0xFF083232),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [
        Color(0x38FFFFFF),
        Color(0x10FFFFFF),
        Color(0x2200E5BE),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    featureTags: ['AI Photo Scanner', 'Telemetry Fusion', 'Early Anomaly Alerts'],
  ),

  // Slide 3: Predictive AI & Disease Progression Engine (Corrected paragraphs & no "98% optimal" chip)
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_records.jpg',
    badge: 'Predictive Health Engine',
    stepLabel: '03 / 04',
    telemetryLabel: null, // Removed "98% optimal index" as requested
    telemetryIcon: null,
    title: 'Know What\'s Coming,\nNot Just What\'s Wrong',
    description:
        'Our Disease Progression & Risk Prediction Engine evaluates breed predisposition, daily activity trends, and vitals to forecast health trajectories with plain-language explanations.',
    icon: Icons.timeline_rounded,
    accentColor: AppColors.royalViolet, // #8B5CF6 Royal Violet
    primaryGradient: LinearGradient(
      colors: [
        Color(0xFF6366F1),
        Color(0xFF8B5CF6),
        Color(0xFFA855F7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFF050718),
        Color(0xFF0E1338),
        Color(0xFF1A1F52),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [
        Color(0x38FFFFFF),
        Color(0x10FFFFFF),
        Color(0x248B5CF6),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    featureTags: ['7-Day Risk Forecast', 'Breed Health Insights', 'Early Warning Alerts'],
  ),

  // Slide 4: Connected Care & Vet Collaboration (Corrected paragraphs & removed "Vet Vault Encrypted" tag)
  OnboardingSlide(
    imageAsset: 'assets/images/onboarding/onboard_join.jpg',
    badge: 'Veterinary Collaboration',
    stepLabel: '04 / 04',
    telemetryLabel: null, // Removed "Vet Vault Encrypted" tag as requested
    telemetryIcon: null,
    title: 'Bridge the Gap to\nTrusted Vet Care',
    description:
        'Generate structured, vet-ready health digests instantly. Connect seamlessly with your veterinary team to share verified biometric timeline data and make confident care decisions together.',
    icon: Icons.auto_awesome_rounded,
    accentColor: Color(0xFF38BDF8), // Sky Blue Accent
    primaryGradient: LinearGradient(
      colors: [
        Color(0xFF0284C7),
        Color(0xFF00F2FE),
        Color(0xFF2DD4BF),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundGradient: LinearGradient(
      colors: [
        Color(0xFF020C14),
        Color(0xFF061D2B),
        Color(0xFF0C3848),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    cardGradient: LinearGradient(
      colors: [
        Color(0x38FFFFFF),
        Color(0x10FFFFFF),
        Color(0x2400F2FE),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    featureTags: ['Vet-Ready Export', 'Clinical Timeline', 'Emergency Care Profile'],
  ),
];
