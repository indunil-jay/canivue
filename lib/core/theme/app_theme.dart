import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core Brand Blues
  static const Color primaryBlue = Color(0xFF0066FF);
  static const Color oceanBlue = Color(0xFF0052CC);
  static const Color skyBlue = Color(0xFF00B4D8);
  static const Color cyanAccent = Color(0xFF38BDF8);
  static const Color turquoiseAccent = Color(0xFF22D3EE);
  static const Color indigoAccent = Color(0xFF818CF8);
  static const Color emeraldAccent = Color(0xFF34D399);
  static const Color darkBlueSurface = Color(0xFF061126);
  static const Color darkNavyCard = Color(0xFF0A2540);

  // Semantic Accents
  static const Color successGreen = Color(0xFF16A34A);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color softPink = Color(0xFFEC4899);

  // Modern Slider & App Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0066FF), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0040AA), Color(0xFF0066FF), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aquaGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient indigoGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF0066FF), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleBlueGradient = LinearGradient(
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient midnightBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF061126), // Midnight Slate Blue
      Color(0xFF0A2540), // Deep Navy
      Color(0xFF003882), // Royal Indigo
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient oceanBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF041926), // Marine Midnight
      Color(0xFF06334D), // Deep Cyan Teal
      Color(0xFF0369A1), // Ocean Cyan
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    colors: [
      Color(0x28FFFFFF), // 16% Frosted White Glass
      Color(0x140066FF), // Soft Blue tint
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGlassCardGradient = LinearGradient(
    colors: [
      Color(0x38FFFFFF),
      Color(0x1A0066FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration get glassCardDecoration => BoxDecoration(
        gradient: glassCardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD6E4FF),
      onPrimaryContainer: const Color(0xFF001B3F),
      secondary: const Color(0xFF00B4D8),
      secondaryContainer: const Color(0xFFCBE6FF),
      tertiary: const Color(0xFF06B6D4),
      surface: Colors.white,
      surfaceContainerHighest: const Color(0xFFF0F4F9),
      outlineVariant: const Color(0xFFD3E0EA),
      brightness: Brightness.light,
    );

    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      textTheme: baseTextTheme.apply(
        bodyColor: const Color(0xFF0F172A),
        displayColor: const Color(0xFF0F172A),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryBlue.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: Color(0xFF0066FF), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFD6E4FF),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          );
        }),
      ),
    );
  }
}
