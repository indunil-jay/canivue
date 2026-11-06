import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The signature Canivue Paw & Bone brand logo as referenced in the modern pet care design.
///
/// Features:
/// - 4 curved toe pads
/// - Central organic palm pad
/// - Classic horizontal dog bone anchor
/// - Optional brand title ("Canivue") with pet badge
class CanivuePawBoneLogo extends StatelessWidget {
  const CanivuePawBoneLogo({
    super.key,
    this.size = 36.0,
    this.color,
    this.showText = false,
    this.subtitle,
    this.textColor,
    this.badgeColor,
  });

  /// Size of the logo icon.
  final double size;

  /// Main silhouette color of the paw & bone. Defaults to dark charcoal or theme onSurface.
  final Color? color;

  /// Whether to display the "Canivue" brand typography beside the logo.
  final bool showText;

  /// Optional subtitle below the brand name (e.g., "Pet Care Sanctuary").
  final String? subtitle;

  /// Color of the brand name and subtitle.
  final Color? textColor;

  /// Color of the accent dot or badge next to the brand name.
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF181A20);
    final effectiveTextColor = textColor ?? effectiveColor;
    final effectiveBadgeColor = badgeColor ?? const Color(0xFF14B8A6);

    final iconWidget = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PawBoneLogoPainter(color: effectiveColor),
      ),
    );

    if (!showText) {
      return iconWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget,
        SizedBox(width: size * 0.28),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Canive',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: size * 0.52,
                    fontWeight: FontWeight.w800,
                    color: effectiveTextColor,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: size * 0.08, top: size * 0.12),
                  width: size * 0.14,
                  height: size * 0.14,
                  decoration: BoxDecoration(
                    color: effectiveBadgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              SizedBox(height: size * 0.04),
              Text(
                subtitle!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: size * 0.26,
                  fontWeight: FontWeight.w600,
                  color: effectiveTextColor.withValues(alpha: 0.65),
                  letterSpacing: 0.8,
                  height: 1.0,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PawBoneLogoPainter extends CustomPainter {
  const _PawBoneLogoPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final scaleX = size.width / 100.0;
    final scaleY = size.height / 100.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // 1. Draw 4 Toe Pads
    _drawRotatedOval(canvas, paint, const Offset(23, 23), 7.2, 9.6, -22 * math.pi / 180);
    _drawRotatedOval(canvas, paint, const Offset(41, 15), 7.8, 10.8, -7 * math.pi / 180);
    _drawRotatedOval(canvas, paint, const Offset(59, 15), 7.8, 10.8, 7 * math.pi / 180);
    _drawRotatedOval(canvas, paint, const Offset(77, 23), 7.2, 9.6, 22 * math.pi / 180);

    // 2. Draw Main Organic Palm Pad
    final palmPath = Path();
    palmPath.moveTo(50, 31);
    palmPath.cubicTo(64, 31, 74, 38, 73, 49);
    palmPath.cubicTo(72, 59, 61, 64, 53, 62);
    palmPath.cubicTo(51.5, 61.6, 48.5, 61.6, 47, 62);
    palmPath.cubicTo(39, 64, 28, 59, 27, 49);
    palmPath.cubicTo(26, 38, 36, 31, 50, 31);
    palmPath.close();
    canvas.drawPath(palmPath, paint);

    // 3. Draw Dog Bone Silhouette Below Palm Pad
    // Shaft
    final shaftRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(26, 76, 48, 10),
      const Radius.circular(5),
    );
    canvas.drawRRect(shaftRect, paint);

    // Left bone knobs
    canvas.drawCircle(const Offset(25, 76), 6.0, paint);
    canvas.drawCircle(const Offset(25, 86), 6.0, paint);

    // Right bone knobs
    canvas.drawCircle(const Offset(75, 76), 6.0, paint);
    canvas.drawCircle(const Offset(75, 86), 6.0, paint);

    canvas.restore();
  }

  void _drawRotatedOval(
    Canvas canvas,
    Paint paint,
    Offset center,
    double radiusX,
    double radiusY,
    double angle,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: radiusX * 2, height: radiusY * 2),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PawBoneLogoPainter oldDelegate) =>
      oldDelegate.color != color;
}
