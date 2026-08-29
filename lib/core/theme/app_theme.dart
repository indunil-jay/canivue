import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';

/// App-wide [ThemeData] plus a legacy color/gradient facade.
///
/// [AppColors] (in `core/design_system/tokens`) is the real source of truth
/// for every color in the app. The named constants below exist so the many
/// screens written before the design-system migration keep working and pick
/// up the teal/emerald rebrand automatically; new code should prefer
/// `Theme.of(context).colorScheme` or [AppColors] directly instead of adding
/// more names here.
class AppTheme {
  // Global reactive ThemeMode notifier.
  //
  // Note: this stays a lightweight ValueNotifier rather than a Riverpod
  // provider — it is pure UI chrome state with a single reader (MaterialApp)
  // and toggling it doesn't touch any domain/repository layer. Feature data
  // (dogs, health metrics, predictions, etc.) is modeled with Riverpod
  // providers/repositories instead — see the `canivue-architecture` skill.
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  static bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  static void toggleTheme() {
    themeModeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
  }

  static void setThemeMode(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }

  // -------------------------------------------------------------
  // Legacy color facade — mapped onto the teal/emerald token palette.
  // -------------------------------------------------------------
  static const Color primaryBlue = AppColors.primary;
  static const Color oceanBlue = AppColors.primaryDark;
  static const Color skyBlue = Color(0xFF06B6B0);
  static const Color cyanAccent = AppColors.primaryOnDark;
  static const Color turquoiseAccent = AppColors.primaryLight;
  static const Color indigoAccent = AppColors.intelligence;
  static const Color emeraldAccent = Color(0xFF10B981);
  static const Color darkBlueSurface = AppColors.darkBackground;
  static const Color darkNavyCard = AppColors.darkElevatedSurface;

  // Semantic Accents
  static const Color successGreen = AppColors.success;
  static const Color warningAmber = AppColors.warning;
  static const Color softPink = Color(0xFFEC4899);

  // Gradients (teal/emerald brand system)
  static const LinearGradient primaryGradient = AppColors.primaryGradient;

  static const LinearGradient heroGradient = AppColors.heroGradient;

  static const LinearGradient aquaGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient indigoGradient = AppColors.intelligenceGradient;

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [AppColors.primary, Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleBlueGradient = LinearGradient(
    colors: [Color(0xFFF3FAF9), Color(0xFFE3F3F0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark background gradient (formerly "midnight royal")
  static const LinearGradient midnightBackgroundGradient = LinearGradient(
    colors: [
      AppColors.darkBackground,
      Color(0xFF0F1F1B),
      Color(0xFF123330),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Light background gradient
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFFF8FBFA),
      Color(0xFFF3FAF9),
      Color(0xFFE3F3F0),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Auth Screen Gradients
  static const LinearGradient obsidianAuthGradient = LinearGradient(
    colors: [
      Color(0xFF090D14),
      Color(0xFF0E141E),
      Color(0xFF10201C),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient porcelainAuthGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8FBFA),
      Color(0xFFF1F5F4),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    colors: [
      Color(0x28FFFFFF),
      Color(0x140F766E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGlassCardGradient = LinearGradient(
    colors: [
      Color(0x38FFFFFF),
      Color(0x1A0F766E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // -------------------------------------------------------------
  // LIGHT THEME
  // -------------------------------------------------------------
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      primaryContainer: const Color(0xFFCFEAE6),
      onPrimaryContainer: const Color(0xFF042E29),
      secondary: AppColors.secondary,
      secondaryContainer: const Color(0xFFD7E7EF),
      tertiary: AppColors.intelligence,
      surface: AppColors.lightSurface,
      surfaceContainerHighest: const Color(0xFFF1F5F4),
      outlineVariant: AppColors.lightBorder,
      error: AppColors.error,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: AppTypography.textTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary).titleMedium
            ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F4),
        border: OutlineInputBorder(borderRadius: AppRadius.mdRadius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
        hintStyle: const TextStyle(color: AppColors.lightMutedText),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: const Color(0xFFCFEAE6),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary);
          }
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.lightTextSecondary);
        }),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.lightBorder, space: 1),
    );
  }

  // -------------------------------------------------------------
  // DARK THEME — a true dark theme, not an inverted light theme.
  // -------------------------------------------------------------
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primaryOnDark,
      onPrimary: const Color(0xFF04211D),
      primaryContainer: const Color(0xFF0E3B35),
      onPrimaryContainer: AppColors.primaryOnDark,
      secondary: AppColors.secondaryOnDark,
      secondaryContainer: const Color(0xFF13343F),
      tertiary: AppColors.intelligenceOnDark,
      surface: AppColors.darkSurface,
      surfaceContainerHighest: AppColors.darkElevatedSurface,
      outlineVariant: AppColors.darkBorder,
      error: AppColors.errorOnDark,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: AppTypography.textTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary).titleMedium
            ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryOnDark,
          foregroundColor: const Color(0xFF04211D),
          elevation: 2,
          shadowColor: AppColors.primaryOnDark.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryOnDark,
          side: const BorderSide(color: AppColors.primaryOnDark, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkElevatedSurface,
        border: OutlineInputBorder(borderRadius: AppRadius.mdRadius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: const BorderSide(color: AppColors.primaryOnDark, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
        hintStyle: const TextStyle(color: AppColors.darkMutedText),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: const Color(0xFF0E3B35),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryOnDark);
          }
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.darkTextSecondary);
        }),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder, space: 1),
    );
  }
}
