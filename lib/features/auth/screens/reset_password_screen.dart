import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/domain/auth_theme_palette.dart';
import 'package:canivue/features/auth/widgets/ambient_auth_backdrop.dart';
import 'package:canivue/features/auth/widgets/auth_form_card.dart';
import 'package:canivue/features/auth/widgets/auth_hero_header.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';
import 'package:canivue/features/auth/widgets/signature_auth_button.dart';

/// Redesigned Reset Password Screen for Canivue.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score;
  }

  void _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    AppFeedback.showToast(
      context,
      title: 'Password Updated 🎉',
      message: 'Your password has been reset successfully. Please log in with your new credentials.',
      type: ToastType.success,
    );

    context.go('/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF16171B);
    final secondaryText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const palette = AuthThemePalette.nordicCobalt;
    final tealAccent = palette.accentColor;
    final pwStrength = _calculatePasswordStrength(_newPasswordController.text);

    return AmbientAuthBackdrop(
      palette: palette,
      showBack: true,
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        children: [
          // 1. Nordic Cobalt Hero Section with Large Mascot (No Tags)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: AuthTopMascot(
              imageAsset: 'assets/images/auth/cutout_dog_reset.png',
              shadowColor: palette.shadowColor,
              tileColor: palette.tileColor,
              avatarSize: 155,
            ),
          ),

          // 2. Bottom Form Card
          Expanded(
            child: AuthFormCard(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Headline
                    Text(
                      'Set New Password',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        color: primaryText,
                        letterSpacing: -0.6,
                      ),
                    ).animate().fadeIn(duration: 250.ms),

                    const SizedBox(height: 3),

                    Text(
                      "Create a fresh strong password for your dog's profile",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: secondaryText,
                      ),
                    ).animate().fadeIn(delay: 50.ms, duration: 250.ms),

                    const SizedBox(height: 16),

                    // New Password Input
                    CustomTextField(
                      label: 'New Password',
                      hintText: 'Min 6 characters',
                      prefixIcon: Icons.lock_outline_rounded,
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      focusAccentColor: palette.accentColor,
                      onChanged: (val) => setState(() {}),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF64748B),
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'At least 6 characters required';
                        }
                        return null;
                      },
                    ),

                    // Password Strength Indicator
                    if (_newPasswordController.text.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          for (int i = 1; i <= 4; i++)
                            Expanded(
                              child: Container(
                                height: 3,
                                margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: pwStrength >= i
                                      ? (pwStrength <= 1
                                          ? const Color(0xFFEF4444)
                                          : pwStrength <= 2
                                              ? const Color(0xFFF59E0B)
                                              : tealAccent)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Confirm New Password Input
                    CustomTextField(
                      label: 'Confirm New Password',
                      hintText: 'Re-enter your new password',
                      prefixIcon: Icons.lock_reset_rounded,
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      focusAccentColor: palette.accentColor,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF64748B),
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Save Button
                    SignatureAuthButton(
                      label: 'Reset Password',
                      icon: Icons.check_circle_rounded,
                      accentColor: palette.buttonAccent,
                      isLoading: _isLoading,
                      height: 52,
                      onTap: _handleResetPassword,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
