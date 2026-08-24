import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
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
    this.maxLines = 1,
    this.isGlass = true,
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
  final int maxLines;
  final bool isGlass;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final labelColor = isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF334155);
    final hintColor = isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF94A3B8);
    final fillColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.18) : const Color(0xFFCBD5E1);
    final prefixIconColor = isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: labelColor,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          maxLines: obscureText ? 1 : maxLines,
          style: GoogleFonts.plusJakartaSans(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.plusJakartaSans(
              color: hintColor,
              fontSize: 14,
            ),
            prefixIcon: maxLines > 1
                ? null
                : Icon(
                    prefixIcon,
                    color: prefixIconColor,
                    size: 20,
                  ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
