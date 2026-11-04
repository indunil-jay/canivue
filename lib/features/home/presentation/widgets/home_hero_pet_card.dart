import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/features/home/domain/dashboard_summary.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/pets/screens/pet_detail_screen.dart';
import 'package:canivue/features/health_check/screens/health_check_capture_screen.dart';

/// Reimagined Hero Pet Showcase Card inspired by Pawsure, PawAdopt, and PawMate.
///
/// Features:
/// - Radiant Warm Honey Amber & Sunlit Peach gradient backplate
/// - High-resolution pet portrait with playful layered offset backing
/// - Live AI Guardian telemetry badge with glowing status dot
/// - Floating frosted glass info bar (Due date / vitals / price / score)
/// - Directional arrow `↗` button with micro-bounce
/// - Apple-style press scaling (scale 0.96)
class HomeHeroPetCard extends StatefulWidget {
  const HomeHeroPetCard({
    super.key,
    required this.dog,
    required this.dogs,
    required this.summary,
  });

  final Pet dog;
  final List<Pet> dogs;
  final DashboardSummary summary;

  @override
  State<HomeHeroPetCard> createState() => _HomeHeroPetCardState();
}

class _HomeHeroPetCardState extends State<HomeHeroPetCard> {
  bool _isPressed = false;

  void _openPetDetail(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PetDetailScreen(pet: widget.dog)),
    );
  }

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
              Color(0xFFFED25E), // Sunshine Honey Gold (Pawsure reference)
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
      onTap: () => _openPetDetail(context),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: cardGradient,
            borderRadius: BorderRadius.circular(32),
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
              // Subtle background circle motif
              Positioned(
                top: -15,
                right: -15,
                child: Opacity(
                  opacity: isDark ? 0.08 : 0.12,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: AI Status Badge + Action Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0x33FFFFFF)
                                : Colors.white.withValues(alpha: 0.85),
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
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Guardian Synced',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF181A20),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Circular arrow button (Pawsure signature ↗)
                        GestureDetector(
                          onTap: () => _openScanner(context),
                          child: Container(
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
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Middle content: Pet headline + portrait
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Keep ${widget.dog.name}\nSafe & Happy',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                  height: 1.15,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${widget.dog.breed} • ${widget.dog.ageYears}y ${widget.dog.ageMonths}m\n${widget.dog.weightKg.toStringAsFixed(1)} kg weight',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: subtitleColor,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Pet portrait with rounded frame & offset backing
                        Expanded(
                          flex: 4,
                          child: Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Offset playful backplate
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    width: 104,
                                    height: 104,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0x336C63FF)
                                          : const Color(0xFFFFAE33),
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 104,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
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
                                    borderRadius: BorderRadius.circular(26),
                                    child: widget.dog.assetImagePath != null
                                        ? Image.asset(
                                            widget.dog.assetImagePath!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) => Center(
                                              child: Text(widget.dog.avatarEmoji, style: const TextStyle(fontSize: 40)),
                                            ),
                                          )
                                        : Container(
                                            color: const Color(0xFFFFF9EE),
                                            child: Center(
                                              child: Text(widget.dog.avatarEmoji, style: const TextStyle(fontSize: 40)),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Floating frosted glass footer pill (Pawsure & Pupora inspired)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0x4016181F)
                                : Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0x33FFFFFF)
                                  : Colors.white.withValues(alpha: 0.8),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _TelemetryItem(
                                label: 'Heart Rate',
                                value: '${widget.summary.vitals.heartRateBpm} bpm',
                                isDark: isDark,
                              ),
                              Container(height: 22, width: 1, color: isDark ? const Color(0x33FFFFFF) : const Color(0x33181A20)),
                              _TelemetryItem(
                                label: 'Temperature',
                                value: '${widget.summary.vitals.temperatureC.toStringAsFixed(1)}°C',
                                isDark: isDark,
                              ),
                              Container(height: 22, width: 1, color: isDark ? const Color(0x33FFFFFF) : const Color(0x33181A20)),
                              _TelemetryItem(
                                label: 'Health Score',
                                value: '${widget.summary.healthScore}%',
                                isDark: isDark,
                                isAccent: true,
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
        ),
      ),
    );
  }
}

class _TelemetryItem extends StatelessWidget {
  const _TelemetryItem({
    required this.label,
    required this.value,
    required this.isDark,
    this.isAccent = false,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF57534E),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isAccent
                ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E))
                : (isDark ? Colors.white : const Color(0xFF181A20)),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
