import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:canivue/core/widgets/canivue_paw_bone_logo.dart';
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
      duration: const Duration(milliseconds: 460),
      curve: Curves.easeInOutCubic,
    );
  }

  void _handleBack() {
    if (_currentPage == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: _currentSlide.backgroundGradient,
        ),
        child: Stack(
          children: [
            // 1. Subtle Watermark Paw Prints in background corners
            Positioned(
              top: topPadding + 40,
              right: -30,
              child: Opacity(
                opacity: 0.07,
                child: Transform.rotate(
                  angle: 0.35,
                  child: const CanivuePawBoneLogo(
                    size: 220,
                    color: Color(0xFF16171B),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 220,
              left: -40,
              child: Opacity(
                opacity: 0.06,
                child: Transform.rotate(
                  angle: -0.25,
                  child: const CanivuePawBoneLogo(
                    size: 200,
                    color: Color(0xFF16171B),
                  ),
                ),
              ),
            ),

            // 2. Interactive Slides PageView
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingSlides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = onboardingSlides[index];
                  return _SlideHeroVisual(
                    key: ValueKey('slide_visual_$index'),
                    slide: slide,
                    isActive: index == _currentPage,
                  );
                },
              ),
            ),

            // 3. Top Header: Paw & Bone Logo + Brand Name + Skip Pill
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Brand Logo: Paw & Bone (from reference Image 2)
                      CanivuePawBoneLogo(
                        size: 38,
                        showText: true,
                        subtitle: 'PET CARE SANCTUARY',
                        color: const Color(0xFF16171B),
                        textColor: const Color(0xFF16171B),
                        badgeColor: _currentSlide.accentColor,
                      ),

                      // Clean Skip Button
                      if (!_isLastPage)
                        GestureDetector(
                          onTap: _goToSignIn,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Skip',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 16,
                                  color: Color(0xFF475569),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 48, height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Bottom Sheet Card with Headline, Short Description & Controls (Image 2 & 3 style)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(42),
                    topRight: Radius.circular(42),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 32,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Headline (Bold, Expressive, Tight Spacing)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        child: Text(
                          _currentSlide.title,
                          key: ValueKey('title_${_currentPage}'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF16171B),
                            letterSpacing: -0.7,
                            height: 1.15,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Shortened 1-line Description
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        child: Text(
                          _currentSlide.description,
                          key: ValueKey('desc_${_currentPage}'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                            height: 1.45,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Bottom Navigation Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left: Back button or Pagination dots
                          if (_currentPage > 0)
                            GestureDetector(
                              onTap: _handleBack,
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.05),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 20,
                                  color: Color(0xFF16171B),
                                ),
                              ),
                            )
                          else
                            // Clean minimal dots (no slider count clutter!)
                            SmoothPageIndicator(
                              controller: _pageController,
                              count: onboardingSlides.length,
                              effect: const ExpandingDotsEffect(
                                activeDotColor: Color(0xFF16171B),
                                dotColor: Color(0x3316171B),
                                dotHeight: 6.5,
                                dotWidth: 6.5,
                                expansionFactor: 3.8,
                                spacing: 5.5,
                              ),
                            ),

                          if (_currentPage > 0)
                            SmoothPageIndicator(
                              controller: _pageController,
                              count: onboardingSlides.length,
                              effect: const ExpandingDotsEffect(
                                activeDotColor: Color(0xFF16171B),
                                dotColor: Color(0x3316171B),
                                dotHeight: 6.5,
                                dotWidth: 6.5,
                                expansionFactor: 3.8,
                                spacing: 5.5,
                              ),
                            ),

                          // Signature Black Pill Button with Circular Accent Icon (Images 2 & 4)
                          _SignaturePillButton(
                            label: _isLastPage ? 'Get Started' : 'Continue',
                            icon: _isLastPage
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                            accentColor: _currentSlide.accentColor,
                            onTap: _handleNext,
                          ),
                        ],
                      ),
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

class _SlideHeroVisual extends StatelessWidget {
  const _SlideHeroVisual({
    super.key,
    required this.slide,
    required this.isActive,
  });

  final OnboardingSlide slide;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final topPadding = MediaQuery.paddingOf(context).top;
    final isCompact = size.height < 700;

    return Padding(
      padding: EdgeInsets.only(
        top: topPadding + 64,
        bottom: 190,
      ),
      child: Center(
        child: SizedBox(
          width: isCompact ? 255 : 280,
          height: isCompact ? 255 : 280,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Tilted Vibrant Backing Tile (Reference Image 2 & Image 1)
              Positioned.fill(
                child: Transform.rotate(
                  angle: 0.08,
                  child: Container(
                    decoration: BoxDecoration(
                      color: slide.tileBackingColor,
                      borderRadius: BorderRadius.circular(44),
                      boxShadow: [
                        BoxShadow(
                          color: slide.tileBackingColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.98, 0.98),
                    end: const Offset(1.03, 1.03),
                    duration: 3800.ms,
                    curve: Curves.easeInOut,
                  ),

              // 2. Second Layer Soft White Shadow Card
              Positioned.fill(
                child: Transform.rotate(
                  angle: -0.04,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(44),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Studio-Grade Pet Photography Container with Gentle Floating Physics
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      slide.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF8FAFC),
                        child: Center(
                          child: Icon(
                            slide.icon,
                            size: 64,
                            color: slide.accentColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(
                    begin: -5,
                    end: 5,
                    duration: 3200.ms,
                    curve: Curves.easeInOut,
                  ),

              // 4. Floating Playful Badge (Image 3 / Image 4 style)
              Positioned(
                bottom: -10,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slide.badgeEmoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        slide.badge,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF16171B),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 150.ms)
                    .scale(
                      begin: const Offset(0.75, 0.75),
                      end: const Offset(1, 1),
                      curve: Curves.elasticOut,
                    ),
              ),

              // 5. Floating Top Heart Badge
              Positioned(
                top: -8,
                left: -6,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '❤️',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 250.ms)
                    .scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1, 1),
                      curve: Curves.elasticOut,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The signature Matte Black Pill Button with Circular Accent Icon (Reference Images 2 & 4).
class _SignaturePillButton extends StatefulWidget {
  const _SignaturePillButton({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_SignaturePillButton> createState() => _SignaturePillButtonState();
}

class _SignaturePillButtonState extends State<_SignaturePillButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 6, 6, 6),
          decoration: BoxDecoration(
            color: const Color(0xFF16171B),
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16171B).withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 14),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 19,
                  color: const Color(0xFF16171B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
