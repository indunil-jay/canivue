import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';

class TelehealthCallDialog extends StatefulWidget {
  const TelehealthCallDialog({
    super.key,
    required this.vetName,
    required this.vetInitials,
    required this.isVideo,
  });

  final String vetName;
  final String vetInitials;
  final bool isVideo;

  static void show(BuildContext context, {
    required String vetName,
    required String vetInitials,
    bool isVideo = true,
  }) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Telehealth Call',
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, anim1, anim2) {
        return TelehealthCallDialog(
          vetName: vetName,
          vetInitials: vetInitials,
          isVideo: isVideo,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  State<TelehealthCallDialog> createState() => _TelehealthCallDialogState();
}

class _TelehealthCallDialogState extends State<TelehealthCallDialog> {
  int _seconds = 0;
  Timer? _timer;
  bool _muted = false;
  bool _cameraOff = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime() {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D13),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Video Stream Simulation
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F1E29), Color(0xFF060D13)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.45),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.vetInitials,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 38,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.vetName,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 8,
                            width: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isVideo ? 'Live Telehealth Video (${_formatTime()})' : 'Voice Call (${_formatTime()})',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Encrypted End-to-End Clinical Stream',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // PiP Local Self-View (Corner)
            if (widget.isVideo)
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  height: 140,
                  width: 95,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2A36),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_rounded, color: Colors.white54, size: 28),
                        const SizedBox(height: 4),
                        Text(
                          'You (Owner)',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom Call Controls (Apple FaceTime Style)
            Positioned(
              left: 24,
              right: 24,
              bottom: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _callButton(
                      icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      active: _muted,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _muted = !_muted);
                      },
                    ),
                    if (widget.isVideo)
                      _callButton(
                        icon: _cameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                        active: _cameraOff,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _cameraOff = !_cameraOff);
                        },
                      ),
                    _callButton(
                      icon: Icons.switch_camera_rounded,
                      onTap: () => HapticFeedback.selectionClick(),
                    ),
                    // End Call
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 52,
                        width: 52,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 26),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _callButton({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: active ? const Color(0xFF0F172A) : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
