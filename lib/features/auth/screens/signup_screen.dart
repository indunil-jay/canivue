import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/core/widgets/canivue_paw_bone_logo.dart';
import 'package:canivue/features/auth/domain/app_user.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/auth/screens/otp_verification_screen.dart';
import 'package:canivue/features/auth/widgets/auth_hero_header.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';
import 'package:canivue/features/auth/widgets/signature_auth_button.dart';

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
  bool _obscureConfirmPassword = true;
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

    await Future.delayed(const Duration(milliseconds: 700));

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

    const primaryText = Color(0xFF16171B);
    const secondaryText = Color(0xFF64748B);
    const tealAccent = Color(0xFF0D9488);
    const orangeAccent = Color(0xFFFF9F1C);
    final pwStrength = _calculatePasswordStrength(_passwordController.text);

    return Scaffold(
      backgroundColor: const Color(0xFF4ECDC4),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF122422),
                    Color(0xFF16171B),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4ECDC4), // Vibrant Teal Mint (Slide 2 style)
                    Color(0xFF68D8D6),
                    Color(0xFFE4F9F6),
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
                  // Top Hero Section: Back Button + Mascot
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Back Button
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

                        // Dedicated Frenchie Mascot with Tilted Orange Tile
                        const AuthTopMascot(
                          imageAsset: 'assets/images/auth/auth_dog_signup.jpg',
                          badgeText: 'New Pack Member',
                          badgeEmoji: '🐾',
                          tileColor: orangeAccent,
                          avatarSize: 70,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Bottom Curved Sheet Card (Flush to Bottom, No Gap!)
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
                          padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title & Subtitle
                                Text(
                                  'Join the Pack',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : primaryText,
                                    letterSpacing: -0.6,
                                  ),
                                ).animate().fadeIn(delay: 60.ms).slideY(begin: 0.08, end: 0),

                                const SizedBox(height: 3),

                                Text(
                                  'Create an account for proactive canine health',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryText,
                                  ),
                                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08, end: 0),

                                const SizedBox(height: 12),

                                // Role Selector Pill
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
                                          activeColor: orangeAccent,
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
                                          activeColor: tealAccent,
                                          onTap: () {
                                            setState(() {
                                              _selectedRole = UserRole.veterinarian;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(delay: 120.ms),

                                const SizedBox(height: 12),

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
                                const SizedBox(height: 10),

                                // Email Address Input
                                CustomTextField(
                                  label: 'Email Address',
                                  hintText: 'e.g. alex@example.com',
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
                                const SizedBox(height: 10),

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
                                                          ? orangeAccent
                                                          : tealAccent)
                                                  : const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 10),

                                // Confirm Password Input
                                CustomTextField(
                                  label: 'Confirm Password',
                                  hintText: 'Re-enter your password',
                                  prefixIcon: Icons.lock_reset_rounded,
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  focusAccentColor: tealAccent,
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
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),

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
                                          activeColor: primaryText,
                                          checkColor: Colors.white,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          side: const BorderSide(
                                            color: Color(0xFFCBD5E1),
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
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              color: secondaryText,
                                              height: 1.25,
                                            ),
                                            children: const [
                                              TextSpan(text: 'I agree to the '),
                                              TextSpan(
                                                text: 'Terms',
                                                style: TextStyle(
                                                  color: tealAccent,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              TextSpan(text: ' & '),
                                              TextSpan(
                                                text: 'Privacy Policy',
                                                style: TextStyle(
                                                  color: tealAccent,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Signature Pill Button with Tangerine Badge
                                SignatureAuthButton(
                                  label: 'Create Account',
                                  icon: Icons.arrow_forward_rounded,
                                  accentColor: orangeAccent,
                                  isLoading: _isLoading,
                                  onTap: _handleSignUp,
                                ),
                                const SizedBox(height: 12),

                                // Already Have Account Link
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
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Log In',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: tealAccent,
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF16171B) : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? activeColor : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
