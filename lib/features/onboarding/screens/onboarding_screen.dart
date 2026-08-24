import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:canivue/core/theme/app_theme.dart';
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
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleBack() {
    if (_currentPage == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final imageHeight = size.height * 0.5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingSlides.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final slide = onboardingSlides[index];
                return _OnboardingPage(
                  slide: slide,
                  imageHeight: imageHeight,
                  isActive: index == _currentPage,
                );
              },
            ),
          ),

          // Skip button
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: AnimatedOpacity(
                opacity: _isLastPage ? 0 : 1,
                duration: const Duration(milliseconds: 250),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 16),
                  child: TextButton(
                    onPressed: _isLastPage ? null : _goToSignIn,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.28),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom controls: indicator + CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _currentPage > 0
                          ? _RoundIconButton(
                              key: const ValueKey('back'),
                              icon: Icons.arrow_back_rounded,
                              onTap: _handleBack,
                              filled: false,
                            )
                          : const SizedBox(key: ValueKey('no-back'), width: 0),
                    ),
                    if (_currentPage > 0) const SizedBox(width: 14),
                    Expanded(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: onboardingSlides.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: AppTheme.primaryBlue,
                          dotColor: theme.colorScheme.outlineVariant,
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 3.6,
                          spacing: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    _RoundIconButton(
                      icon: _isLastPage ? Icons.check_rounded : Icons.arrow_forward_rounded,
                      onTap: _handleNext,
                      filled: true,
                      wide: _isLastPage,
                      label: _isLastPage ? 'Get Started' : null,
                    ),
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

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.slide,
    required this.imageHeight,
    required this.isActive,
  });

  final OnboardingSlide slide;
  final double imageHeight;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: imageHeight,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
                child: Image.asset(
                  slide.imageAsset,
                  fit: BoxFit.cover,
                ),
              ),
              // Scrim for legibility + brand tint
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.oceanBlue.withValues(alpha: 0.25),
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      stops: const [0, 0.55, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    slide.badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate(target: isActive ? 1 : 0).fadeIn(duration: 380.ms).slideY(begin: 0.3, end: 0),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                )
                    .animate(target: isActive ? 1 : 0)
                    .fadeIn(duration: 420.ms, delay: 80.ms)
                    .slideY(begin: 0.25, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 12),
                Text(
                  slide.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                )
                    .animate(target: isActive ? 1 : 0)
                    .fadeIn(duration: 420.ms, delay: 160.ms)
                    .slideY(begin: 0.25, end: 0, curve: Curves.easeOutCubic),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.filled,
    this.wide = false,
    this.label,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final bool wide;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      height: 52,
      width: wide ? null : 52,
      padding: wide ? const EdgeInsets.symmetric(horizontal: 20) : null,
      decoration: BoxDecoration(
        gradient: filled ? AppTheme.primaryGradient : null,
        color: filled ? null : const Color(0xFFF1F5F9),
        shape: wide ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: wide ? BorderRadius.circular(26) : null,
        boxShadow: filled
            ? [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: filled ? Colors.white : const Color(0xFF334155), size: 22),
          if (wide && label != null) ...[
            const SizedBox(width: 8),
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
