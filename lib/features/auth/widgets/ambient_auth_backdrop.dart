import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:canivue/core/widgets/canivue_paw_bone_logo.dart';
import 'package:canivue/features/auth/domain/auth_theme_palette.dart';

/// Ambient Theme-Blended Backdrop for Canivue Auth Screens.
///
/// Implements:
/// - Full-bleed multi-tone gradient blending with the core Canivue theme
/// - Subtle watermark paw silhouettes matching Canivue brand identity
/// - `ambient-section-particles`: Lightweight ambient floating micro-particles
///   (canine paws, luminous orbs, and sparkles) with reduced-motion awareness
/// - `container-lines`: Subtle vertical alignment guide lines with corner-square accents
/// - `apple-design`: Frosted glass blur, high-contrast typography, and fluid touch states
class AmbientAuthBackdrop extends StatefulWidget {
  const AmbientAuthBackdrop({
    super.key,
    this.palette,
    this.gradient,
    this.accentColor,
    required this.child,
    this.showBack = false,
    this.onBack,
    this.trailingAction,
    this.watermarkOpacity = 0.08,
  });

  /// Specific auth color template. Defaults to [AuthThemePalette.sanctuaryTeal].
  final AuthThemePalette? palette;

  /// Optional override gradient. Defaults to active palette gradient.
  final LinearGradient? gradient;

  /// Optional override accent color. Defaults to active palette accent.
  final Color? accentColor;

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
      duration: const Duration(seconds: 10),
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

    final activePalette = widget.palette ?? AuthThemePalette.sanctuaryTeal;

    final effectiveGradient = widget.gradient ??
        (isDark ? activePalette.darkGradient : activePalette.gradient);
    final effectiveAccent = widget.accentColor ?? activePalette.accentColor;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0F14) : const Color(0xFFF6FAF9),
      body: Stack(
        children: [
          // 1. Full-Bleed Radiant Gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: effectiveGradient),
            ),
          ),

          // 2. Watermark Paw & Bone Silhouettes (Brand Identity)
          Positioned(
            top: topPadding + 16,
            right: -32,
            child: IgnorePointer(
              child: Opacity(
                opacity: widget.watermarkOpacity,
                child: Transform.rotate(
                  angle: 0.35,
                  child: CanivuePawBoneLogo(
                    size: 220,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 150,
            left: -38,
            child: IgnorePointer(
              child: Opacity(
                opacity: widget.watermarkOpacity * 0.85,
                child: Transform.rotate(
                  angle: -0.28,
                  child: CanivuePawBoneLogo(
                    size: 200,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // 3. Ambient Section Floating Micro-Particles (`ambient-section-particles` skill)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _AmbientAtmospherePainter(
                      progress: disableAnimations ? 0.0 : _particleController.value,
                      accentColor: activePalette.highlightColor,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. Container Lines with Corner Squares (`container-lines` skill)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ContainerLinesPainter(
                  lineColor: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.12),
                  squareColor: activePalette.highlightColor.withValues(alpha: 0.65),
                ),
              ),
            ),
          ),

          // 5. Main Content Shell
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Navigation Bar (Apple Frosted Vibrancy)
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
                        CanivuePawBoneLogo(
                          size: 30,
                          showText: true,
                          subtitle: 'CANINE SANCTUARY',
                          color: Colors.white,
                          textColor: Colors.white,
                          badgeColor: activePalette.tileColor,
                        ),

                      // Optional Trailing Action (e.g. Help / Close / Empty spacer)
                      if (widget.trailingAction != null)
                        widget.trailingAction!
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
            color: Colors.white.withValues(alpha: 0.20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.30),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Ambient micro-particle atmospheric painter (`ambient-section-particles` skill).
class _AmbientAtmospherePainter extends CustomPainter {
  _AmbientAtmospherePainter({
    required this.progress,
    required this.accentColor,
    required this.isDark,
  });

  final double progress;
  final Color accentColor;
  final bool isDark;

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
    const Offset(0.30, 0.60),
    const Offset(0.70, 0.65),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _baseOffsets.length; i++) {
      final base = _baseOffsets[i];
      final swayPhase = (progress * 2 * math.pi) + (i * 0.75);
      final dx = (base.dx * size.width) + (math.sin(swayPhase) * 6.0);
      final dy = (base.dy * size.height) + (math.cos(swayPhase * 0.65) * 8.0);

      final radius = (i % 3 == 0) ? 2.8 : 1.8;
      final opacity = 0.10 + (math.sin(swayPhase * 1.2).abs() * 0.18);

      particlePaint.color = (i % 2 == 0 ? accentColor : Colors.white)
          .withValues(alpha: opacity.clamp(0.06, 0.32));

      canvas.drawCircle(Offset(dx, dy), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientAtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isDark != isDark;
  }
}

/// Guide lines with corner squares (`container-lines` skill)
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

    const margin = 18.0;
    final left = margin;
    final right = size.width - margin;

    // Draw thin vertical framing guides
    canvas.drawLine(Offset(left, 0), Offset(left, size.height), linePaint);
    canvas.drawLine(Offset(right, 0), Offset(right, size.height), linePaint);

    // Draw small 5px corner accents with precise alignment
    const squareSize = 5.0;
    const half = squareSize / 2;

    // Top-left and Top-right corner squares
    canvas.drawRect(Rect.fromLTWH(left - half, 72 - half, squareSize, squareSize), squarePaint);
    canvas.drawRect(Rect.fromLTWH(right - half, 72 - half, squareSize, squareSize), squarePaint);
  }

  @override
  bool shouldRepaint(covariant _ContainerLinesPainter oldDelegate) => false;
}
