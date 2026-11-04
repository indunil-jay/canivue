import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Signature Matte Charcoal Pill Button for Canivue Authentication.
///
/// Features a dark matte pill body (`#16171B`), high-contrast white typography,
/// an accent-tinted circular icon badge, and a responsive scale-down bounce on tap.
class SignatureAuthButton extends StatefulWidget {
  const SignatureAuthButton({
    super.key,
    required this.label,
    this.icon = Icons.arrow_forward_rounded,
    this.accentColor = const Color(0xFF10B981),
    this.isLoading = false,
    this.onTap,
    this.fullWidth = true,
  });

  final String label;
  final IconData? icon;
  final Color accentColor;
  final bool isLoading;
  final VoidCallback? onTap;
  final bool fullWidth;

  @override
  State<SignatureAuthButton> createState() => _SignatureAuthButtonState();
}

class _SignatureAuthButtonState extends State<SignatureAuthButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null && !widget.isLoading;

    final buttonContent = AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: Container(
        height: 56,
        padding: const EdgeInsets.fromLTRB(24, 7, 8, 7),
        decoration: BoxDecoration(
          color: const Color(0xFF16171B),
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF16171B).withValues(alpha: 0.24),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.fullWidth ? const SizedBox(width: 8) : const SizedBox(width: 4),
            Text(
              widget.label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: widget.accentColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF16171B)),
                        ),
                      )
                    : Icon(
                        widget.icon,
                        size: 20,
                        color: const Color(0xFF16171B),
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: isEnabled ? widget.onTap : null,
      child: widget.fullWidth
          ? SizedBox(width: double.infinity, child: buttonContent)
          : buttonContent,
    );
  }
}
