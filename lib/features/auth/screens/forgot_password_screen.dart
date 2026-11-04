import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/core/widgets/canivue_paw_bone_logo.dart';
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

    const primaryText = Color(0xFF16171B);
    const secondaryText = Color(0xFF64748B);
    const violetAccent = Color(0xFF8B5CF6);
    const yellowAccent = Color(0xFFFFD166);

    return Scaffold(
      backgroundColor: const Color(0xFFC77DFF),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF23162C),
                    Color(0xFF16171B),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFC77DFF), // Dreamy Violet (Slide 3 style)
                    Color(0xFFE0AAFF),
                    Color(0xFFFAF5FF),
                  ],
                ),
        ),
        child: Stack(
          children: [
            // Background Watermark Paw Prints
            Positioned(
              top: -20,
              right: -30,
              child: Opacity(
                opacity: 0.08,
                child: Transform.rotate(
                  angle: 0.35,
                  child: const CanivuePawBoneLogo(
                    size: 210,
                    color: primaryText,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 140,
              left: -40,
              child: Opacity(
                opacity: 0.06,
                child: Transform.rotate(
                  angle: -0.25,
                  child: const CanivuePawBoneLogo(
                    size: 190,
                    color: primaryText,
                  ),
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top Hero Section: Back Button + Corgi Key Mascot
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.06),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                                color: primaryText,
                              ),
                            ),
                          ),
                        ),

                        // Corgi Mascot with Golden Key & Tilted Yellow Tile
                        const AuthTopMascot(
                          imageAsset: 'assets/images/auth/auth_dog_forgot.jpg',
                          badgeText: 'Key Recovery',
                          badgeEmoji: '🔑',
                          tileColor: yellowAccent,
                          avatarSize: 72,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Bottom Curved Sheet Card (Flush to Bottom)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF182029) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(38),
                          topRight: Radius.circular(38),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 28,
                            offset: Offset(0, -6),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title & Subtitle
                                Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : primaryText,
                                    letterSpacing: -0.6,
                                  ),
                                ).animate().fadeIn(delay: 60.ms).slideY(begin: 0.08, end: 0),

                                const SizedBox(height: 3),

                                Text(
                                  "We'll send an instant code to recover your dog's records",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryText,
                                  ),
                                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08, end: 0),

                                const SizedBox(height: 18),

                                // Email Input
                                CustomTextField(
                                  label: 'Account Email',
                                  hintText: 'Enter your registered email',
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

                                // Helpful Reassurance Pill
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
