import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Crafted Vector Canine Asset (`anatomy`, `anatomy-asset`, `apple-design`).
///
/// Features:
/// - Sitting directly on the green background with zero white box or container
/// - Soft contact ground shadow grounding the dog into the surface (Tone 1)
/// - Four-tone shading with fur base, warm pearl chest bib, and specular highlights
/// - Canivue Cyan Smart Collar with glowing telemetry status pendant
/// - Calm harmonic tail-wag and breathing chest motion (respects `prefers-reduced-motion`)
class SittingDogVectorHero extends StatefulWidget {
  const SittingDogVectorHero({
    super.key,
    this.width = 175.0,
    this.height = 170.0,
    this.collarColor,
  });

  final double width;
  final double height;
  final Color? collarColor;

  @override
  State<SittingDogVectorHero> createState() => _SittingDogVectorHeroState();
}

class _SittingDogVectorHeroState extends State<SittingDogVectorHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          final progress = disableAnimations ? 0.0 : _animController.value;
          return CustomPaint(
            painter: _SittingDogPainter(
              progress: progress,
              collarColor: widget.collarColor,
            ),
          );
        },
      ),
    );
  }
}

class _SittingDogPainter extends CustomPainter {
  const _SittingDogPainter({
    required this.progress,
    this.collarColor,
  });

  final double progress;
  final Color? collarColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 400.0;
    canvas.save();
    canvas.scale(scale, scale);

    final swayPhase = progress * 2 * math.pi;
    final tailWag = math.sin(swayPhase * 1.5) * 6.0;
    final chestBreath = math.sin(swayPhase) * 1.8;

