import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:canivue/core/widgets/canivue_paw_bone_logo.dart';

/// Ambient backdrop offering soft paw watermarks and restrained ambient particle drift.
///
/// Implements skills:
/// - `ambient-section-particles`: restrained subtle floating motes that pause on reduced motion
/// - `anatomy-asset`: branded canine paw-bone silhouettes
/// - `accessible-animation`: fully respects `MediaQuery.disableAnimations`
class AmbientPawBackdrop extends StatefulWidget {
  const AmbientPawBackdrop({
    super.key,
    required this.child,
    this.showContainerLines = false,
    this.showPawWatermarks = true,
    this.showParticles = true,
    this.particleCount = 6,
  });

  final Widget child;
  final bool showContainerLines;
  final bool showPawWatermarks;
  final bool showParticles;
  final int particleCount;

  @override
  State<AmbientPawBackdrop> createState() => _AmbientPawBackdropState();
}

class _AmbientPawBackdropState extends State<AmbientPawBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final watermarkColor = isDark
        ? const Color(0x0FFFFFFF)
        : const Color(0x0C181A20);

    return Stack(
      children: [
        // 1. Watermark Paws in corners
        if (widget.showPawWatermarks) ...[
          Positioned(
            top: -24,
            right: -30,
            child: IgnorePointer(
              child: Opacity(
                opacity: isDark ? 0.05 : 0.045,
                child: Transform.rotate(
                  angle: 0.28,
                  child: CanivuePawBoneLogo(
                    size: 240,
                    color: watermarkColor,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -40,
            child: IgnorePointer(
              child: Opacity(
                opacity: isDark ? 0.04 : 0.035,
                child: Transform.rotate(
                  angle: -0.32,
                  child: CanivuePawBoneLogo(
                    size: 200,
                    color: watermarkColor,
                  ),
                ),
              ),
            ),
          ),
        ],

        // 2. Ambient drifting particles (respects reduced motion)
        if (widget.showParticles && !reduceMotion)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _RestrainedParticlesPainter(
                      progress: _controller.value,
                      isDark: isDark,
                      count: widget.particleCount,
                    ),
                  );
                },
              ),
            ),
          ),

        // 3. Main Foreground Content
        widget.child,
      ],
    );
  }
}

class _RestrainedParticlesPainter extends CustomPainter {
  const _RestrainedParticlesPainter({
    required this.progress,
    required this.isDark,
    required this.count,
  });

  final double progress;
  final bool isDark;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final seed = i * 1.61803398875;
      final speed = 0.5 + (i % 3) * 0.25;
      final t = (progress * speed + seed) % 1.0;

      final x = ((seed * 137.5) % size.width) + math.sin(t * math.pi * 2 + seed) * 16;
      final y = size.height * (1.0 - t);

      final radius = 1.5 + (i % 3) * 1.0;
      final alpha = (math.sin(t * math.pi) * (isDark ? 0.18 : 0.12)).clamp(0.0, 0.25);

      final color = i % 2 == 0
          ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF10B981))
          : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B));

      paint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RestrainedParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
