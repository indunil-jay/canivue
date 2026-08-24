import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/auth/screens/reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  final String email;

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

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

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

    final backgroundGradient = isDark ? AppTheme.obsidianAuthGradient : AppTheme.porcelainAuthGradient;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF64748B);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: backgroundGradient,
        ),
        child: Stack(
          children: [
            // Ambient Luminous Orbs
            if (isDark) ...[
              Positioned(
                top: -60,
                right: -40,
                child: Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.indigoAccent.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Icon Badge
                        Center(
                          child: Container(
                            height: 74,
                            width: 74,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: isDark ? 0.35 : 0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withValues(alpha: isDark ? 0.35 : 0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mark_email_read_outlined,
                              size: 38,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Title
                        Text(
                          'Enter Verification Code',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description with email highlight
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text.rich(
                            TextSpan(
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: subtitleColor,
                                height: 1.45,
                              ),
                              children: [
                                const TextSpan(text: 'We sent a 6-digit verification code to\n'),
                                TextSpan(
                                  text: widget.email,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Glass Card for OTP digits
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF141D2B).withValues(alpha: 0.85)
                                    : Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : const Color(0xFFE2E8F0),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: 0.35)
                                        : const Color(0xFF0F172A).withValues(alpha: 0.06),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
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

                                  // Verify Submit Button
                                  Container(
                                    height: 52,
                                    width: double.infinity,
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
                                      onPressed: _isLoading ? null : _handleVerify,
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
                                              'Verify Code',
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

                        // Resend Code and Auto-Fill Row
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Didn't receive the code? ",
                              style: GoogleFonts.plusJakartaSans(
                                color: isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF475569),
                                fontSize: 13.5,
                              ),
                            ),
                            TextButton(
                              onPressed: _timerSeconds == 0 ? _handleResend : null,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                _timerSeconds > 0 ? 'Resend in ${_timerSeconds}s' : 'Resend Code',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: _timerSeconds == 0
                                      ? (isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue)
                                      : (isDark ? Colors.white54 : const Color(0xFF94A3B8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Demo Fill Button
                        Center(
                          child: TextButton.icon(
                            onPressed: _fillDemoCode,
                            icon: Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue,
                            ),
                            label: Text(
                              'Auto-fill Demo OTP (123456)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
    );
  }
}

class _OtpDigitField extends StatelessWidget {
  const _OtpDigitField({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 58,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.18) : const Color(0xFFCBD5E1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.18) : const Color(0xFFCBD5E1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue,
              width: 2,
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
