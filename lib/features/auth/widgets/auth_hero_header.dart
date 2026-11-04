import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Large, Clean Hero Real Dog Mascot for Canivue Auth Screens.
///
/// Implements `anatomy`, `anatomy-asset`, and `apple-design`:
/// - Renders real dog cutouts sitting directly on the green sanctuary background
/// - Zero white background box, zero white tile, zero borders
/// - Realistic soft ground contact shadow anchoring paws to the green surface
/// - Calming Apple-style idle micro-float motion respecting `MediaQuery.disableAnimations`
class AuthTopMascot extends StatelessWidget {
  const AuthTopMascot({
    super.key,
    required this.imageAsset,
    this.shadowColor,
    this.tileColor = const Color(0xFFF59E0B),
    this.avatarSize = 165.0,
    this.badgeText,
    this.badgeEmoji,
    this.showTelemetryHud = false,
    this.telemetryAccent,
    this.telemetryHighlight,
  });

  final String imageAsset;
  final Color? shadowColor;
  final Color tileColor;
  final double avatarSize;

  // Optional legacy parameters kept for call-site compatibility
  final String? badgeText;
  final String? badgeEmoji;
  final bool showTelemetryHud;
  final Color? telemetryAccent;
  final Color? telemetryHighlight;

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    Widget dogImage = Image.asset(
      imageAsset,
      width: avatarSize,
      height: avatarSize,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(
        Icons.pets_rounded,
        size: avatarSize * 0.45,
        color: Colors.white70,
      ),
    );

    if (!disableAnimations) {
      dogImage = dogImage
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .moveY(begin: 0, end: -4.5, duration: 2400.ms, curve: Curves.easeInOut)
          .animate()
          .scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1, 1),
            duration: 400.ms,
            curve: Curves.easeOutBack,
          )
          .fadeIn(duration: 350.ms);
    }

    return Center(
      child: SizedBox(
        width: avatarSize,
        height: avatarSize + 16,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Ground Contact Shadow directly on the green sanctuary surface
            Positioned(
              bottom: 2,
              child: Container(
                width: avatarSize * 0.72,
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(avatarSize * 0.72, 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (shadowColor ?? const Color(0xFF022622))
                          .withValues(alpha: 0.55),
                      blurRadius: 18,
                      spreadRadius: 3,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Real Dog Cutout Sitting Directly on Green Background (No White Box)
            Positioned(
              bottom: 6,
              child: dogImage,
            ),
          ],
        ),
      ),
    );
  }
}
