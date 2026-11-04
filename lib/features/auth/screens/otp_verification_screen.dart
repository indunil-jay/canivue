import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/domain/auth_theme_palette.dart';
import 'package:canivue/features/auth/screens/reset_password_screen.dart';
import 'package:canivue/features/auth/widgets/ambient_auth_backdrop.dart';
import 'package:canivue/features/auth/widgets/auth_form_card.dart';
import 'package:canivue/features/auth/widgets/auth_hero_header.dart';
import 'package:canivue/features/auth/widgets/signature_auth_button.dart';

/// Redesigned OTP Verification Screen for Canivue.
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.onVerified,
  });

  final String email;

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

    await Future.delayed(const Duration(milliseconds: 650));

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
    const palette = AuthThemePalette.emeraldShield;

    return AmbientAuthBackdrop(
      palette: palette,
      showBack: true,
      onBack: () => Navigator.of(context).pop(),
      child: Column(
        children: [
          // 1. Emerald Shield Hero Section with Large Mascot (No Tags)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: AuthTopMascot(
              imageAsset: 'assets/images/auth/cutout_dog_otp.png',
              shadowColor: palette.shadowColor,
              tileColor: palette.tileColor,
              avatarSize: 155,
            ),
          ),

          // 2. Bottom Form Card
          Expanded(
            child: AuthFormCard(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Headline
                  Text(
                    'Enter Verification Code',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      color: primaryText,
                      letterSpacing: -0.6,
                    ),
                  ).animate().fadeIn(duration: 250.ms),

                  const SizedBox(height: 3),

                  Text(
                    'Enter the 6-digit code sent to ${widget.email}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: secondaryText,
                    ),
                  ).animate().fadeIn(delay: 50.ms, duration: 250.ms),

                  const SizedBox(height: 18),

                  // 6 Digit OTP Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      _codeLength,
                      (index) => _OtpCompactDigitField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        isDark: isDark,
                        activeAccent: palette.accentColor,
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

                  // Verify Button
                  SignatureAuthButton(
                    label: 'Verify Code',
                    icon: Icons.check_rounded,
                    accentColor: palette.buttonAccent,
                    isLoading: _isLoading,
                    height: 52,
                    onTap: _handleVerify,
                  ),

                  const SizedBox(height: 20),

                  // Resend Code Pill
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.5),
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
                              fontSize: 12,
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
                                fontSize: 12,
                                color: _timerSeconds == 0
                                    ? palette.accentColor
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Auto-fill Demo Button
                  Center(
                    child: TextButton.icon(
                      onPressed: _fillDemoCode,
                      icon: Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: palette.accentColor,
                      ),
                      label: Text(
                        'Auto-fill Demo Code (123456)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: primaryText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 44,
      height: 50,
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
          fontSize: 19,
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
