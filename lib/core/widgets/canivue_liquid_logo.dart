import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';

/// Modern Liquid Glass Logo for Canivue.
///
/// Implements [liquid-glass-design] and [flutter-ui-design]:
/// - Realtime backdrop blur with frosted glassmorphism
/// - Multi-stop iridescent border refraction
/// - Aurora biometrics (Electric Cyan -> Luminous Mint -> Electric Indigo -> Violet)
/// - Hardware-accelerated custom vector canine insignia
class CanivueLiquidLogo extends StatefulWidget {
  const CanivueLiquidLogo({
    super.key,
    this.size = 80.0,
    this.showGlow = true,
    this.enableAnimation = true,
    this.onTap,
  });

  /// The dimension (width and height) of the logo squircle.
  final double size;

  /// Whether to render the ambient volumetric aurora glow behind the glass.
  final bool showGlow;

  /// Whether to play subtle liquid shimmer & aura animations.
  final bool enableAnimation;

  /// Optional tap callback for interactive preview on landing screens.
  final VoidCallback? onTap;

  @override
  State<CanivueLiquidLogo> createState() => _CanivueLiquidLogoState();
}

class _CanivueLiquidLogoState extends State<CanivueLiquidLogo>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final radius = size * 0.28;

    Widget logoContent = GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Volumetric Aurora Ambient Glow (Underneath Glass)
              if (widget.showGlow)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyanAccent.withValues(alpha: 0.35),
                          blurRadius: size * 0.35,
                          spreadRadius: size * 0.04,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: AppColors.royalViolet.withValues(alpha: 0.28),
                          blurRadius: size * 0.5,
                          spreadRadius: size * 0.02,
                          offset: Offset(0, size * 0.1),
                        ),
                      ],
                    ),
                  ),
                ),

              // 2. Liquid Glass Card Container
              ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      gradient: AppColors.liquidGlassGradient,
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    child: Stack(
                      children: [
                        // Subtle inner background aurora orb
                        Positioned(
                          top: -size * 0.2,
                          left: -size * 0.2,
                          width: size * 0.8,
                          height: size * 0.8,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.cyanAccent.withValues(alpha: 0.25),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Iridescent refraction rim border painter
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _LiquidGlassBorderPainter(
                              radius: radius,
                              strokeWidth: (size * 0.025).clamp(1.5, 3.5),
                            ),
                          ),
                        ),

                        // 3. Central Canine & Biometric Telemetry Insignia
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.all(size * 0.12),
                            child: CustomPaint(
                              painter: _CanivueInsigniaPainter(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!widget.enableAnimation) {
      return logoContent;
    }

    // Apply smooth liquid breathing & shimmer animation via flutter_animate
    return logoContent
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: 3200.ms,
          color: AppColors.cyanAccent.withValues(alpha: 0.25),
          angle: 45,
        );
  }
}

/// Custom painter for iridescent glass border reflections.
class _LiquidGlassBorderPainter extends CustomPainter {
  const _LiquidGlassBorderPainter({
    required this.radius,
    required this.strokeWidth,
  });

  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = AppColors.liquidGlassBorderGradient.createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassBorderPainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.strokeWidth != strokeWidth;
}

