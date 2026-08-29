import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale built on Plus Jakarta Sans. Screens should pull from
/// `Theme.of(context).textTheme` (populated from this scale in
/// `core/theme/app_theme.dart`) rather than constructing one-off
/// `GoogleFonts.plusJakartaSans(...)` styles inline.
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(Color primaryText, Color secondaryText) {
    final base = GoogleFonts.plusJakartaSansTextTheme();
    return base
        .copyWith(
          displayLarge: GoogleFonts.plusJakartaSans(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.6),
          displayMedium: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.4),
          headlineLarge: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4),
          headlineMedium: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3),
          titleLarge: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.2),
          titleMedium: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600),
          titleSmall: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
          bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w500, height: 1.4),
          bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4),
          bodySmall: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w400, height: 1.35),
          labelLarge: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.1),
          labelMedium: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
          labelSmall: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        )
        .apply(bodyColor: primaryText, displayColor: primaryText);
  }
}
