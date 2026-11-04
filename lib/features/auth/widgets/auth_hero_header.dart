import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Top Hero Mascot for Canivue Auth Screens.
///
/// Displays the dedicated 3D canine character mascot with gentle idle
/// floating micro-animation, a tilted vibrant backing tile, and a floating pill badge.
class AuthTopMascot extends StatelessWidget {
  const AuthTopMascot({
    super.key,
    required this.imageAsset,
    required this.badgeText,
    required this.badgeEmoji,
    required this.tileColor,
    this.avatarSize = 74.0,
  });

  final String imageAsset;
  final String badgeText;
  final String badgeEmoji;
  final Color tileColor;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: avatarSize + 18,
        height: avatarSize + 14,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Tilted Backing Tile (Signature Onboarding Look)
            Positioned(
              child: Transform.rotate(
                angle: 0.09,
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: tileColor.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Mascot Avatar with Idle Floating Micro-Animation
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(
                      Icons.pets_rounded,
                      size: 34,
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

            // 3. Floating Pill Badge Overlapping Bottom
            Positioned(
              bottom: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(badgeEmoji, style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
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
    );
  }
}
