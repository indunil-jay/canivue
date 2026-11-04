/// Canivue color tokens.
///
/// Single source of truth for every color used across the app. Screens and
/// widgets should reference [AppColors] (or the theme's [ColorScheme], which
/// is built from these tokens in `core/theme/app_theme.dart`) rather than
/// hardcoding hex values.
///
/// The palette communicates health, trust, liquid glassmorphism, and calm intelligence:
/// electric cyan, aurora teal, hyper indigo, and deep obsidian liquid surfaces.
library;

import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // ---------------------------------------------------------------------
  // Modern Warm Pet Care Palette (Reference Aesthetic)
  // ---------------------------------------------------------------------
  /// Fresh mint & sage tones (Images 2 & 4)
  static const Color pastelMint = Color(0xFFE4F4F0);
  static const Color pastelMintSoft = Color(0xFFF2FAF7);
  static const Color mintAccent = Color(0xFF10B981);
  static const Color mintPillBadge = Color(0xFF34D399);

  /// Warm honey & cream tones (Image 1)
  static const Color pastelAmber = Color(0xFFFFF5E4);
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color honeyGolden = Color(0xFFFDCB58);

  /// Soft pastel lilac & blush tones (Image 3)
  static const Color pastelLilac = Color(0xFFF3EFFF);
  static const Color lilacAccent = Color(0xFF7A67EE);
  static const Color softBlush = Color(0xFFFDF2F0);

  /// Sky & cyan pastel tones
  static const Color pastelSky = Color(0xFFEAF4FB);
  static const Color skyAccent = Color(0xFF0284C7);

  /// Signature high-contrast controls
  static const Color charcoalBlack = Color(0xFF181A20);
  static const Color charcoalCard = Color(0xFF22262E);
  static const Color warmCream = Color(0xFFFAF8F5);

  // ---------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------
  /// Deep teal — trust, health, calm intelligence. Primary brand color.
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF0B4F4A);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  /// Brighter teal used as the primary accent against dark surfaces.
  static const Color primaryOnDark = Color(0xFF2DD4BF);

  /// Muted slate-blue secondary — supporting actions, secondary chrome.
  static const Color secondary = Color(0xFF35607A);
  static const Color secondaryOnDark = Color(0xFF7DD3FC);

  /// Indigo "intelligence" accent — reserved for AI/prediction surfaces.
  static const Color intelligence = Color(0xFF6366F1);
  static const Color intelligenceOnDark = Color(0xFFA5B4FC);

  // ---------------------------------------------------------------------
  // Liquid Glass & Aurora Chromatic Accents
  // ---------------------------------------------------------------------
  /// High-voltage electric cyan flare — vital telemetry & specular highlights.
  static const Color cyanAccent = Color(0xFF00F2FE);

  /// Luminous neon mint — vital signs active state.
  static const Color neonMint = Color(0xFF00E5BE);

  /// Electric indigo — predictive neural diagnostics.
  static const Color electricIndigo = Color(0xFF6366F1);

  /// Royal orchid violet — secondary chromatic refraction.
  static const Color royalViolet = Color(0xFF8B5CF6);

  /// Liquid glass frosted white overlay.
  static const Color glassSurface = Color(0x18FFFFFF);
  static const Color glassSurfaceElevated = Color(0x24FFFFFF);
  static const Color glassBorder = Color(0x4000F2FE);

  // ---------------------------------------------------------------------
  // Semantic
  // ---------------------------------------------------------------------
  static const Color success = Color(0xFF16A34A);
  static const Color successOnDark = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningOnDark = Color(0xFFFBBF24);
  static const Color error = Color(0xFFDC2626);
  static const Color errorOnDark = Color(0xFFF87171);
  static const Color info = Color(0xFF0369A1);
  static const Color infoOnDark = Color(0xFF38BDF8);

  // ---------------------------------------------------------------------
  // Light mode surfaces
  // ---------------------------------------------------------------------
  static const Color lightBackground = Color(0xFFF6FAF9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightElevatedSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE1E8E6);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightMutedText = Color(0xFF8B9A97);

  // ---------------------------------------------------------------------
  // Dark mode surfaces — deep obsidian liquid space.
  // ---------------------------------------------------------------------
  static const Color darkBackground = Color(0xFF050E14);
  static const Color darkSurface = Color(0xFF091720);
  static const Color darkElevatedSurface = Color(0xFF0F222E);
  static const Color darkCard = Color(0xFF0F222E);
  static const Color darkBorder = Color(0xFF1A3545);
  static const Color darkTextPrimary = Color(0xFFF1F5F4);
  static const Color darkTextSecondary = Color(0xFFB9C7C3);
  static const Color darkMutedText = Color(0xFF77857F);

  // ---------------------------------------------------------------------
  // Gradients
  // ---------------------------------------------------------------------
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0B4F4A), Color(0xFF0F766E), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient intelligenceGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF818CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkHeroGradient = LinearGradient(
    colors: [Color(0xFF0C2420), Color(0xFF0F1B19), Color(0xFF0A1413)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Multi-stop Aurora Gradient: Electric Cyan -> Aquamarine -> Indigo -> Violet
  static const LinearGradient auroraGradient = LinearGradient(
    colors: [
      Color(0xFF00F2FE),
      Color(0xFF00D2C4),
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
    ],
    stops: [0.0, 0.32, 0.72, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Liquid Glass Frosted Surface Gradient
  static const LinearGradient liquidGlassGradient = LinearGradient(
    colors: [
      Color(0x33FFFFFF), // Crisp top-left specular bounce
      Color(0x0FFFFFFF), // Translucent body
      Color(0x1A00F2FE), // Cyan fluid depth
      Color(0x286366F1), // Subtle chromatic floor
    ],
    stops: [0.0, 0.45, 0.8, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Iridescent Liquid Glass Border Gradient
  static const LinearGradient liquidGlassBorderGradient = LinearGradient(
    colors: [
      Color(0xCC00F2FE), // Vibrant specular rim
      Color(0x60FFFFFF),
      Color(0x308B5CF6),
      Color(0x996366F1), // Prismatic edge
    ],
    stops: [0.0, 0.28, 0.68, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Biometric Wave Pulse Gradient
  static const LinearGradient biometricPulseGradient = LinearGradient(
    colors: [
      Color(0xFF00F2FE),
      Color(0xFF38BDF8),
      Color(0xFF818CF8),
      Color(0xFF8B5CF6),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ---------------------------------------------------------------------
  // Chart palette
  // ---------------------------------------------------------------------
  static const List<Color> chartSeriesLight = [
    Color(0xFF0F766E),
    Color(0xFF6366F1),
    Color(0xFFB45309),
    Color(0xFFBE185D),
    Color(0xFF0369A1),
  ];

  static const List<Color> chartSeriesDark = [
    Color(0xFF2DD4BF),
    Color(0xFFA5B4FC),
    Color(0xFFFBBF24),
    Color(0xFFF472B6),
    Color(0xFF38BDF8),
  ];
}
