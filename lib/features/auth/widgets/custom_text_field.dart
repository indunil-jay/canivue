import 'package:flutter/material.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isGlass ? Colors.white.withValues(alpha: 0.9) : theme.colorScheme.onSurfaceVariant,
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
          style: TextStyle(
            color: isGlass ? Colors.white : const Color(0xFF0F172A),
            fontSize: 15,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isGlass
                  ? Colors.white.withValues(alpha: 0.5)
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            prefixIcon: maxLines > 1
                ? null
                : Icon(
                    prefixIcon,
                    color: isGlass ? AppTheme.cyanAccent : theme.colorScheme.primary,
                    size: 20,
                  ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isGlass
                ? Colors.white.withValues(alpha: 0.12)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isGlass ? Colors.white.withValues(alpha: 0.2) : theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isGlass ? Colors.white.withValues(alpha: 0.2) : theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isGlass ? AppTheme.cyanAccent : theme.colorScheme.primary,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
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
