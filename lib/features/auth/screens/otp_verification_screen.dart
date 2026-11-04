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

    final primaryText = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF16171B);
    final secondaryText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
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
                    Color(0xFF56CFE1), // Fresh Seafoam (Slide 4 style)
                    Color(0xFF72EFDD),
                    Color(0xFFE8FCFA),
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
                  // Top Hero Section: Back Button + Beagle Letter Mascot
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
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

                        // Beagle Mascot with Love Letter & Tilted Coral Tile
                        const AuthTopMascot(
                          imageAsset: 'assets/images/auth/auth_dog_otp.jpg',
                          badgeText: 'Instant Passcode',
                          badgeEmoji: '📬',
                          tileColor: coralAccent,
                          avatarSize: 72,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Bottom Curved Sheet Card (Flush to Bottom)
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
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title & Subtitle
                              Text(
                                'Verify Your Code',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : primaryText,
                                  letterSpacing: -0.6,
                                ),
                              ).animate().fadeIn(delay: 60.ms).slideY(begin: 0.08, end: 0),

                              const SizedBox(height: 3),

                              Text(
                                'Enter the 6-digit code sent to ${widget.email}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryText,
                                ),
                              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08, end: 0),

                              const SizedBox(height: 20),

                              // 6 Digit OTP Fields
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  _codeLength,
                                  (index) => _OtpCompactDigitField(
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
                              const SizedBox(height: 20),

                              // Signature Pill Button with Coral Badge
                              SignatureAuthButton(
                                label: 'Verify & Continue',
                                icon: Icons.check_rounded,
                                accentColor: coralAccent,
                                isLoading: _isLoading,
                                onTap: _handleVerify,
                              ),
                              const SizedBox(height: 16),

                              // Resend Code Pill
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF222B36) : const Color(0xFFF1F8F6),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Didn't receive code? ",
                                        style: GoogleFonts.plusJakartaSans(
                                          color: secondaryText,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
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
                                            fontSize: 12.5,
                                            color: _timerSeconds == 0
                                                ? const Color(0xFF0891B2)
                                                : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(delay: 180.ms),
                              const SizedBox(height: 10),

                              // Auto-fill Demo Button
                              Center(
                                child: TextButton.icon(
                                  onPressed: _fillDemoCode,
                                  icon: const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 15,
                                    color: Color(0xFF0891B2),
                                  ),
                                  label: Text(
                                    'Auto-fill Demo Code (123456)',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      color: isDark ? Colors.white : primaryText,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(delay: 220.ms),
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

class _OtpCompactDigitField extends StatefulWidget {
  const _OtpCompactDigitField({
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
  State<_OtpCompactDigitField> createState() => _OtpCompactDigitFieldState();
}

class _OtpCompactDigitFieldState extends State<_OtpCompactDigitField> {
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
      width: 44,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: widget.activeAccent.withValues(alpha: 0.28),
                  blurRadius: 12,
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
          fontSize: 20,
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
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: widget.activeAccent,
              width: 2,
            ),
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
