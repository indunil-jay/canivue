import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/features/home/domain/dashboard_summary.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/health_check/screens/health_check_capture_screen.dart';

/// Reimagined Hero Pet Promotional Card for Canivue's Flagship Feature:
/// Multimodal Canine AI Health Scanner.
///
/// Highlights:
/// - Radiant Warm Honey Amber & Sunlit Gold gradient backplate
/// - High-resolution pet portrait with playful layered offset backing & "AI Ready" indicator
/// - Multimodal AI feature promotion badge with glowing sparkle icon
/// - Compelling AI triage headline and early-symptom description
/// - Prominent "Launch AI Scanner ➔" action pill
/// - Tapping anywhere on the banner navigates directly to [HealthCheckCaptureScreen],
///   where users can select their pet profile and perform diagnostics.
/// - Apple-style press scaling (scale 0.97)
class HomeHeroPetCard extends StatefulWidget {
  const HomeHeroPetCard({
    super.key,
    required this.dog,
    required this.dogs,
    this.summary,
  });

  final Pet dog;
  final List<Pet> dogs;
  final DashboardSummary? summary;

  @override
  State<HomeHeroPetCard> createState() => _HomeHeroPetCardState();
}

class _HomeHeroPetCardState extends State<HomeHeroPetCard> {
  bool _isPressed = false;

  void _openScanner(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthCheckCaptureScreen(
          pets: widget.dogs,
          initialPet: widget.dog,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Card background: Warm Sunny Amber in light mode, deep luminous amber-charcoal in dark
    final cardGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF2C2417), Color(0xFF1E1C18), Color(0xFF15171C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFFFED25E), // Sunshine Honey Gold
              Color(0xFFFDC64A),
              Color(0xFFFFB638),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final textColor = isDark ? Colors.white : const Color(0xFF181A20);
    final subtitleColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF3B3323);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => _openScanner(context),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: cardGradient,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? const Color(0x33FED25E) : const Color(0x66FFFFFF),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : const Color(0x33F59E0B),
                blurRadius: 28,
                offset: const Offset(0, 12),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle background circle motifs
              Positioned(
                top: -20,
                right: -20,
                child: Opacity(
                  opacity: isDark ? 0.08 : 0.14,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -35,
                left: 40,
                child: Opacity(
                  opacity: isDark ? 0.05 : 0.09,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: AI Feature Badge + Circular Arrow Launch Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5.5),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0x33FFFFFF)
                                : Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 13,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'MULTIMODAL AI 2.0',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                  color: const Color(0xFF181A20),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Circular arrow button (Pawsure signature ↗)
                        Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF242A38) : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_outward_rounded,
                            size: 18,
                            color: Color(0xFF181A20),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Middle content: Headline, description, CTA button + Pet portrait with AI badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instant Canine\nAI Health Scan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                  height: 1.15,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Early visual triage across eyes, coat, skin, and gait powered by veterinary AI.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: subtitleColor,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Dedicated "Launch AI Scanner" CTA button wrapped with FittedBox to prevent overflow
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF242A38) : const Color(0xFF181A20),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.document_scanner_rounded,
                                        color: Color(0xFFFED25E),
                                        size: 15,
                                      ),
                                      const SizedBox(width: 7),
                                      Text(
                                        'Launch AI Scanner',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Pet portrait with rounded frame, offset backing, and "AI Ready" indicator
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Offset playful backplate
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0x336C63FF)
                                        : const Color(0xFFFFAE33),
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                ),
                              ),
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(26),
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: widget.dog.assetImagePath != null
                                      ? Image.asset(
                                          widget.dog.assetImagePath!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Center(
                                            child: Text(widget.dog.avatarEmoji, style: const TextStyle(fontSize: 36)),
                                          ),
                                        )
                                      : Container(
                                          color: const Color(0xFFFFF9EE),
                                          child: Center(
                                            child: Text(widget.dog.avatarEmoji, style: const TextStyle(fontSize: 36)),
                                          ),
                                        ),
                                ),
                              ),
                              // Floating AI Ready chip at bottom of avatar
                              Positioned(
                                bottom: -7,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF181A20),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFFED25E), width: 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 5.5,
                                          height: 5.5,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'AI Ready',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
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
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
