import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/core/widgets/canivue_paw_bone_logo.dart';
import 'package:canivue/features/auth/screens/reset_password_screen.dart';
import 'package:canivue/features/auth/widgets/auth_hero_header.dart';
import 'package:canivue/features/auth/widgets/signature_auth_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.onVerified,
  });

  final String email;

  /// When provided, called instead of navigating to [ResetPasswordScreen] —
  /// lets this same OTP flow back both "forgot password" and "verify your
  /// email at signup" without duplicating the screen.
  final VoidCallback? onVerified;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final int _codeLength = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  bool _isLoading = false;
  int _timerSeconds = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_codeLength, (_) => TextEditingController());
    _focusNodes = List.generate(_codeLength, (_) => FocusNode());
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timerSeconds = 59;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _fillDemoCode() {
    const demo = '123456';
    for (int i = 0; i < _codeLength; i++) {
      _controllers[i].text = demo[i];
    }
    setState(() {});
    _handleVerify();
  }

  void _handleVerify() async {
    final code = _otpCode;
    if (code.length < _codeLength) {
      AppFeedback.showToast(
        context,
        title: 'Incomplete Code',
        message: 'Please enter the full 6-digit verification code.',
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

    if (widget.onVerified != null) {
      widget.onVerified!();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(email: widget.email),
      ),
    );
  }

  void _handleResend() {
    if (_timerSeconds > 0) return;
    _startTimer();

    AppFeedback.showToast(
      context,
      title: 'Code Resent 📨',
      message: 'A new 6-digit code has been sent to ${widget.email}',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const primaryText = Color(0xFF16171B);
    const secondaryText = Color(0xFF475569);
    const seafoamAccent = Color(0xFF06B6D4);
    const coralAccent = Color(0xFFFF6B6B);

    return Scaffold(
      backgroundColor: const Color(0xFF56CFE1),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0E2226),
                    Color(0xFF16171B),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF56CFE1), // Fresh Seafoam
                    Color(0xFF72EFDD),
                    Color(0xFFE8FCFA),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 38),

                            // Expressive Hero Avatar & Titles (Image 4 Style)
                            AuthHeroHeader(
                              imageAsset: 'assets/images/onboarding/dog_slide_4.jpg',
                              tileColor: coralAccent,
                              badgeText: 'Instant Passcode',
                              badgeEmoji: '📬',
                              title: 'Verify Your Code',
                              subtitle: 'We sent a 6-digit code to ${widget.email}',
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
                                children: [
                                  // 6 Digit OTP Fields
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                      _codeLength,
                                      (index) => _OtpDigitField(
                                        controller: _controllers[index],
                                        focusNode: _focusNodes[index],
                                        isDark: isDark,
                                        activeAccent: seafoamAccent,
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {
                                            if (index < _codeLength - 1) {
                                              _focusNodes[index + 1].requestFocus();
                                            } else {
                                              _focusNodes[index].unfocus();
                                              _handleVerify();
                                            }
                                          } else if (value.isEmpty && index > 0) {
                                            _focusNodes[index - 1].requestFocus();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Signature Pill Button with Coral Badge
                                  SignatureAuthButton(
                                    label: 'Verify & Proceed',
                                    icon: Icons.check_rounded,
                                    accentColor: coralAccent,
                                    isLoading: _isLoading,
                                    onTap: _handleVerify,
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08, end: 0),
                            const SizedBox(height: 22),

                            // Resend Code Pill
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.06),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Didn't receive code? ",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: secondaryText,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _timerSeconds == 0 ? _handleResend : null,
                                      child: Text(
                                        _timerSeconds > 0
                                            ? 'Resend in ${_timerSeconds}s'
                                            : 'Resend Code',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          color: _timerSeconds == 0
                                              ? const Color(0xFF0891B2)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: 250.ms),
                            const SizedBox(height: 14),

                            // Demo Auto-fill Button
                            Center(
                              child: TextButton.icon(
                                onPressed: _fillDemoCode,
                                icon: const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 16,
                                  color: Color(0xFF0891B2),
                                ),
                                label: Text(
                                  'Auto-fill Demo Code (123456)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: primaryText,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: 280.ms),
                          ],
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

class _OtpDigitField extends StatefulWidget {
  const _OtpDigitField({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.activeAccent,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final Color activeAccent;
  final ValueChanged<String> onChanged;

  @override
  State<_OtpDigitField> createState() => _OtpDigitFieldState();
}

class _OtpDigitFieldState extends State<_OtpDigitField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: 46,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: widget.activeAccent.withValues(alpha: 0.28),
                  blurRadius: 14,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: widget.isDark ? Colors.white : const Color(0xFF16171B),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: widget.isDark
              ? const Color(0xFF1E252B)
              : const Color(0xFFF8FAF9),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: widget.activeAccent,
              width: 2.2,
            ),
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
