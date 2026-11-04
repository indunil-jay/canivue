import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pre-configured theme palettes for Canivue Auth screens.
///
/// Allows the authentication screens to match the primary Canivue theme
/// (Deep Sanctuary Teal & Cyan) while also supporting harmonious alternative
/// combinations (Aurora Indigo, Sunlit Amber, Alpine Mint & Coral).
class AuthThemePalette {
  const AuthThemePalette({
    required this.id,
    required this.name,
    required this.badgeEmoji,
    required this.badgeText,
    required this.gradient,
    required this.accentColor,
    required this.highlightColor,
    required this.tileColor,
    required this.buttonAccent,
    required this.darkGradient,
    this.shadowColor = const Color(0xFF022622),
  });

  final String id;
  final String name;
  final String badgeEmoji;
  final String badgeText;
  final LinearGradient gradient;
  final Color accentColor;
  final Color highlightColor;
  final Color tileColor;
  final Color buttonAccent;
  final LinearGradient darkGradient;
  final Color shadowColor;

  /// Global reactive notifier for current auth palette, matching [AppTheme.themeModeNotifier]
  static final ValueNotifier<AuthThemePalette> current =
      ValueNotifier<AuthThemePalette>(AuthThemePalette.sanctuaryTeal);

  /// 1. Sign In: Canivue Sanctuary Teal (Matches core app theme)
  static const sanctuaryTeal = AuthThemePalette(
    id: 'sanctuary_teal',
    name: 'Sanctuary Teal',
    badgeEmoji: '🐶',
    badgeText: 'Canine Sanctuary',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF042F2C),
        Color(0xFF0A4D46),
        Color(0xFF0F766E),
      ],
      stops: [0.0, 0.45, 1.0],
    ),
    darkGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF021B19),
        Color(0xFF052B27),
        Color(0xFF0A3C37),
      ],
    ),
    accentColor: Color(0xFF0F766E),
    highlightColor: Color(0xFF00F2FE),
    tileColor: Color(0xFF14B8A6),
    buttonAccent: Color(0xFF00F2FE),
    shadowColor: Color(0xFF022622),
  );

  /// 2. Sign Up: Sunlit Amber & Terracotta Meadow (Warm Welcome for New Pet Parents)
  static const sunlitAmber = AuthThemePalette(
    id: 'sunlit_amber',
    name: 'Sunlit Amber',
    badgeEmoji: '🐾',
    badgeText: 'New Companion',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF78350F), // Deep Ochre
        Color(0xFFB45309), // Amber Brown
        Color(0xFFD97706), // Warm Honey
      ],
    ),
    darkGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2C1304),
        Color(0xFF451A03),
        Color(0xFF78350F),
      ],
    ),
    accentColor: Color(0xFFD97706),
    highlightColor: Color(0xFFFDE68A),
    tileColor: Color(0xFFF59E0B),
    buttonAccent: Color(0xFFF59E0B),
    shadowColor: Color(0xFF451A03),
  );

  /// 3. Forgot Password: Aurora Indigo & Twilight Periwinkle (Calm, Reassuring)
  static const auroraIndigo = AuthThemePalette(
    id: 'aurora_indigo',
    name: 'Aurora Indigo',
    badgeEmoji: '🔮',
    badgeText: 'Account Recovery',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1E1B4B), // Deep Midnight Indigo
        Color(0xFF312E81), // Royal Violet
        Color(0xFF4338CA), // Electric Iris
      ],
    ),
    darkGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0C0A26),
        Color(0xFF14113D),
        Color(0xFF1E1B4B),
      ],
    ),
    accentColor: Color(0xFF4F46E5),
    highlightColor: Color(0xFFA5B4FC),
    tileColor: Color(0xFF818CF8),
    buttonAccent: Color(0xFF818CF8),
    shadowColor: Color(0xFF0F0E2A),
  );

  /// 4. OTP Verification: Cyber Obsidian & Emerald Shield (Vigilant Protection)
  static const emeraldShield = AuthThemePalette(
    id: 'emerald_shield',
    name: 'Emerald Shield',
    badgeEmoji: '🛡️',
    badgeText: 'Secure Verification',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF064E3B), // Deep Forest Pine
        Color(0xFF047857), // Guard Emerald
        Color(0xFF059669), // Vivid Jade
      ],
    ),
    darkGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF021F17),
        Color(0xFF043327),
        Color(0xFF064E3B),
      ],
    ),
    accentColor: Color(0xFF059669),
    highlightColor: Color(0xFF6EE7B7),
    tileColor: Color(0xFF34D399),
    buttonAccent: Color(0xFF10B981),
    shadowColor: Color(0xFF022C22),
  );

  /// 5. Reset Password: Nordic Cobalt & Sky Azure (Fresh Start & Restored Access)
  static const nordicCobalt = AuthThemePalette(
    id: 'nordic_cobalt',
    name: 'Nordic Cobalt',
    badgeEmoji: '✨',
    badgeText: 'Access Restored',
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF082F49), // Deep Oceanic Slate
        Color(0xFF075985), // Azure Abyss
        Color(0xFF0284C7), // Sky Horizon
      ],
    ),
    darkGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF031522),
        Color(0xFF06253B),
        Color(0xFF082F49),
      ],
    ),
    accentColor: Color(0xFF0284C7),
    highlightColor: Color(0xFF7DD3FC),
    tileColor: Color(0xFF0EA5E9),
    buttonAccent: Color(0xFF38BDF8),
    shadowColor: Color(0xFF031726),
  );

  static const List<AuthThemePalette> presets = [
    sanctuaryTeal,
    sunlitAmber,
    auroraIndigo,
    emeraldShield,
    nordicCobalt,
  ];
}

/// Global provider for the active auth theme palette (synchronized with [AuthThemePalette.current]).
final authThemePaletteProvider = StateProvider<AuthThemePalette>((ref) {
  return AuthThemePalette.current.value;
});
