import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Crafted Isometric Canine Telemetry Asset (`/anatomy` and `/anatomy-asset`).
///
/// Implements:
/// - Isometric 30-degree perspective projection with painter's order (back-to-front)
/// - Four-tone shading: highlight rim, base plate, mid-tone bevel, and deep cast shadow
/// - Framed technical card with title, status readout, and live pulse telemetry
/// - Calm eased ambient motion respecting `MediaQuery.disableAnimations`
class AuthAnatomyVitalsHUD extends StatefulWidget {
  const AuthAnatomyVitalsHUD({
    super.key,
    required this.accentColor,
    required this.highlightColor,
    this.compact = false,
  });

  final Color accentColor;
  final Color highlightColor;
  final bool compact;

  @override
  State<AuthAnatomyVitalsHUD> createState() => _AuthAnatomyVitalsHUDState();
}

class _AuthAnatomyVitalsHUDState extends State<AuthAnatomyVitalsHUD>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  int _activeMetric = 0;

  static const List<Map<String, String>> _metrics = [
    {
      'label': 'CANINE VITALS',
      'value': '84 BPM • NORMAL',
      'hint': 'Live Collar Telemetry',
      'icon': '❤️',
    },
    {
      'label': 'HEALTH INDEX',
      'value': '99.2% OPTIMAL',
      'hint': 'Multimodal AI Vision',
      'icon': '🐾',
    },
    {
      'label': 'NEURAL SYNC',
      'value': 'ACTIVE • 42ms',
      'hint': 'Predictive Health Engine',
      'icon': '⚡',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _cycleMetric() {
    setState(() {
      _activeMetric = (_activeMetric + 1) % _metrics.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final metric = _metrics[_activeMetric];

    return Semantics(
      label: '${metric['label']}: ${metric['value']}. Tap to cycle telemetry.',
      button: true,
      child: GestureDetector(
        onTap: _cycleMetric,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 12 : 14,
            vertical: widget.compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Isometric Collar Sensor Asset (Four-Tone Shading)
              SizedBox(
                width: widget.compact ? 34 : 40,
                height: widget.compact ? 34 : 40,
                child: CustomPaint(
                  painter: _IsometricTelemetryPuckPainter(
                    accentColor: widget.accentColor,
                    highlightColor: widget.highlightColor,
                    pulse: disableAnimations ? 0.5 : _pulseController.value,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // 2. Framed Technical Readout & Hint
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status Blinking Dot
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          final opacity = disableAnimations
                              ? 1.0
                              : 0.5 + 0.5 * math.sin(_pulseController.value * math.pi * 2);
                          return Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.highlightColor.withValues(alpha: opacity),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.highlightColor.withValues(alpha: opacity * 0.8),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 5),
                      Text(
                        metric['label']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: widget.compact ? 9.5 : 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.78),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        metric['icon']!,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    metric['value']!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: widget.compact ? 12 : 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Mini Hint Chevron
              Icon(
                Icons.swap_horiz_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the 4-tone isometric canine sensor puck (`/anatomy-asset`).
///
/// Perspective: Isometric 30-degree projection.
/// Tone 1: Cast Ambient Shadow (black/teal floor contact)
/// Tone 2: Mid-tone isometric bevel wall
/// Tone 3: Base tone top face
/// Tone 4: Specular rim & glowing biometric pulse core
class _IsometricTelemetryPuckPainter extends CustomPainter {
  const _IsometricTelemetryPuckPainter({
    required this.accentColor,
    required this.highlightColor,
    required this.pulse,
  });

  final Color accentColor;
  final Color highlightColor;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radiusX = size.width * 0.44;
    final radiusY = size.height * 0.24;
    final puckHeight = size.height * 0.22;

    // 1. Cast Ambient Shadow (Tone 1: Shadow)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + puckHeight + 3),
        width: radiusX * 2,
        height: radiusY * 2,
      ),
      shadowPaint,
    );

    // 2. Mid-Tone Isometric Bevel Cylinder (Tone 2: Mid-tone)
    final bevelPath = Path()
      ..moveTo(cx - radiusX, cy)
      ..lineTo(cx - radiusX, cy + puckHeight)
      ..arcToPoint(
        Offset(cx + radiusX, cy + puckHeight),
        radius: Radius.elliptical(radiusX, radiusY),
        clockwise: false,
      )
      ..lineTo(cx + radiusX, cy)
      ..arcToPoint(
        Offset(cx - radiusX, cy),
        radius: Radius.elliptical(radiusX, radiusY),
        clockwise: true,
      )
      ..close();

    final bevelPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          accentColor.withValues(alpha: 0.60),
          accentColor.withValues(alpha: 0.95),
          accentColor.withValues(alpha: 0.45),
        ],
      ).createShader(Rect.fromLTWH(cx - radiusX, cy, radiusX * 2, puckHeight));
    canvas.drawPath(bevelPath, bevelPaint);

    // 3. Base Isometric Top Surface (Tone 3: Base Tone)
    final topRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: radiusX * 2,
      height: radiusY * 2,
    );
    final topPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          highlightColor.withValues(alpha: 0.95),
          accentColor,
        ],
      ).createShader(topRect);
    canvas.drawOval(topRect, topPaint);

    // 4. Specular Highlight Rim (Tone 4: Highlight)
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawOval(topRect, rimPaint);

    // 5. Center Biometric Pulse Wave
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6
      ..color = Colors.white;

    final wavePath = Path();
    final waveWidth = radiusX * 1.1;
    final waveStartX = cx - waveWidth / 2;
    final waveY = cy;

    wavePath.moveTo(waveStartX, waveY);
    wavePath.lineTo(waveStartX + waveWidth * 0.25, waveY);
    // Pulse spike influenced by progress
    final spikeOffset = math.sin(pulse * math.pi * 2) * 3.5;
    wavePath.lineTo(waveStartX + waveWidth * 0.40, waveY - 4 - spikeOffset);
    wavePath.lineTo(waveStartX + waveWidth * 0.55, waveY + 4 + spikeOffset);
    wavePath.lineTo(waveStartX + waveWidth * 0.70, waveY);
    wavePath.lineTo(waveStartX + waveWidth, waveY);

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _IsometricTelemetryPuckPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.highlightColor != highlightColor;
  }
}
