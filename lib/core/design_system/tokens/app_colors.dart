/// Canivue color tokens.
///
/// Single source of truth for every color used across the app. Screens and
/// widgets should reference [AppColors] (or the theme's [ColorScheme], which
/// is built from these tokens in `core/theme/app_theme.dart`) rather than
/// hardcoding hex values.
///
/// The palette communicates health, trust and calm intelligence: a deep
/// teal/emerald primary instead of a generic "medical" blue, paired with a
/// true (non-inverted) dark theme.
library;

import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

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

  /// Indigo "intelligence" accent — reserved for AI/prediction surfaces so
  /// AI-driven content reads as visually distinct from routine health data.
  static const Color intelligence = Color(0xFF6366F1);
  static const Color intelligenceOnDark = Color(0xFFA5B4FC);

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
  // Dark mode surfaces — a true dark theme, not an inversion.
  // ---------------------------------------------------------------------
  static const Color darkBackground = Color(0xFF0A1413);
  static const Color darkSurface = Color(0xFF0F1B19);
  static const Color darkElevatedSurface = Color(0xFF152420);
  static const Color darkCard = Color(0xFF152420);
  static const Color darkBorder = Color(0xFF25332F);
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

  // ---------------------------------------------------------------------
  // Chart palette — readable & muted-safe in both themes.
  // ---------------------------------------------------------------------
  static const List<Color> chartSeriesLight = [
    Color(0xFF0F766E), // teal
    Color(0xFF6366F1), // indigo
    Color(0xFFB45309), // amber
    Color(0xFFBE185D), // rose
    Color(0xFF0369A1), // sky
  ];

  static const List<Color> chartSeriesDark = [
    Color(0xFF2DD4BF), // teal
    Color(0xFFA5B4FC), // indigo
    Color(0xFFFBBF24), // amber
    Color(0xFFF472B6), // rose
    Color(0xFF38BDF8), // sky
  ];
}
