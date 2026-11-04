import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
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

                        // Animated Vault Mascot
                        AuthHeroHeader(
                          imageAsset: 'assets/images/auth/auth_dog_reset.jpg',
                          badgeText: 'Vault Secured',
                          badgeEmoji: '🛡️',
                          title: 'Set New Password',
                          subtitle: 'Create a fresh strong password for your dog\'s profile',
                          titleColor: primaryText,
                          subtitleColor: secondaryText,
                          accentColor: mintAccent,
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
                                const SizedBox(height: 6),
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
                              const SizedBox(height: 18),

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
                        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.06, end: 0),
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
