import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/core/widgets/canivue_paw_bone_logo.dart';
import 'package:canivue/features/auth/domain/app_user.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/auth/screens/forgot_password_screen.dart';
import 'package:canivue/features/auth/screens/signup_screen.dart';
import 'package:canivue/features/auth/widgets/auth_hero_header.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';
import 'package:canivue/features/auth/widgets/signature_auth_button.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
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

    ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : 'alex@canivue.com',
          name: 'Alex',
        );

    if (!mounted) return;
    context.go('/home');
  }

  void _handleVetSignIn() {
    ref.read(authControllerProvider.notifier).signIn(
          email: 'sarah.jenkins@canivue.com',
          name: 'Dr. Sarah Jenkins',
          role: UserRole.veterinarian,
        );
    context.go('/vet-dashboard');
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ForgotPasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF16171B);
    final secondaryText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const amberAccent = Color(0xFFF59E0B);
    const violetAccent = Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101418) : const Color(0xFFF8FAF9),
      body: SafeArea(
        child: Center(
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
                    // Top Brand Tag
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1C222A) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CanivuePawBoneLogo(
                              size: 14,
                              color: primaryText,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'CANIVUE · CANINE CARE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 10),

                    // Dedicated 3D Mascot Header (Non-scrolling, Animated)
                    AuthHeroHeader(
                      imageAsset: 'assets/images/auth/auth_dog_signin.jpg',
                      badgeText: 'Health Sanctuary',
                      badgeEmoji: '🐶',
                      title: 'Welcome Back!',
                      subtitle: "Sign in to track your dog's telemetry & vitals",
                      titleColor: primaryText,
                      subtitleColor: secondaryText,
                      accentColor: amberAccent,
                      avatarSize: 64,
                    ),
                    const SizedBox(height: 14),

                    // Crisp Card
                    Container(
                      padding: const EdgeInsets.all(20),
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
                          // Email Input
                          CustomTextField(
                            label: 'Email Address',
                            hintText: 'e.g. alex@canivue.com',
                            prefixIcon: Icons.alternate_email_rounded,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            focusAccentColor: amberAccent,
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
                          const SizedBox(height: 12),

                          // Password Input
                          CustomTextField(
                            label: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icons.lock_outline_rounded,
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            focusAccentColor: amberAccent,
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
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: Checkbox(
                                          value: _rememberMe,
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
                                              _rememberMe = val ?? false;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Remember me',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _navigateToForgotPassword,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Signature Pill Button with Amber Icon Badge
                          SignatureAuthButton(
                            label: 'Sign In to Pack',
                            icon: Icons.arrow_forward_rounded,
                            accentColor: const Color(0xFFFFAE33),
                            isLoading: _isLoading,
                            onTap: _handleSignIn,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.06, end: 0),
                    const SizedBox(height: 14),

                    // Social Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: _CompactSocialButton(
                            label: 'Google',
                            icon: Icons.g_mobiledata_rounded,
                            isDark: isDark,
                            onTap: () {
                              AppFeedback.showToast(
                                context,
                                title: 'Google Sign In',
                                message: 'Connecting to Google Authentication...',
                                type: ToastType.info,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _CompactSocialButton(
                            label: 'Apple',
                            icon: Icons.apple_rounded,
                            isDark: isDark,
                            onTap: () {
                              AppFeedback.showToast(
                                context,
                                title: 'Apple Sign In',
                                message: 'Connecting to Apple ID...',
                                type: ToastType.info,
                              );
                            },
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 12),

                    // Veterinarian Demo Pill
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF182029) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: violetAccent.withValues(alpha: 0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: violetAccent.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleVetSignIn,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: violetAccent,
                                    ),
                                    child: const Icon(
                                      Icons.medical_services_rounded,
                                      size: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    "Veterinarian Instant Demo",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: primaryText,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 15,
                                    color: violetAccent,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 240.ms),
                    const SizedBox(height: 12),

                    // Sign Up Link Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.plusJakartaSans(
                            color: secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: const Color(0xFFD97706),
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
    );
  }
}

class _CompactSocialButton extends StatelessWidget {
  const _CompactSocialButton({
    required this.label,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF182029) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isDark ? Colors.white : const Color(0xFF16171B),
                size: 19,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: isDark ? Colors.white : const Color(0xFF16171B),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