    // -------------------------------------------------------------
    // 1. Ground Contact Shadow (Tone 1 - Shadow on green floor)
    // -------------------------------------------------------------
    final groundShadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF022622).withValues(alpha: 0.55),
          const Color(0xFF022622).withValues(alpha: 0.20),
          const Color(0xFF022622).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(
        Rect.fromCenter(
          center: const Offset(200, 360),
          width: 220,
          height: 48,
        ),
      );
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(200, 360),
        width: 220,
        height: 48,
      ),
      groundShadowPaint,
    );

    // -------------------------------------------------------------
    // 2. Wagging Tail (Behind body, Painter's order)
    // -------------------------------------------------------------
    final tailPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFCD34D), Color(0xFFF59E0B), Color(0xFFD97706)],
      ).createShader(const Rect.fromLTWH(240, 190, 110, 130));

    final tailPath = Path()
      ..moveTo(265, 305)
      ..cubicTo(310 + tailWag, 300, 345 + tailWag, 255, 338 + tailWag, 222)
      ..cubicTo(332 + tailWag, 195, 302 + tailWag, 210, 292 + tailWag, 235)
      ..cubicTo(282, 260, 258, 290, 248, 305)
      ..close();
    canvas.drawPath(tailPath, tailPaint);

    // Tail Tip Pearl Specular
    final tailTipPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final tailTipPath = Path()
      ..moveTo(338 + tailWag, 222)
      ..cubicTo(342 + tailWag, 214, 328 + tailWag, 206, 314 + tailWag, 220)
      ..cubicTo(324 + tailWag, 224, 334 + tailWag, 228, 338 + tailWag, 222)
      ..close();
    canvas.drawPath(tailTipPath, tailTipPaint);

    // -------------------------------------------------------------
    // 3. Seated Hind Legs & Haunches
    // -------------------------------------------------------------
    final haunchShadePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD97706), Color(0xFFB45309)],
      ).createShader(const Rect.fromLTWH(100, 270, 200, 80));

    final baseFurPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFCD34D), Color(0xFFF59E0B), Color(0xFFD97706)],
      ).createShader(const Rect.fromLTWH(100, 190, 200, 160));

    // Left Haunch
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(140, 305), width: 76, height: 64),
      haunchShadePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(130, 335), width: 52, height: 32),
      baseFurPaint,
    );
    // Left Paws
    final pawCream = Paint()..color = const Color(0xFFFDE68A);
    canvas.drawCircle(const Offset(115, 342), 8, pawCream);
    canvas.drawCircle(const Offset(130, 345), 9, pawCream);
    canvas.drawCircle(const Offset(145, 342), 8, pawCream);

    // Right Haunch
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(260, 305), width: 76, height: 64),
      haunchShadePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(270, 335), width: 52, height: 32),
      baseFurPaint,
    );
    // Right Paws
    canvas.drawCircle(const Offset(255, 342), 8, pawCream);
    canvas.drawCircle(const Offset(270, 345), 9, pawCream);
    canvas.drawCircle(const Offset(285, 342), 8, pawCream);

    // -------------------------------------------------------------
    // 4. Body / Torso (Breathing expansion)
    // -------------------------------------------------------------
    final bodyPath = Path()
      ..moveTo(155 - chestBreath, 210)
      ..cubicTo(148 - chestBreath, 265, 155, 325, 170, 340)
      ..lineTo(230, 340)
      ..cubicTo(245, 325, 252 + chestBreath, 265, 245 + chestBreath, 210)
      ..close();
    canvas.drawPath(bodyPath, baseFurPaint);

    // -------------------------------------------------------------
    // 5. Warm Pearl Chest Bib (Tone 4 - Pearl highlight)
    // -------------------------------------------------------------
    final pearlChestPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFFFF), Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
      ).createShader(const Rect.fromLTWH(160, 210, 80, 110));

    final chestPath = Path()
      ..moveTo(175 - chestBreath * 0.7, 210)
      ..cubicTo(165 - chestBreath * 0.7, 245, 170, 290, 200, 315)
      ..cubicTo(230, 290, 235 + chestBreath * 0.7, 245, 225 + chestBreath * 0.7, 210)
      ..close();
    canvas.drawPath(chestPath, pearlChestPaint);

    // -------------------------------------------------------------
    // 6. Front Legs & Paws
    // -------------------------------------------------------------
    // Left Front Leg
    final leftLeg = Path()
      ..moveTo(172, 240)
      ..lineTo(168, 340)
      ..cubicTo(168, 348, 186, 348, 186, 340)
      ..lineTo(186, 240)
      ..close();
    canvas.drawPath(leftLeg, baseFurPaint);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(177, 344), width: 28, height: 18),
      pawCream,
    );
    final clawLinePaint = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(172, 341), const Offset(172, 348), clawLinePaint);
    canvas.drawLine(const Offset(182, 341), const Offset(182, 348), clawLinePaint);

    // Right Front Leg
    final rightLeg = Path()
      ..moveTo(214, 240)
      ..lineTo(214, 340)
      ..cubicTo(214, 348, 232, 348, 232, 340)
      ..lineTo(228, 240)
      ..close();
    canvas.drawPath(rightLeg, baseFurPaint);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(223, 344), width: 28, height: 18),
      pawCream,
    );
    canvas.drawLine(const Offset(218, 341), const Offset(218, 348), clawLinePaint);
    canvas.drawLine(const Offset(228, 341), const Offset(228, 348), clawLinePaint);

    // -------------------------------------------------------------
    // 7. Canivue Cyan Smart Collar with Glowing Telemetry Pendant
    // -------------------------------------------------------------
    final collarPrimary = collarColor ?? const Color(0xFF00F2FE);
    final collarPaint = Paint()
      ..shader = LinearGradient(
        colors: [collarPrimary, const Color(0xFF00D2C4), const Color(0xFF14B8A6)],
      ).createShader(const Rect.fromLTWH(155, 205, 90, 25));

    final collarPath = Path()
      ..moveTo(160, 205)
      ..cubicTo(185, 218, 215, 218, 240, 205)
      ..lineTo(243, 217)
      ..cubicTo(215, 230, 185, 230, 157, 217)
      ..close();
    canvas.drawPath(collarPath, collarPaint);

    // Glowing Biometric Status Pendant
    final pendantGlow = Paint()
      ..color = collarPrimary.withValues(alpha: 0.65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(const Offset(200, 224), 8, pendantGlow);
    canvas.drawCircle(const Offset(200, 224), 6, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(200, 224), 4, Paint()..color = collarPrimary);

    // -------------------------------------------------------------
    // 8. Head & Cheeks
    // -------------------------------------------------------------
    final headPath = Path()
      ..moveTo(148, 155)
      ..cubicTo(135, 175, 140, 205, 165, 210)
      ..cubicTo(185, 215, 215, 215, 235, 210)
      ..cubicTo(260, 205, 265, 175, 252, 155)
      ..cubicTo(248, 110, 230, 85, 200, 85)
      ..cubicTo(170, 85, 152, 110, 148, 155)
      ..close();
    canvas.drawPath(headPath, baseFurPaint);

    // -------------------------------------------------------------
    // 9. Droopy Soft Ears (With Inner Warm Tone)
    // -------------------------------------------------------------
    // Left Ear
    final leftEar = Path()
      ..moveTo(154, 115)
      ..cubicTo(130, 115, 110, 145, 112, 185)
      ..cubicTo(114, 215, 130, 225, 142, 210)
      ..cubicTo(150, 195, 152, 150, 154, 115)
      ..close();
    canvas.drawPath(leftEar, haunchShadePaint);

    final leftEarInner = Path()
      ..moveTo(125, 145)
      ..cubicTo(118, 165, 120, 195, 130, 200)
      ..cubicTo(138, 190, 138, 165, 136, 145)
      ..close();
    canvas.drawPath(
      leftEarInner,
      Paint()..color = const Color(0xFFB45309).withValues(alpha: 0.60),
    );

    // Right Ear
    final rightEar = Path()
      ..moveTo(246, 115)
      ..cubicTo(270, 115, 290, 145, 288, 185)
      ..cubicTo(286, 215, 270, 225, 258, 210)
      ..cubicTo(250, 195, 248, 150, 246, 115)
      ..close();
    canvas.drawPath(rightEar, haunchShadePaint);

    final rightEarInner = Path()
      ..moveTo(275, 145)
      ..cubicTo(282, 165, 280, 195, 270, 200)
      ..cubicTo(262, 190, 262, 165, 264, 145)
      ..close();
    canvas.drawPath(
      rightEarInner,
      Paint()..color = const Color(0xFFB45309).withValues(alpha: 0.60),
    );

    // -------------------------------------------------------------
    // 10. Muzzle / Snout
    // -------------------------------------------------------------
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(200, 172), width: 68, height: 48),
      pearlChestPaint,
    );

    // Truffle Nose
    final nosePath = Path()
      ..moveTo(188, 158)
      ..cubicTo(194, 154, 206, 154, 212, 158)
      ..cubicTo(216, 161, 210, 172, 200, 174)
      ..cubicTo(190, 172, 184, 161, 188, 158)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFF16171B));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(196, 159), width: 7, height: 3.5),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    // Smile Lines
    final smilePaint = Paint()
      ..color = const Color(0xFF16171B)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final mouthLeft = Path()
      ..moveTo(200, 174)
      ..lineTo(200, 182)
      ..cubicTo(192, 185, 186, 183, 182, 180);
    final mouthRight = Path()
      ..moveTo(200, 182)
      ..cubicTo(208, 185, 214, 183, 218, 180);
    canvas.drawPath(mouthLeft, smilePaint);
    canvas.drawPath(mouthRight, smilePaint);

    // Whisker Dots
    final whiskerPaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawCircle(const Offset(178, 173), 1.5, whiskerPaint);
    canvas.drawCircle(const Offset(174, 177), 1.5, whiskerPaint);
    canvas.drawCircle(const Offset(222, 173), 1.5, whiskerPaint);
    canvas.drawCircle(const Offset(226, 177), 1.5, whiskerPaint);

    // -------------------------------------------------------------
    // 11. Expressive Sparkling Eyes (Apple Double Catchlights)
    // -------------------------------------------------------------
    final eyeBase = Paint()..color = const Color(0xFF16171B);
    final catchlight = Paint()..color = Colors.white;

    // Left Eye
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(176, 142), width: 17, height: 20),
      eyeBase,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(178, 140), width: 6.5, height: 8),
      catchlight,
    );
    canvas.drawCircle(const Offset(174, 146), 1.6, catchlight);
    // Left Eyebrow Dot
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(174, 126), width: 10, height: 5),
      pawCream,
    );

    // Right Eye
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(224, 142), width: 17, height: 20),
      eyeBase,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(222, 140), width: 6.5, height: 8),
      catchlight,
    );
    canvas.drawCircle(const Offset(226, 146), 1.6, catchlight);
    // Right Eyebrow Dot
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(226, 126), width: 10, height: 5),
      pawCream,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SittingDogPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.collarColor != collarColor;
  }
}
