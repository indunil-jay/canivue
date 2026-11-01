import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/onboarding/models/onboarding_slide.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == onboardingSlides.length - 1;
  OnboardingSlide get _currentSlide => onboardingSlides[_currentPage];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToSignIn() {
    context.go('/sign-in');
  }

  void _handleNext() {
    if (_isLastPage) {
      _goToSignIn();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  void _handleBack() {
    if (_currentPage == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: _currentSlide.backgroundGradient,
        ),
        child: Stack(
          children: [
            // 1. Organic Breathing Aurora Orbs (Liquid Glass Background)
            Positioned(
              top: -90,
              right: -70,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 650),
                height: 320,
                width: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _currentSlide.accentColor.withValues(alpha: 0.38),
                      AppColors.royalViolet.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.96, 0.96),
                    end: const Offset(1.08, 1.08),
                    duration: 3800.ms,
                    curve: Curves.easeInOut,
                  ),
            ),
            Positioned(
              bottom: size.height * 0.22,
              left: -90,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 650),
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.cyanAccent.withValues(alpha: 0.28),
                      _currentSlide.accentColor.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1.06, 1.06),
                    end: const Offset(0.94, 0.94),
                    duration: 4200.ms,
                    curve: Curves.easeInOut,
                  ),
            ),

            // 2. Page View with Animated Slides
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingSlides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = onboardingSlides[index];
                  return _OnboardingPage(
                    key: ValueKey('slide_$index'),
                    slide: slide,
                    isActive: index == _currentPage,
                  );
                },
              ),
            ),

            // 3. Floating Bottom Navigation Bar (Glass Controls)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Main navigation row
                      Row(
                        children: [
                          // Left: Back button (if not page 0)
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _currentPage > 0
                                  ? _RoundIconButton(
                                      key: const ValueKey('back'),
                                      icon: Icons.arrow_back_rounded,
                                      onTap: _handleBack,
                                      gradient: null,
                                      accentColor: _currentSlide.accentColor,
                                    )
                                      .animate()
                                      .fadeIn(duration: 250.ms)
                                      .scale(
                                        begin: const Offset(0.85, 0.85),
                                        end: const Offset(1.0, 1.0),
                                        curve: Curves.easeOutBack,
                                      )
                                  : const SizedBox(height: 48, width: 48),
                            ),
                          ),

                          // Center: Smooth Page Indicator with Aurora Glow
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count: onboardingSlides.length,
                              effect: ExpandingDotsEffect(
                                activeDotColor: _currentSlide.accentColor,
                                dotColor: Colors.white.withValues(alpha: 0.28),
                                dotHeight: 8,
                                dotWidth: 8,
                                expansionFactor: 3.5,
                                spacing: 6,
                              ),
                            ),
                          ),

                          // Right: Next / Get Started Button
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _RoundIconButton(
                                key: ValueKey('action_btn_$_isLastPage'),
                                icon: _isLastPage
                                    ? Icons.rocket_launch_rounded
                                    : Icons.arrow_forward_rounded,
                                onTap: _handleNext,
                                gradient: _currentSlide.primaryGradient,
                                accentColor: _currentSlide.accentColor,
                                wide: _isLastPage,
                                label: _isLastPage ? 'Get Started' : null,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Bottom Skip Button
                      if (!_isLastPage) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _goToSignIn,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Skip',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white.withValues(alpha: 0.88),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 32),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    super.key,
    required this.slide,
    required this.isActive,
  });

  final OnboardingSlide slide;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < 700;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, isCompact ? 36 : 48, 20, 95),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. High-Tech Animated Liquid Glass Hero Frame
          // Combines entrance scale, continuous organic vertical floating, and periodic glass light shimmer
          Container(
            height: isCompact ? size.height * 0.38 : size.height * 0.44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: slide.accentColor.withValues(alpha: 0.38),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: slide.accentColor.withValues(alpha: 0.32),
                  blurRadius: 36,
                  spreadRadius: 2,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // A. Photo with Subtle Cinematic Ambient Zoom
                  Image.asset(
                    slide.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF041924),
                      child: Center(
                        child: Icon(slide.icon, size: 64, color: slide.accentColor),
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.06, 1.06),
                        duration: 6000.ms,
                        curve: Curves.easeInOut,
                      ),

                  // B. Deep Ambient Contrast Scrim
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.22),
                          Colors.black.withValues(alpha: 0.84),
                        ],
                        stops: const [0.35, 0.65, 1.0],
                      ),
                    ),
                  ),

                  // C. Vision Scanning Laser Beam (Slide 2 AI Vision active effect)
                  if (slide.badge.contains('Vision'))
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.neonMint.withValues(alpha: 0.8),
                              AppColors.cyanAccent,
                              AppColors.neonMint.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyanAccent.withValues(alpha: 0.8),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(
                            begin: 25,
                            end: isCompact ? size.height * 0.34 : size.height * 0.39,
                            duration: 2600.ms,
                            curve: Curves.easeInOut,
                          ),
                    ),

                  // D. Top Right Floating Liquid Telemetry HUD Chip (only if present)
                  if (slide.telemetryLabel != null && slide.telemetryIcon != null)
                    Positioned(
                    top: 16,
                    right: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: slide.accentColor.withValues(alpha: 0.55),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: slide.accentColor.withValues(alpha: 0.25),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Pulsing Live LED Dot
                              Container(
                                height: 7,
                                width: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: slide.accentColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: slide.accentColor,
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              )
                                  .animate(onPlay: (c) => c.repeat(reverse: true))
                                  .scale(
                                    begin: const Offset(0.75, 0.75),
                                    end: const Offset(1.35, 1.35),
                                    duration: 1100.ms,
                                  ),
                              const SizedBox(width: 7),
                              Icon(slide.telemetryIcon!, color: Colors.white, size: 14),
                              const SizedBox(width: 5),
                              Text(
                                slide.telemetryLabel!,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 400.ms)
                      .slideY(begin: -0.3, end: 0, curve: Curves.easeOutCubic),

                  // E. Bottom Left Floating Category Badge
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: slide.accentColor.withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: slide.accentColor.withValues(alpha: 0.25),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: slide.accentColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: slide.accentColor,
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                slide.icon,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                slide.badge,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.25, end: 0, curve: Curves.easeOutCubic),
                ],
              ),
            ),
          )
              // 1. Initial smooth entrance
              .animate()
              .fadeIn(duration: 450.ms, curve: Curves.easeOutCubic)
              .scale(
                begin: const Offset(0.96, 0.96),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.easeOutCubic,
              )
              // 2. Periodic Specular Shimmer across Glass Frame
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                delay: 1600.ms,
                duration: 2500.ms,
                color: slide.accentColor.withValues(alpha: 0.35),
                angle: 45,
              )
              // 3. Continuous Organic Floating Motion (Liquid Glass Gravity)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
                begin: -5,
                end: 5,
                duration: 3400.ms,
                curve: Curves.easeInOut,
              ),

          const SizedBox(height: 18),

          // 2. Liquid Glass Content Card (with Staggered Content Animation)
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: slide.cardGradient,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.26),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with slide-in animation
                    Text(
                      slide.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: Colors.white,
                        height: 1.18,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 400.ms)
                        .slideX(begin: -0.04, end: 0, curve: Curves.easeOutCubic),

                    const SizedBox(height: 10),

                    // Description with fade animation
                    Text(
                      slide.description,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 14,
                        height: 1.48,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 250.ms, duration: 400.ms),

                    const SizedBox(height: 16),

                    // Feature Pill Chips with Staggered Ripple Entrances
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: slide.featureTags.asMap().entries.map((entry) {
                        final index = entry.key;
                        final tag = entry.value;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: slide.accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: slide.accentColor.withValues(alpha: 0.45),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: slide.accentColor,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tag,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: 320 + (index * 70)),
                              duration: 350.ms,
                            )
                            .scale(
                              begin: const Offset(0.85, 0.85),
                              end: const Offset(1.0, 1.0),
                              curve: Curves.easeOutBack,
                            );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 450.ms, curve: Curves.easeOutCubic)
              .slideY(begin: 0.08, end: 0, duration: 450.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.gradient,
    required this.accentColor,
    this.wide = false,
    this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final LinearGradient? gradient;
  final Color accentColor;
  final bool wide;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final isFilled = gradient != null;

    Widget buttonBody = Container(
      height: 48,
      padding: wide ? const EdgeInsets.symmetric(horizontal: 18) : EdgeInsets.zero,
      width: wide ? 142 : 48,
      decoration: BoxDecoration(
        gradient: gradient,
        color: isFilled ? null : Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: isFilled ? 0.38 : 0.25),
          width: 1.2,
        ),
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.45),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            if (wide && label != null) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (wide) {
      buttonBody = buttonBody
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
            duration: 2200.ms,
            color: Colors.white.withValues(alpha: 0.35),
            angle: 45,
          );
    }

    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: buttonBody,
      ),
    );
  }
}
