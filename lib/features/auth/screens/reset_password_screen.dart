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

    const primaryText = Color(0xFF16171B);
    const secondaryText = Color(0xFF475569);
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
            // Watermark Paw Prints
            Positioned(
              top: -20,
              right: -30,
              child: Opacity(
                opacity: 0.08,
                child: Transform.rotate(
                  angle: 0.35,
                  child: const CanivuePawBoneLogo(
                    size: 220,
                    color: primaryText,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: -40,
              child: Opacity(
                opacity: 0.06,
                child: Transform.rotate(
                  angle: -0.28,
                  child: const CanivuePawBoneLogo(
                    size: 200,
                    color: primaryText,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Stack(
                children: [
                  // Back Button Pill
                  Positioned(
                    top: 10,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.06),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: primaryText,
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 38),

                              // Expressive Hero Avatar & Titles
                              const AuthHeroHeader(
                                imageAsset: 'assets/images/pets/max.jpg',
                                tileColor: honeyAccent,
                                badgeText: 'Vault Secured',
                                badgeEmoji: '🛡️',
                                title: 'Set New Password',
                                subtitle: 'Choose a strong password to protect your dog\'s profile',
                                titleColor: primaryText,
                                subtitleColor: secondaryText,
                              ),
                              const SizedBox(height: 24),

                              // Crisp White Form Card
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E252E) : Colors.white,
                                  borderRadius: BorderRadius.circular(34),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF16171B).withValues(alpha: 0.09),
                                      blurRadius: 32,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // New Password Input
                                    CustomTextField(
                                      label: 'New Password',
                                      hintText: 'Enter new password (min 6 chars)',
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
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureNewPassword = !_obscureNewPassword;
                                          });
                                        },
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a new password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    if (_newPasswordController.text.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          for (int i = 1; i <= 4; i++)
                                            Expanded(
                                              child: Container(
                                                height: 4,
                                                margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
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
                                    const SizedBox(height: 16),

                                    // Confirm New Password Input
                                    CustomTextField(
                                      label: 'Confirm New Password',
                                      hintText: 'Re-enter new password',
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
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword = !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your new password';
                                        }
                                        if (value != _newPasswordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),

                                    // Reset Password Submit Button
                                    SignatureAuthButton(
                                      label: 'Update Password',
                                      icon: Icons.check_rounded,
                                      accentColor: honeyAccent,
                                      isLoading: _isLoading,
                                      onTap: _handleResetPassword,
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08, end: 0),
                            ],
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
