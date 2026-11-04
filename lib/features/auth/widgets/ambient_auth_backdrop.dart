import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:canivue/core/widgets/canivue_paw_bone_logo.dart';

/// Ambient Theme-Blended Backdrop for Canivue Auth Screens.
///
/// Implements:
/// - Full-bleed multi-tone gradient background blending with the theme
/// - Subtle watermark paw silhouettes (matching onboarding screen aesthetics)
/// - `ambient-section-particles`: Lightweight ambient floating micro-particles
///   with reduced-motion awareness via `MediaQuery.disableAnimations`
/// - `container-lines`: Subtle vertical alignment guide lines with corner-square accents
class AmbientAuthBackdrop extends StatefulWidget {
  const AmbientAuthBackdrop({
    super.key,
    required this.gradient,
    required this.accentColor,
    required this.child,
    this.showBack = false,
    this.onBack,
    this.trailingAction,
    this.watermarkOpacity = 0.07,
  });

  final LinearGradient gradient;
  final Color accentColor;
  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailingAction;
  final double watermarkOpacity;

  @override
  State<AmbientAuthBackdrop> createState() => _AmbientAuthBackdropState();
}

class _AmbientAuthBackdropState extends State<AmbientAuthBackdrop>
    with SingleTickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topPadding = MediaQuery.paddingOf(context).top;
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    // In dark mode, blend into deep luxury tones
    final effectiveGradient = isDark
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.gradient.colors.first.withValues(alpha: 0.35),
              const Color(0xFF16171B),
              const Color(0xFF0F1115),
            ],
          )
        : widget.gradient;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1115) : Colors.white,
      body: Stack(
        children: [
          // 1. Full-Bleed Radiant Gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: effectiveGradient),
            ),
          ),

          // 2. Watermark Paw & Bone Silhouettes (Signature Onboarding Look)
          Positioned(
            top: topPadding + 20,
            right: -35,
            child: IgnorePointer(
              child: Opacity(
                opacity: widget.watermarkOpacity,
                child: Transform.rotate(
                  angle: 0.35,
                  child: CanivuePawBoneLogo(
                    size: 210,
                    color: isDark ? Colors.white : const Color(0xFF16171B),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 160,
            left: -40,
            child: IgnorePointer(
              child: Opacity(
                opacity: widget.watermarkOpacity * 0.85,
                child: Transform.rotate(
                  angle: -0.28,
                  child: CanivuePawBoneLogo(
                    size: 190,
                    color: isDark ? Colors.white : const Color(0xFF16171B),
                  ),
                ),
              ),
            ),
          ),

          // 3. Ambient Section Floating Micro-Particles
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _AmbientParticlesPainter(
                      progress: disableAnimations ? 0.0 : _particleController.value,
                      accentColor: widget.accentColor,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. Subtle Container Lines with Corner Squares (container-lines skill)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ContainerLinesPainter(
                  lineColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  squareColor: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : widget.accentColor.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),

          // 5. Main Content Shell
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button or Brand Identity
                      if (widget.showBack)
                        _AppleGlassIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          isDark: isDark,
                          onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
                        )
                      else
                        // Brand Logo + Title
                        CanivuePawBoneLogo(
                          size: 30,
                          showText: true,
                          subtitle: 'CANINE SANCTUARY',
                          color: isDark ? Colors.white : const Color(0xFF16171B),
                          textColor: isDark ? Colors.white : const Color(0xFF16171B),
                          badgeColor: widget.accentColor,
                        ),

                      // Optional Trailing Action (e.g. Help / Close / Skip)
                      if (widget.trailingAction != null)
                        widget.trailingAction!
                      else if (widget.showBack)
                        CanivuePawBoneLogo(
                          size: 26,
                          showText: false,
                          color: isDark ? Colors.white : const Color(0xFF16171B),
                        )
                      else
                        const SizedBox(width: 32),
                    ],
                  ),
                ),

                // Screen Body
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Frosted Glass Circle Button with 120ms Apple Press Scale
class _AppleGlassIconButton extends StatefulWidget {
  const _AppleGlassIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_AppleGlassIconButton> createState() => _AppleGlassIconButtonState();
}

class _AppleGlassIconButtonState extends State<_AppleGlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.85),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: widget.isDark ? Colors.white : const Color(0xFF16171B),
          ),
        ),
      ),
    );
  }
}

/// Ambient micro-particle atmospheric painter (ambient-section-particles skill)
class _AmbientParticlesPainter extends CustomPainter {
  _AmbientParticlesPainter({
    required this.progress,
    required this.accentColor,
    required this.isDark,
  });

  final double progress;
  final Color accentColor;
  final bool isDark;

  // Fixed deterministic seeds for gentle floating sparkles and dots
  static final List<Offset> _baseOffsets = [
    const Offset(0.12, 0.14),
    const Offset(0.85, 0.18),
    const Offset(0.24, 0.28),
    const Offset(0.76, 0.32),
    const Offset(0.08, 0.40),
    const Offset(0.92, 0.44),
    const Offset(0.35, 0.12),
    const Offset(0.65, 0.22),
    const Offset(0.18, 0.52),
    const Offset(0.82, 0.56),
    const Offset(0.48, 0.26),
    const Offset(0.55, 0.38),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _baseOffsets.length; i++) {
      final base = _baseOffsets[i];
      // Slow rhythmic sway with sinusoidal offset
      final swayPhase = (progress * 2 * math.pi) + (i * 0.8);
      final dx = (base.dx * size.width) + (math.sin(swayPhase) * 6.0);
      final dy = (base.dy * size.height) + (math.cos(swayPhase * 0.7) * 8.0);

      final radius = (i % 3 == 0) ? 2.6 : 1.8;
      final opacity = 0.08 + (math.sin(swayPhase * 1.2).abs() * 0.12);

      particlePaint.color = (i % 2 == 0 ? accentColor : (isDark ? Colors.white : const Color(0xFF16171B)))
          .withValues(alpha: opacity.clamp(0.04, 0.22));

      canvas.drawCircle(Offset(dx, dy), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isDark != isDark;
  }
}

/// Guide lines with corner squares (container-lines skill)
class _ContainerLinesPainter extends CustomPainter {
  _ContainerLinesPainter({
    required this.lineColor,
    required this.squareColor,
  });

  final Color lineColor;
  final Color squareColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final squarePaint = Paint()
      ..color = squareColor
      ..style = PaintingStyle.fill;

    const margin = 16.0;
    final left = margin;
    final right = size.width - margin;

    // Draw thin vertical framing guides
    canvas.drawLine(Offset(left, 0), Offset(left, size.height), linePaint);
    canvas.drawLine(Offset(right, 0), Offset(right, size.height), linePaint);

    // Draw small 4px corner accents
    const squareSize = 4.0;
    const half = squareSize / 2;

    // Top-left and Top-right corner squares
    canvas.drawRect(Rect.fromLTWH(left - half, 80 - half, squareSize, squareSize), squarePaint);
    canvas.drawRect(Rect.fromLTWH(right - half, 80 - half, squareSize, squareSize), squarePaint);
  }

  @override
  bool shouldRepaint(covariant _ContainerLinesPainter oldDelegate) => false;
}
