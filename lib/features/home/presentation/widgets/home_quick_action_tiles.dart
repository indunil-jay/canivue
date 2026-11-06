import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/widgets/canivue_paw_bone_logo.dart';
import 'package:canivue/features/health_check/screens/health_check_capture_screen.dart';
import 'package:canivue/features/devices/presentation/screens/device_management_screen.dart';
import 'package:canivue/features/pets/models/pet_model.dart';

/// Side-by-side punchy action cards directly inspired by Image 1 (Pawsure).
///
/// Features:
/// - Tile 1: Obsidian Charcoal Black with bone silhouette watermark and white plus button
/// - Tile 2: Vivid Royal Indigo/Violet with telemetry/molecule watermark and white plus button
/// - Apple-style press scaling (scale 0.96)
/// - High tactile delight and instant feedback
class HomeQuickActionTiles extends StatelessWidget {
  const HomeQuickActionTiles({
    super.key,
    required this.dog,
    required this.dogs,
  });

  final Pet dog;
  final List<Pet> dogs;

  void _onLaunchScan(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HealthCheckCaptureScreen(pets: dogs, initialPet: dog),
      ),
    );
  }

  void _onCollarTelemetry(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceManagementScreen(dogId: dog.id, dogName: dog.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tile 1: AI Health Scan (Obsidian Black)
        Expanded(
          child: _ActionTile(
            title: 'AI Health\nScanner',
            subtitle: 'Multimodal Vision',
            backgroundColor: const Color(0xFF16181F),
            accentWatermark: const CanivuePawBoneLogo(
              size: 110,
              color: Color(0x1AFFFFFF),
            ),
            icon: Icons.document_scanner_rounded,
            onTap: () => _onLaunchScan(context),
          ),
        ),
        const SizedBox(width: 14),
        // Tile 2: Log Collar Telemetry (Vivid Royal Indigo)
        Expanded(
          child: _ActionTile(
            title: 'Collar\nTelemetry',
            subtitle: 'Sync Biometrics',
            backgroundColor: const Color(0xFF6C63FF),
            accentWatermark: Opacity(
              opacity: 0.16,
              child: const Icon(
                Icons.sensors_rounded,
                size: 110,
                color: Colors.white,
              ),
            ),
            icon: Icons.bluetooth_searching_rounded,
            onTap: () => _onCollarTelemetry(context),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatefulWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.icon,
    required this.onTap,
    this.accentWatermark,
  });

  final String title;
  final String subtitle;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? accentWatermark;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 144,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Stack(
            children: [
              if (widget.accentWatermark != null)
                Positioned(
                  right: -14,
                  bottom: -14,
                  child: IgnorePointer(child: widget.accentWatermark!),
                ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.15,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 22,
                          color: widget.backgroundColor,
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
