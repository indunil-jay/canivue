import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/domain/app_user.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/auth/screens/forgot_password_screen.dart';
import 'package:canivue/features/auth/screens/signup_screen.dart';
import 'package:canivue/features/auth/widgets/ambient_auth_backdrop.dart';
import 'package:canivue/features/auth/widgets/auth_form_card.dart';
import 'package:canivue/features/auth/widgets/auth_hero_header.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';
import 'package:canivue/features/auth/widgets/signature_auth_button.dart';
import 'package:canivue/features/auth/widgets/social_auth_button.dart';

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

    const primaryText = Color(0xFF16171B);
    const secondaryText = Color(0xFF64748B);
    const amberAccent = Color(0xFFF59E0B);
    const violetAccent = Color(0xFF6366F1);

    return AmbientAuthBackdrop(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFAE33), // Radiant Sunshine Amber (Onboarding Slide 1 Style)
          Color(0xFFFFC043),
          Color(0xFFFFF3D6),
        ],
      ),
      accentColor: amberAccent,
      showBack: false,
      child: Column(
        children: [
          // 1. Hero Mascot & Title Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
            child: const AuthTopMascot(
              imageAsset: 'assets/images/auth/auth_dog_signin.jpg',
              badgeText: 'Health Sanctuary',
              badgeEmoji: '🐶',
              tileColor: Color(0xFF6B66FF), // Contrast Electric Violet Tile
              avatarSize: 68,
            ),
          ),

          // 2. Compact Bottom Card (Zero Scrolling at Rest)
          Expanded(
            child: AuthFormCard(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Headline
                    Text(
                      'Welcome Back',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : primaryText,
                        letterSpacing: -0.6,
                      ),
                    ).animate().fadeIn(duration: 250.ms),

                    const SizedBox(height: 2),

                    Text(
                      "Sign in to monitor your dog's telemetry & vitals",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: secondaryText,
                      ),
                    ).animate().fadeIn(delay: 50.ms, duration: 250.ms),

                    const SizedBox(height: 12),

                    // Email Field
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

                    const SizedBox(height: 10),

                    // Password Field
                    CustomTextField(
                      label: 'Password',
                      hintText: 'Enter account password',
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

                    const SizedBox(height: 6),

                    // Remember Me & Forgot Password Row
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
                                    fontSize: 11.5,
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
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Primary Signature Action Button
                    SignatureAuthButton(
                      label: 'Log In',
                      icon: Icons.arrow_forward_rounded,
                      accentColor: const Color(0xFFFFAE33),
                      isLoading: _isLoading,
                      height: 48,
                      onTap: _handleSignIn,
                    ),

                    const SizedBox(height: 10),

                    // Social Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: CompactSocialButton(
                            label: 'Google',
                            icon: Icons.g_mobiledata_rounded,
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
                          child: CompactSocialButton(
                            label: 'Apple',
                            icon: Icons.apple_rounded,
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
                    ),

                    const SizedBox(height: 8),

                    // Veterinarian Demo Pill
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF222B36) : const Color(0xFFF8F5FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: violetAccent.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleVetSignIn,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3.5),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: violetAccent,
                                    ),
                                    child: const Icon(
                                      Icons.medical_services_rounded,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Veterinarian Instant Demo",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : primaryText,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 14,
                                    color: violetAccent,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Sign Up Link Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.plusJakartaSans(
                            color: secondaryText,
                            fontSize: 12,
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
                              fontSize: 12,
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
        ],
      ),
    );
  }
}
