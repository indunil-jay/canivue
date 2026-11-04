import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact, Animated Canine Mascot Header for Canivue Auth Screens.
///
/// Designed to fit comfortably on screen without scrolling.
/// Features a dedicated 3D canine mascot with idle floating animation,
/// subtle pill badge, and crisp Plus Jakarta Sans typography.
class AuthHeroHeader extends StatelessWidget {
  const AuthHeroHeader({
    super.key,
    required this.imageAsset,
    required this.badgeText,
    required this.badgeEmoji,
    required this.title,
    required this.subtitle,
    this.badgeBgColor = const Color(0xFFF1F5F9),
    this.titleColor = const Color(0xFF16171B),
    this.subtitleColor = const Color(0xFF64748B),
    this.accentColor = const Color(0xFF10B981),
    this.avatarSize = 68.0,
  });

  final String imageAsset;
  final String badgeText;
  final String badgeEmoji;
  final String title;
  final String subtitle;
  final Color badgeBgColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color accentColor;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compact Mascot Avatar with Idle Gentle Float Animation
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Mascot Frame
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.16),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(
                        Icons.pets_rounded,
                        size: 32,
                        color: Color(0xFF16171B),
                      ),
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .moveY(begin: 0, end: -3.5, duration: 1600.ms, curve: Curves.easeInOut)
                  .animate()
                  .scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(),

              // Floating Pill Badge
              Positioned(
                bottom: -5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(badgeEmoji, style: const TextStyle(fontSize: 10)),
                      const SizedBox(width: 3),
                      Text(
                        badgeText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF16171B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: titleColor,
            letterSpacing: -0.4,
          ),
        ).animate().fadeIn(delay: 60.ms).slideY(begin: 0.08, end: 0),

        const SizedBox(height: 3),

        // Subtitle (Compact 1-line)
        Text(
          subtitle,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: subtitleColor,
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08, end: 0),
      ],
    );
  }
}
