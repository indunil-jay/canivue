import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:canivue/core/theme/app_theme.dart';

class AuraCanvasBackground extends StatelessWidget {
  const AuraCanvasBackground({
    super.key,
    required this.child,
    this.primaryAccent,
    this.secondaryAccent,
  });

  final Widget child;
  final Color? primaryAccent;
  final Color? secondaryAccent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    final primary = primaryAccent ?? (isDark ? AppTheme.primaryBlue : const Color(0xFF38BDF8));
    final secondary = secondaryAccent ?? (isDark ? AppTheme.cyanAccent : const Color(0xFF818CF8));
    final tertiary = isDark ? const Color(0xFF10B981) : const Color(0xFFA7F3D0);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Base Foundation Gradient
          Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF080C14),
                        Color(0xFF0D1420),
                        Color(0xFF111928),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : const LinearGradient(
                      colors: [
                        Color(0xFFF8FAFC),
                        Color(0xFFEFF6FF),
                        Color(0xFFE2E8F0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
            ),
          ),

          // Fluid Blob 1: Top Right Aura
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              height: 320,
              width: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withValues(alpha: isDark ? 0.32 : 0.45),
                    primary.withValues(alpha: isDark ? 0.12 : 0.18),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Fluid Blob 2: Bottom Left Aura
          Positioned(
            bottom: size.height * 0.18,
            left: -70,
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    secondary.withValues(alpha: isDark ? 0.28 : 0.4),
                    secondary.withValues(alpha: isDark ? 0.10 : 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Fluid Blob 3: Center Ambient Accent
          Positioned(
            top: size.height * 0.42,
            right: -40,
            child: Container(
              height: 240,
              width: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    tertiary.withValues(alpha: isDark ? 0.2 : 0.35),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          // High-grade Softening Diffusion Layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Interactive Content
          child,
        ],
      ),
    );
  }
}

