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
    const secondaryText = Color(0xFF475569);
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
                    Color(0xFF4ECDC4), // Vibrant Teal Mint
                    Color(0xFF68D8D6),
                    Color(0xFFE4F9F6),
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

                              // Expressive Hero Avatar & Titles (Image 2 Style)
                              const AuthHeroHeader(
                                imageAsset: 'assets/images/onboarding/dog_slide_2.jpg',
                                tileColor: orangeAccent,
                                badgeText: 'New Pack Member',
                                badgeEmoji: '🐾',
                                title: 'Join the Pack',
                                subtitle: 'Create an account to protect your dog with AI telemetry',
                                titleColor: primaryText,
                                subtitleColor: secondaryText,
                              ),
                              const SizedBox(height: 20),

                              // Role Selection Cards
                              Row(
                                children: [
                                  Expanded(
                                    child: _RoleCard(
                                      label: 'Dog Parent',
                                      sublabel: 'Personal Care',
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
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _RoleCard(
                                      label: 'Veterinarian',
                                      sublabel: 'Clinical Portal',
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
                              ).animate().fadeIn(delay: 180.ms),
                              const SizedBox(height: 20),

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
                                    const SizedBox(height: 16),

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
                                    const SizedBox(height: 16),

                                    // Password Input
                                    CustomTextField(
                                      label: 'Password',
                                      hintText: 'Create a password (min 6 chars)',
                                      prefixIcon: Icons.lock_outline_rounded,
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      focusAccentColor: tealAccent,
                                      onChanged: (val) {
                                        setState(() {});
                                      },
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: const Color(0xFF64748B),
                                          size: 20,
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
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                    if (_passwordController.text.isNotEmpty) ...[
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
                                                              ? orangeAccent
                                                              : tealAccent)
                                                      : const Color(0xFFE2E8F0),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        pwStrength <= 1
                                            ? 'Weak password'
                                            : pwStrength <= 2
                                                ? 'Fair password'
                                                : pwStrength == 3
                                                    ? 'Good password'
                                                    : 'Strong password 💪',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: pwStrength <= 1
                                              ? const Color(0xFFEF4444)
                                              : pwStrength <= 2
                                                  ? orangeAccent
                                                  : tealAccent,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),

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
                                          return 'Please confirm your password';
                                        }
                                        if (value != _passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Terms & Privacy Checkbox
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _acceptTerms = !_acceptTerms;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(6),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: Checkbox(
                                              value: _acceptTerms,
                                              activeColor: primaryText,
                                              checkColor: Colors.white,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize.shrinkWrap,
                                              side: const BorderSide(
                                                color: Color(0xFFCBD5E1),
                                                width: 1.5,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              onChanged: (val) {
                                                setState(() {
                                                  _acceptTerms = val ?? false;
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text.rich(
                                              TextSpan(
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 12.5,
                                                  color: secondaryText,
                                                  height: 1.35,
                                                ),
                                                children: const [
                                                  TextSpan(text: 'I agree to the '),
                                                  TextSpan(
                                                    text: 'Terms of Service',
                                                    style: TextStyle(
                                                      color: tealAccent,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                  TextSpan(text: ' and '),
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
                                    const SizedBox(height: 22),

                                    // Signature Pill Button with Tangerine Badge
                                    SignatureAuthButton(
                                      label: 'Create Account',
                                      icon: Icons.arrow_forward_rounded,
                                      accentColor: orangeAccent,
                                      isLoading: _isLoading,
                                      onTap: _handleSignUp,
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: 220.ms).slideY(begin: 0.08, end: 0),
                              const SizedBox(height: 22),

                              // Already Have Account Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: primaryText.withValues(alpha: 0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Log In',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        color: primaryText,
                                        decoration: TextDecoration.underline,
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
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF16171B) : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.28)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? const Color(0xFF16171B) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : const Color(0xFF16171B),
                    ),
                  ),
                  Text(
                    sublabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white70 : const Color(0xFF94A3B8),
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
