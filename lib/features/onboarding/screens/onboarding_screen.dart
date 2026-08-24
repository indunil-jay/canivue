import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:canivue/core/utils/page_transitions.dart';
import 'package:canivue/features/auth/screens/signin_screen.dart';
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
    Navigator.of(context).pushReplacement(fadeSlidePageRoute(const SignInScreen()));
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
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: _currentSlide.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Ambient Luminous Background Orbs for Depth
            Positioned(
              top: -80,
              right: -60,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                height: 280,
                width: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _currentSlide.accentColor.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.25,
              left: -80,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                height: 260,
                width: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _currentSlide.accentColor.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Page View with Slides
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingSlides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = onboardingSlides[index];
                  return _OnboardingPage(
                    slide: slide,
                    isActive: index == _currentPage,
                  );
                },
              ),
            ),

            // Top Header: Brand Badge & Step Pill & Skip Button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Canivue Logo
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          gradient: _currentSlide.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _currentSlide.accentColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pets_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),

                      // Skip Button
                      AnimatedOpacity(
                        opacity: _isLastPage ? 0 : 1,
                        duration: const Duration(milliseconds: 250),
                        child: TextButton(
                          onPressed: _isLastPage ? null : _goToSignIn,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.14),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Skip',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.chevron_right_rounded, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Navigation Controls
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Back Button
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: _currentPage > 0
                                  ? _RoundIconButton(
                                      key: const ValueKey('back'),
                                      icon: Icons.arrow_back_rounded,
                                      onTap: _handleBack,
                                      gradient: null,
                                      accentColor: _currentSlide.accentColor,
                                    )
                                  : const SizedBox(key: ValueKey('no-back'), width: 0),
                            ),
                            if (_currentPage > 0) const SizedBox(width: 14),

                            // Indicator
                            Expanded(
                              child: Center(
                                child: SmoothPageIndicator(
                                  controller: _pageController,
                                  count: onboardingSlides.length,
                                  effect: ExpandingDotsEffect(
                                    activeDotColor: _currentSlide.accentColor,
                                    dotColor: Colors.white.withValues(alpha: 0.3),
                                    dotHeight: 8,
                                    dotWidth: 8,
                                    expansionFactor: 3.5,
                                    spacing: 6,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Next / Get Started Button
                            _RoundIconButton(
                              icon: _isLastPage ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                              onTap: _handleNext,
                              gradient: _currentSlide.primaryGradient,
                              accentColor: _currentSlide.accentColor,
                              wide: _isLastPage,
                              label: _isLastPage ? 'Get Started' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
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
    required this.slide,
    required this.isActive,
  });

  final OnboardingSlide slide;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < 700;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, isCompact ? 70 : 85, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Image Glass Container
          Container(
            height: isCompact ? size.height * 0.38 : size.height * 0.44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: slide.accentColor.withValues(alpha: 0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  Image.asset(
                    slide.imageAsset,
                    fit: BoxFit.cover,
                  ),

                  // Gradient Scrim Layer for Smooth Blending
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        stops: const [0.4, 0.7, 1.0],
                      ),
                    ),
                  ),

                  // Bottom Floating Badge with Category Icon
                  Positioned(
                    left: 18,
                    bottom: 18,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                slide.icon,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                slide.badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate(target: isActive ? 1 : 0).fadeIn(duration: 380.ms).slideY(begin: 0.3, end: 0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Enhanced Glassmorphism Content Card
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: slide.cardGradient,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      slide.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.18,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    )
                        .animate(target: isActive ? 1 : 0)
                        .fadeIn(duration: 400.ms, delay: 80.ms)
                        .slideY(begin: 0.25, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 10),

                    // Description
                    Text(
                      slide.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                        .animate(target: isActive ? 1 : 0)
                        .fadeIn(duration: 400.ms, delay: 140.ms)
                        .slideY(begin: 0.25, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 16),

                    // Feature Pill Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: slide.featureTags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: slide.accentColor.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: slide.accentColor,
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                        .animate(target: isActive ? 1 : 0)
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ),
          ),
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

    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      height: 48,
      width: wide ? null : 48,
      padding: wide ? const EdgeInsets.symmetric(horizontal: 22) : null,
      decoration: BoxDecoration(
        gradient: gradient,
        color: isFilled ? null : Colors.white.withValues(alpha: 0.15),
        shape: wide ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: wide ? BorderRadius.circular(24) : null,
        border: Border.all(
          color: Colors.white.withValues(alpha: isFilled ? 0.3 : 0.2),
        ),
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          if (wide && label != null) ...[
            const SizedBox(width: 8),
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      shape: wide ? const StadiumBorder() : const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: wide ? const StadiumBorder() : const CircleBorder(),
        child: child,
      ),
    );
  }
}
