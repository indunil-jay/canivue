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

    const primaryText = Color(0xFF16171B);
    const secondaryText = Color(0xFF475569);
    const amberAccent = Color(0xFFF59E0B);
    const violetAccent = Color(0xFF6B66FF);

    return Scaffold(
      backgroundColor: const Color(0xFFFFAE33),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF261D12),
                    Color(0xFF16171B),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFAE33), // Radiant Sunshine Amber
                    Color(0xFFFFCC33),
                    Color(0xFFFFF7E6),
                  ],
                ),
        ),
        child: Stack(
          children: [
            // Watermark Paw Prints in corners
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
              child: Center(
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
                          // Top Brand Pill Badge
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.06),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CanivuePawBoneLogo(
                                    size: 16,
                                    color: primaryText,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'CANIVUE · CANINE SANCTUARY',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                      color: primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                          const SizedBox(height: 14),

                          // Expressive Hero Avatar & Titles (Image 1 Style)
                          const AuthHeroHeader(
                            imageAsset: 'assets/images/onboarding/dog_slide_1.jpg',
                            tileColor: violetAccent,
                            badgeText: 'Health Sanctuary',
                            badgeEmoji: '🐶',
                            title: 'Welcome Back!',
                            subtitle: "Sign in to track your dog's health & AI telemetry",
                            titleColor: primaryText,
                            subtitleColor: secondaryText,
                          ),
                          const SizedBox(height: 22),

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
                                const SizedBox(height: 18),

                                // Password Input
                                CustomTextField(
                                  label: 'Password',
                                  hintText: 'Enter your account password',
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
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),

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
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Checkbox(
                                                value: _rememberMe,
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
                                                    _rememberMe = val ?? false;
                                                  });
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Remember me',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
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
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Forgot Password?',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFFD97706),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),

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
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08, end: 0),
                          const SizedBox(height: 22),

                          // Or Continue With Divider
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.black.withValues(alpha: 0.12),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'or continue with',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: primaryText.withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.black.withValues(alpha: 0.12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Social Login Buttons
                          Row(
                            children: [
                              Expanded(
                                child: _SocialLoginButton(
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
                              const SizedBox(width: 14),
                              Expanded(
                                child: _SocialLoginButton(
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
                          ).animate().fadeIn(delay: 260.ms),
                          const SizedBox(height: 20),

                          // Veterinarian Demo Pill
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: violetAccent.withValues(alpha: 0.3),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: violetAccent.withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _handleVetSignIn,
                                  borderRadius: BorderRadius.circular(24),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: violetAccent,
                                          ),
                                          child: const Icon(
                                            Icons.medical_services_rounded,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 9),
                                        Text(
                                          "I'm a Veterinarian (Instant Demo)",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: primaryText,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          size: 18,
                                          color: violetAccent,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 300.ms),
                          const SizedBox(height: 18),

                          // Sign Up Link Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.plusJakartaSans(
                                  color: primaryText.withValues(alpha: 0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Sign Up',
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
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF16171B),
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF16171B),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
