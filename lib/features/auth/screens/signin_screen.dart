import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/core/widgets/aura_canvas_background.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/auth/screens/forgot_password_screen.dart';
import 'package:canivue/features/auth/screens/signup_screen.dart';
import 'package:canivue/features/auth/widgets/custom_text_field.dart';

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

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : 'alex@canivue.com',
          name: 'Alex',
        );

    if (!mounted) return;
    context.go('/home');
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

    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF475569);

    return AuraCanvasBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Aura Medallion
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 88,
                            width: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  (isDark ? AppTheme.cyanAccent : const Color(0xFF38BDF8)).withValues(alpha: 0.35),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 72,
                            width: 72,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: isDark ? 0.4 : 0.7),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withValues(alpha: isDark ? 0.35 : 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.pets_rounded,
                              size: 38,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Header Text
                    Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to manage your pets and AI health telemetry',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: subtitleColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Frosted Glass Form Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF131C2B).withValues(alpha: 0.82)
                                : Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.14)
                                  : Colors.white.withValues(alpha: 0.85),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.35)
                                    : const Color(0xFF0F172A).withValues(alpha: 0.08),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email Input
                              CustomTextField(
                                label: 'Email Address',
                                hintText: 'Enter your email address',
                                prefixIcon: Icons.email_outlined,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password Input
                              CustomTextField(
                                label: 'Password',
                                hintText: 'Enter your password',
                                prefixIcon: Icons.lock_outline_rounded,
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
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

                              // Remember Me & Forgot Password Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor: AppTheme.primaryBlue,
                                          checkColor: Colors.white,
                                          side: BorderSide(
                                            color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
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
                                      const SizedBox(width: 8),
                                      Text(
                                        'Remember me',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: _navigateToForgotPassword,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot Password?',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Log In Submit Button
                              Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSignIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Log In',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Or Continue With Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'or continue with',
                            style: GoogleFonts.plusJakartaSans(
                              color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFCBD5E1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Social Login Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _SocialLoginButton(
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
                        const SizedBox(width: 14),
                        Expanded(
                          child: _SocialLoginButton(
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
                    ),
                    const SizedBox(height: 24),

                    // Sign Up Link Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF475569),
                            fontSize: 14,
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
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue,
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

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141D2B).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
