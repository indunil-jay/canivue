import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern Warm Form Field for Canivue Authentication.
///
/// Refined with soft squircle borders, dynamic focus elevation,
/// crisp Plus Jakarta Sans typography, and friendly dog-care aesthetics.
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.maxLines = 1,
    this.isGlass = false,
    this.focusNode,
    this.focusAccentColor = const Color(0xFF10B981),
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool isGlass;
  final FocusNode? focusNode;
  final Color focusAccentColor;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _internalFocus = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _internalFocus = true;
    }
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_internalFocus) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeAccent = widget.focusAccentColor;
    final textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF16171B);
    final labelColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
    final hintColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final fillColor = isDark ? const Color(0xFF1E252B) : const Color(0xFFF8FAF9);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: labelColor,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 7),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: activeAccent.withValues(alpha: isDark ? 0.28 : 0.2),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted,
            onChanged: widget.onChanged,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            style: GoogleFonts.plusJakartaSans(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: GoogleFonts.plusJakartaSans(
                color: hintColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: widget.maxLines > 1
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(left: 16, right: 10),
                      child: Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? activeAccent
                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        size: 20,
                      ),
                    ),
              prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              suffixIcon: widget.suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: widget.suffixIcon,
                    )
                  : null,
              filled: true,
              fillColor: fillColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: borderColor,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: borderColor,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: activeAccent,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 1.4,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 2,
                ),
              ),
              errorStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
