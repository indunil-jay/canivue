import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/domain/app_user.dart';
import 'package:canivue/features/auth/domain/auth_theme_palette.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/auth/screens/otp_verification_screen.dart';
import 'package:canivue/features/auth/widgets/ambient_auth_backdrop.dart';
import 'package:canivue/features/auth/widgets/auth_form_card.dart';
import 'package:canivue/features/auth/widgets/auth_hero_header.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';
import 'package:canivue/features/auth/widgets/signature_auth_button.dart';
import 'package:canivue/features/auth/widgets/social_auth_button.dart';

/// Redesigned Sign Up Screen for Canivue.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.dogOwner;
  bool _obscurePassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      AppFeedback.showToast(
        context,
        title: 'Terms of Service',
        message: 'Please accept the Terms of Service & Privacy Policy to continue.',
        type: ToastType.warning,
      );
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

    final email = _emailController.text.trim();
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Alex';
    final role = _selectedRole;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          email: email,
          onVerified: () {
            ref.read(authControllerProvider.notifier).signUp(
                  email: email,
                  name: name,
                  role: role,
                );
            if (role == UserRole.veterinarian) {
              context.go('/vet-dashboard');
            } else {
              context.go('/home');
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF16171B);
    final secondaryText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const palette = AuthThemePalette.sunlitAmber;
    final tealAccent = palette.accentColor;
    final pwStrength = _calculatePasswordStrength(_passwordController.text);

    return AmbientAuthBackdrop(
      palette: palette,
      showBack: true,
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        children: [
          // 1. Warm Sunlit Amber Hero Section with Large Mascot (No Tags)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
            child: AuthTopMascot(
              imageAsset: 'assets/images/auth/cutout_dog_signup.png',
              shadowColor: palette.shadowColor,
              tileColor: palette.tileColor,
              avatarSize: 145,
            ),
          ),

          // 2. Bottom Form Card
          Expanded(
            child: AuthFormCard(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Headline
                    Text(
                      'Create an Account',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        color: primaryText,
                        letterSpacing: -0.6,
                      ),
                    ).animate().fadeIn(duration: 250.ms),

                    const SizedBox(height: 3),

                    Text(
                      'Create an account for proactive canine health',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: secondaryText,
                      ),
                    ).animate().fadeIn(delay: 50.ms, duration: 250.ms),

                    const SizedBox(height: 12),

                    // Role Selector Pill (Apple Segmented Style)
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF222B36) : const Color(0xFFEFF5F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white10 : const Color(0xFFDCE8E2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _CompactRoleTab(
                              label: 'Dog Parent',
                              icon: Icons.pets_rounded,
                              isSelected: _selectedRole == UserRole.dogOwner,
                              activeColor: palette.accentColor,
                              onTap: () {
                                setState(() {
                                  _selectedRole = UserRole.dogOwner;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: _CompactRoleTab(
                              label: 'Veterinarian',
                              icon: Icons.medical_services_rounded,
                              isSelected: _selectedRole == UserRole.veterinarian,
                              activeColor: palette.tileColor,
                              onTap: () {
                                setState(() {
                                  _selectedRole = UserRole.veterinarian;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Full Name Input
                    CustomTextField(
                      label: 'Full Name',
                      hintText: 'e.g. Alex Morgan',
                      prefixIcon: Icons.person_outline_rounded,
                      controller: _nameController,
                      focusAccentColor: tealAccent,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    // Email Address Input
                    CustomTextField(
                      label: 'Email Address',
                      hintText: 'e.g. alex@canivue.com',
                      prefixIcon: Icons.alternate_email_rounded,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      focusAccentColor: tealAccent,
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

                    const SizedBox(height: 8),

                    // Password Input
                    CustomTextField(
                      label: 'Password',
                      hintText: 'Min 6 characters',
                      prefixIcon: Icons.lock_outline_rounded,
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      focusAccentColor: tealAccent,
                      onChanged: (val) => setState(() {}),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF64748B),
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please create a password';
                        }
                        if (value.length < 6) {
                          return 'At least 6 characters required';
                        }
                        return null;
                      },
                    ),

                    // Password Strength Indicator
                    if (_passwordController.text.isNotEmpty) ...[
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

                    // Confirm Password Input
                    const SizedBox(height: 8),
                    CustomTextField(
                      label: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      prefixIcon: Icons.lock_reset_rounded,
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      focusAccentColor: tealAccent,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    // Terms & Privacy Checkbox
                    InkWell(
                      onTap: () {
                        setState(() {
                          _acceptTerms = !_acceptTerms;
                        });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 18,
                            width: 18,
                            child: Checkbox(
                              value: _acceptTerms,
                              activeColor: palette.accentColor,
                              checkColor: Colors.white,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              side: BorderSide(
                                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                                width: 1.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _acceptTerms = val ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'I agree to Canivue Terms of Service & Privacy Policy',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Primary Create Account Button
                    SignatureAuthButton(
                          label: 'Sign Up',
                          icon: Icons.pets_rounded,
                          accentColor: palette.buttonAccent,
                          isLoading: _isLoading,
                          height: 52,
                          onTap: _handleSignUp,
                        ),

                    const SizedBox(height: 18),

                    // Divider with Label: ─── or continue with ───
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'or continue with',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: secondaryText,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Social Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: CompactSocialButton(
                            label: 'Google',
                            icon: Icons.g_mobiledata_rounded,
                            height: 48,
                            onTap: () {
                              AppFeedback.showToast(
                                context,
                                title: 'Google Sign Up',
                                message: 'Connecting to Google Authentication...',
                                type: ToastType.info,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CompactSocialButton(
                            label: 'Apple',
                            icon: Icons.apple_rounded,
                            height: 48,
                            onTap: () {
                              AppFeedback.showToast(
                                context,
                                title: 'Apple Sign Up',
                                message: 'Connecting to Apple ID...',
                                type: ToastType.info,
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Already Have Account Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
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
                            'Sign In',
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

class _CompactRoleTab extends StatelessWidget {
  const _CompactRoleTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2D3748) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? activeColor : const Color(0xFF64748B),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : const Color(0xFF16171B))
                    : const Color(0xFF64748B),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
