import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ergonomic Social Auth Button with 120ms Apple Press Scale
class CompactSocialButton extends StatefulWidget {
  const CompactSocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.height = 48.0,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double height;

  @override
  State<CompactSocialButton> createState() => _CompactSocialButtonState();
}

class _CompactSocialButtonState extends State<CompactSocialButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Sign in with ${widget.label}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF222B36) : const Color(0xFFF8FAF9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: isDark ? Colors.white : const Color(0xFF16171B),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? Colors.white : const Color(0xFF16171B),
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
