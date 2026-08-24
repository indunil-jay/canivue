import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/theme/app_theme.dart';

class LuxuryBiometricRing extends StatelessWidget {
  const LuxuryBiometricRing({
    super.key,
    required this.percentage,
    this.size = 110,
    this.strokeWidth = 10,
    this.gradient,
    this.backgroundColor,
    this.centerWidget,
    this.valueText,
    this.unitText,
    this.label,
    this.icon,
    this.accentColor,
    this.glow = true,
  });

  final double percentage; // 0.0 to 1.0 (or 0 to 100)
  final double size;
  final double strokeWidth;
  final SweepGradient? gradient;
  final Color? backgroundColor;
  final Widget? centerWidget;
  final String? valueText;
  final String? unitText;
  final String? label;
  final IconData? icon;
  final Color? accentColor;
  final bool glow;

  double get _clampedProgress {
    final val = percentage > 1.0 ? percentage / 100.0 : percentage;
    return val.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = accentColor ?? (isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue);

    final sweepGradient = gradient ??
        SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: isDark
              ? [
                  const Color(0xFF0066FF),
                  const Color(0xFF00B4D8),
                  const Color(0xFF38BDF8),
                  const Color(0xFF10B981),
                ]
              : [
                  const Color(0xFF0284C7),
                  const Color(0xFF0066FF),
                  const Color(0xFF38BDF8),
                  const Color(0xFF059669),
                ],
          stops: const [0.0, 0.45, 0.75, 1.0],
        );

    final trackColor = backgroundColor ??
        (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0).withValues(alpha: 0.8));

    return Stack(
      alignment: Alignment.center,
      children: [
        // Optional Aura Glow behind the ring
        if (glow)
          Container(
            height: size * 0.85,
            width: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: isDark ? 0.35 : 0.2),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

        // Radial Ring Canvas
        SizedBox(
          height: size,
          width: size,
          child: CustomPaint(
            painter: _BiometricRingPainter(
              progress: _clampedProgress,
              strokeWidth: strokeWidth,
              trackColor: trackColor,
              sweepGradient: sweepGradient,
              accentColor: accent,
            ),
          ),
        ),

        // Center Content / Metrics Readout
        if (centerWidget != null)
          centerWidget!
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: size * 0.18, color: accent),
                const SizedBox(height: 2),
              ],
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    valueText ?? '${(_clampedProgress * 100).toInt()}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                      height: 1,
                    ),
                  ),
                  if (unitText != null) ...[
                    const SizedBox(width: 1),
                    Text(
                      unitText!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: size * 0.12,
                        fontWeight: FontWeight.bold,
                        color: accent,
                        height: 1,
                      ),
                    ),
                  ],
                ],
              ),
              if (label != null) ...[
                const SizedBox(height: 2),
                Text(
                  label!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: size * 0.095,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}

class _BiometricRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final SweepGradient sweepGradient;
  final Color accentColor;

  _BiometricRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.sweepGradient,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Draw Background Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // 2. Draw Progress Sweep
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

    // 3. Draw High-Tech Tip Indicator (Glow Bead)
    final tipAngle = startAngle + sweepAngle;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);
    final tipOffset = Offset(tipX, tipY);

    final beadGlowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);

    canvas.drawCircle(tipOffset, strokeWidth * 0.45, beadGlowPaint);
  }

  @override
  bool shouldRepaint(covariant _BiometricRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.accentColor != accentColor;
  }
}
