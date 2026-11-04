import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Expressive Dog Hero Header for Canivue Auth Screens.
///
/// Features a studio canine portrait, tilted vibrant backing tile,
/// floating playful badge, and energetic typography inspired by the onboarding aesthetic.
class AuthHeroHeader extends StatelessWidget {
  const AuthHeroHeader({
    super.key,
    required this.imageAsset,
    required this.tileColor,
    required this.badgeText,
    required this.badgeEmoji,
    required this.title,
    required this.subtitle,
    this.badgeBgColor = Colors.white,
    this.titleColor = const Color(0xFF16171B),
    this.subtitleColor = const Color(0xFF64748B),
    this.avatarSize = 108.0,
  });

  final String imageAsset;
  final Color tileColor;
  final String badgeText;
  final String badgeEmoji;
  final String title;
  final String subtitle;
  final Color badgeBgColor;
  final Color titleColor;
  final Color subtitleColor;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hero Avatar with Tilted Backing Tile & Floating Badge
        Center(
          child: SizedBox(
            width: avatarSize + 24,
            height: avatarSize + 20,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 1. Tilted Backing Tile (Signature Look)
                Positioned(
                  child: Transform.rotate(
                    angle: 0.09,
                    child: Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        color: tileColor,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: tileColor.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Dog Photo Card in Crisp White Border
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white, width: 3.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22.5),
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(
                          Icons.pets_rounded,
                          size: 40,
                          color: Color(0xFF16171B),
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Floating Pill Badge Overlapping Bottom Right
                Positioned(
                  bottom: -6,
                  right: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.06),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          badgeEmoji,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          badgeText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF16171B),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().scale(
                duration: 480.ms,
                curve: Curves.easeOutBack,
              ).fadeIn(),
        ),

        const SizedBox(height: 18),

        // Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: titleColor,
            letterSpacing: -0.6,
            height: 1.2,
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

        const SizedBox(height: 6),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: subtitleColor,
              height: 1.4,
            ),
          ),
        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }
}
