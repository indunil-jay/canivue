import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/domain/auth_theme_palette.dart';
import 'package:canivue/features/auth/screens/otp_verification_screen.dart';
import 'package:canivue/features/auth/widgets/ambient_auth_backdrop.dart';
import 'package:canivue/features/auth/widgets/auth_form_card.dart';
import 'package:canivue/features/auth/widgets/auth_hero_header.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';
import 'package:canivue/features/auth/widgets/signature_auth_button.dart';

/// Redesigned Forgot Password Screen for Canivue.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendCode() async {
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
      title: 'Verification Code Sent 📨',
      message: 'A 6-digit code has been sent to ${_emailController.text.trim()}',
      type: ToastType.success,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(email: _emailController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF16171B);
    final secondaryText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const palette = AuthThemePalette.auroraIndigo;

    return AmbientAuthBackdrop(
      palette: palette,
      showBack: true,
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        children: [
          // 1. Aurora Indigo Hero Section with Large Mascot (No Tags)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: AuthTopMascot(
              imageAsset: 'assets/images/auth/cutout_dog_forgot.png',
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
                      'Forgot Password?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        color: primaryText,
                        letterSpacing: -0.6,
                      ),
                    ).animate().fadeIn(duration: 250.ms),

                    const SizedBox(height: 3),

                    Text(
                      "We'll send an instant code to recover your dog's records",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: secondaryText,
                      ),
                    ).animate().fadeIn(delay: 50.ms, duration: 250.ms),

                    const SizedBox(height: 16),

                    // Email Input
                    CustomTextField(
                      label: 'Email Address',
                      hintText: 'Enter registered email address',
                      prefixIcon: Icons.alternate_email_rounded,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      focusAccentColor: palette.accentColor,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value.trim())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Helpful Security Reassurance Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF221A30) : const Color(0xFFFAF5FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: palette.accentColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: palette.accentColor,
                            ),
                            child: const Icon(
                              Icons.security_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Instant 6-digit code will be dispatched securely.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: secondaryText,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Submit Button
                    SignatureAuthButton(
                      label: 'Send Reset Link',
                      icon: Icons.arrow_forward_rounded,
                      accentColor: palette.buttonAccent,
                      isLoading: _isLoading,
                      height: 52,
                      onTap: _handleSendCode,
                    ),

                    const SizedBox(height: 22),

                    // Back to Log In Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remember your password? ',
                          style: GoogleFonts.plusJakartaSans(
                            color: secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Log In',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: palette.accentColor,
                            ),
                          ),
                        ),
                      ],
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
