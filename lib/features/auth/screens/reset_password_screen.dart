import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/core/widgets/canivue_paw_bone_logo.dart';
import 'package:canivue/features/auth/widgets/auth_hero_header.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';
import 'package:canivue/features/auth/widgets/signature_auth_button.dart';

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

    await Future.delayed(const Duration(milliseconds: 700));

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
    const mintAccent = Color(0xFF10B981);
    const honeyAccent = Color(0xFFF59E0B);
    final pwStrength = _calculatePasswordStrength(_newPasswordController.text);

    return Scaffold(
      backgroundColor: const Color(0xFF34D399),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F261E),
                    Color(0xFF16171B),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF34D399), // Radiant Emerald Mint
                    Color(0xFF10B981),
                    Color(0xFFE8FAF3),
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
                  child: CanivuePawBoneLogo(
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
                  child: CanivuePawBoneLogo(
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
                  // Top Hero Section: Back Button + Vault Mascot
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
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                                color: primaryText,
                              ),
                            ),
                          ),
                        ),

                        // Vault Mascot with Honey Tile
                        const AuthTopMascot(
                          imageAsset: 'assets/images/auth/auth_dog_reset.jpg',
                          badgeText: 'Vault Secured',
                          badgeEmoji: '🛡️',
                          tileColor: honeyAccent,
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
                                  'Set New Password',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : primaryText,
                                    letterSpacing: -0.6,
                                  ),
                                ).animate().fadeIn(delay: 60.ms).slideY(begin: 0.08, end: 0),

                                const SizedBox(height: 3),

                                Text(
                                  "Create a fresh strong password for your dog's profile",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryText,
                                  ),
                                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08, end: 0),

                                const SizedBox(height: 18),

                                // New Password Input
                                CustomTextField(
                                  label: 'New Password',
                                  hintText: 'Min 6 characters',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  controller: _newPasswordController,
                                  obscureText: _obscureNewPassword,
                                  focusAccentColor: mintAccent,
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
                                if (_newPasswordController.text.isNotEmpty) ...[
                                  const SizedBox(height: 5),
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
                                                          ? honeyAccent
                                                          : mintAccent)
                                                  : const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),

                                // Confirm New Password Input
                                CustomTextField(
                                  label: 'Confirm Password',
                                  hintText: 'Re-enter your password',
                                  prefixIcon: Icons.lock_reset_rounded,
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  focusAccentColor: mintAccent,
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
                                      return 'Please confirm password';
                                    }
                                    if (value != _newPasswordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Update Password Submit Button
                                SignatureAuthButton(
                                  label: 'Update Password',
                                  icon: Icons.check_rounded,
                                  accentColor: honeyAccent,
                                  isLoading: _isLoading,
                                  onTap: _handleResetPassword,
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