/// Precision custom painter for the Canivue canine silhouette and biometric pulse wave.
class _CanivueInsigniaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ViewBox mapping: normalized from 0..1 to 0..w and 0..h
    // 1. Canine Head & Neck Smooth Silhouette
    final bodyPath = Path();
    bodyPath.moveTo(w * 0.30, h * 0.78);
    // Left neck arch
    bodyPath.cubicTo(w * 0.28, h * 0.65, w * 0.32, h * 0.48, w * 0.38, h * 0.38);
    // Neck to ear base
    bodyPath.cubicTo(w * 0.42, h * 0.30, w * 0.47, h * 0.21, w * 0.50, h * 0.15);
    // Ear tip
    bodyPath.cubicTo(w * 0.52, h * 0.12, w * 0.55, h * 0.14, w * 0.56, h * 0.19);
    // Ear down to forehead
    bodyPath.cubicTo(w * 0.55, h * 0.26, w * 0.58, h * 0.32, w * 0.63, h * 0.35);
    // Forehead to snout muzzle
    bodyPath.cubicTo(w * 0.70, h * 0.39, w * 0.76, h * 0.44, w * 0.79, h * 0.50);
    // Snout to jaw
    bodyPath.cubicTo(w * 0.80, h * 0.56, w * 0.74, h * 0.59, w * 0.68, h * 0.59);
    // Jaw to collar base
    bodyPath.cubicTo(w * 0.60, h * 0.59, w * 0.53, h * 0.63, w * 0.48, h * 0.69);
    bodyPath.lineTo(w * 0.43, h * 0.78);
    bodyPath.close();

    // Body Gradient: Frosted Platinum White -> Luminous Cyan tint
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFE2FAF8),
          Color(0xFF99F6E4),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Draw soft subtle drop shadow behind silhouette
    canvas.drawShadow(bodyPath, Colors.black.withValues(alpha: 0.4), 6.0, false);
    canvas.drawPath(bodyPath, bodyPaint);

    // 2. Ear Dynamic Facet (Teal-to-Violet Liquid Sheen)
    final earPath = Path();
    earPath.moveTo(w * 0.50, h * 0.17);
    earPath.cubicTo(w * 0.53, h * 0.24, w * 0.50, h * 0.31, w * 0.44, h * 0.37);
    earPath.cubicTo(w * 0.42, h * 0.33, w * 0.43, h * 0.26, w * 0.46, h * 0.21);
    earPath.close();

    final earPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00F2FE), Color(0xFF6366F1)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(w * 0.4, h * 0.15, w * 0.2, h * 0.3));

    canvas.drawPath(earPath, earPaint);

    // 3. Intelligent Eye
    final eyePaint = Paint()..color = const Color(0xFF0F766E);
    canvas.drawCircle(Offset(w * 0.60, h * 0.44), w * 0.024, eyePaint);

    final eyeSpark = Paint()..color = const Color(0xFF00F2FE);
    canvas.drawCircle(Offset(w * 0.605, h * 0.435), w * 0.010, eyeSpark);

    // 4. Glowing Biometric ECG Telemetry Pulse Wave ("Vue")
    final pulsePath = Path();
    pulsePath.moveTo(w * 0.16, h * 0.65);
    pulsePath.lineTo(w * 0.30, h * 0.65);
    pulsePath.lineTo(w * 0.35, h * 0.60);
    pulsePath.lineTo(w * 0.40, h * 0.72);
    pulsePath.lineTo(w * 0.46, h * 0.54);
    pulsePath.lineTo(w * 0.52, h * 0.77);
    pulsePath.lineTo(w * 0.58, h * 0.62);
    pulsePath.lineTo(w * 0.63, h * 0.67);
    pulsePath.lineTo(w * 0.68, h * 0.65);
    pulsePath.lineTo(w * 0.86, h * 0.65);

    // Pulse Glow
    final glowPulsePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.065
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.cyanAccent.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(pulsePath, glowPulsePaint);

    // Sharp Foreground Pulse Line
    final pulsePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = AppColors.biometricPulseGradient.createShader(
        Rect.fromLTWH(w * 0.16, h * 0.5, w * 0.7, h * 0.3),
      );
    canvas.drawPath(pulsePath, pulsePaint);

    // Biometric Pulse Nodes
    final nodeCenter1 = Offset(w * 0.52, h * 0.77);
    canvas.drawCircle(nodeCenter1, w * 0.028, Paint()..color = Colors.white);
    canvas.drawCircle(nodeCenter1, w * 0.016, Paint()..color = AppColors.royalViolet);

    final nodeCenter2 = Offset(w * 0.46, h * 0.54);
    canvas.drawCircle(nodeCenter2, w * 0.022, Paint()..color = Colors.white);
    canvas.drawCircle(nodeCenter2, w * 0.012, Paint()..color = AppColors.cyanAccent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Complete Landing & Splash Logo Preview Widget.
///
/// Features the Liquid Glass Logo, glowing ambient aurora ring, and
/// high-end typography styled with [flutter-ui-design].
class CanivueLandingLogoPreview extends StatelessWidget {
  const CanivueLandingLogoPreview({
    super.key,
    this.logoSize = 104.0,
    this.titleSize = 32.0,
    this.subtitleSize = 13.0,
    this.spacing = 20.0,
    this.onTap,
  });

  final double logoSize;
  final double titleSize;
  final double subtitleSize;
  final double spacing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Interactive Liquid Glass Logo Badge
        CanivueLiquidLogo(
          size: logoSize,
          showGlow: true,
          enableAnimation: true,
          onTap: onTap,
        ),

        SizedBox(height: spacing),

        // 2. Brand Name with Prismatic Shader Mask
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFE2FAF8),
              Color(0xFF99F6E4),
              Color(0xFFC7D2FE),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'CANIVE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 4.5,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 6),

        // 3. Telemetry Subtitle with Glowing Beacon Dot
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 7,
              width: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyanAccent,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyanAccent.withValues(alpha: 0.8),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'CANINE HEALTH INTELLIGENCE',
              style: GoogleFonts.inter(
                fontSize: subtitleSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.2,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
