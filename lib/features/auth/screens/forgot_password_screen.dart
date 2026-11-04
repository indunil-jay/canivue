import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/screens/otp_verification_screen.dart';
import 'package:canivue/features/auth/widgets/auth_hero_header.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';
import 'package:canivue/features/auth/widgets/signature_auth_button.dart';

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
    const violetAccent = Color(0xFF8B5CF6);
    const yellowAccent = Color(0xFFFFD166);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101418) : const Color(0xFFF8FAF9),
      body: SafeArea(
        child: Stack(
          children: [
            // Compact Back Pill
            Positioned(
              top: 8,
              left: 14,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C222A) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: primaryText,
                  ),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 18),

                        // Animated Corgi with Golden Key Mascot
                        AuthHeroHeader(
                          imageAsset: 'assets/images/auth/auth_dog_forgot.jpg',
                          badgeText: 'Key Recovery',
                          badgeEmoji: '🔑',
                          title: 'Forgot Password?',
                          subtitle: "We'll send an instant code to recover your dog's profile",
                          titleColor: primaryText,
                          subtitleColor: secondaryText,
                          accentColor: violetAccent,
                          avatarSize: 68,
                        ),
                        const SizedBox(height: 18),

                        // Crisp Form Card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF182029) : Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isDark ? Colors.white10 : const Color(0xFFEBF0ED),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF16171B).withValues(alpha: isDark ? 0.3 : 0.05),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Email Address Input
                              CustomTextField(
                                label: 'Registered Email',
                                hintText: 'e.g. alex@canivue.com',
                                prefixIcon: Icons.alternate_email_rounded,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                focusAccentColor: violetAccent,
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
                              const SizedBox(height: 14),

                              // Reassurance Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF221A30) : const Color(0xFFFAF5FF),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: violetAccent.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: yellowAccent,
                                      ),
                                      child: const Icon(
                                        Icons.security_rounded,
                                        size: 13,
                                        color: Color(0xFF16171B),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Instant 6-digit verification code will be dispatched securely.",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: secondaryText,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Send Code Submit Button
                              SignatureAuthButton(
                                label: 'Send Recovery Code',
                                icon: Icons.arrow_forward_rounded,
                                accentColor: yellowAccent,
                                isLoading: _isLoading,
                                onTap: _handleSendCode,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.06, end: 0),
                        const SizedBox(height: 16),

                        // Back to Sign In Link
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
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Log In',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: violetAccent,
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
            ),
          ],
        ),
      ),
    );
  }
}
