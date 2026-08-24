import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:canivue/core/theme/app_theme.dart';

enum ToastType { success, error, info, warning }

class AppFeedback {
  static void showToast(
    BuildContext context, {
    required String message,
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    Color accentColor;
    IconData icon;
    LinearGradient borderGradient;

    switch (type) {
      case ToastType.success:
        accentColor = AppTheme.emeraldAccent;
        icon = Icons.check_circle_rounded;
        borderGradient = AppTheme.emeraldGradient;
        break;
      case ToastType.error:
        accentColor = const Color(0xFFF43F5E);
        icon = Icons.error_rounded;
        borderGradient = const LinearGradient(
          colors: [Color(0xFFE11D48), Color(0xFFFB7185)],
        );
        break;
      case ToastType.warning:
        accentColor = AppTheme.warningAmber;
        icon = Icons.warning_rounded;
        borderGradient = const LinearGradient(
          colors: [Color(0xFFD97706), Color(0xFFFBBF24)],
        );
        break;
      case ToastType.info:
        accentColor = AppTheme.cyanAccent;
        icon = Icons.info_rounded;
        borderGradient = AppTheme.primaryGradient;
        break;
    }

    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            type: MaterialType.transparency,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0F1B2B).withValues(alpha: 0.94),
                            const Color(0xFF070D18).withValues(alpha: 0.97),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              gradient: borderGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(icon, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (title != null)
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                Text(
                                  message,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    fontSize: 13,
                                    height: 1.3,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 200.ms)
                  .slideY(begin: -0.4, end: 0, curve: Curves.easeOutCubic),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    Future.delayed(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  static Future<bool?> showLuxuryDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData icon = Icons.info_outline_rounded,
    LinearGradient? iconGradient,
    Color? accentColor,
  }) {
    final effectiveAccent = accentColor ?? AppTheme.cyanAccent;
    final effectiveGradient = iconGradient ?? AppTheme.primaryGradient;

    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10 * anim1.value,
            sigmaY: 10 * anim1.value,
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutCubic,
            ),
            child: FadeTransition(
              opacity: anim1,
              child: child,
            ),
          ),
        );
      },
      pageBuilder: (context, _, _) {
        return Material(
          color: Colors.transparent,
          type: MaterialType.transparency,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF101E33).withValues(alpha: 0.95),
                            const Color(0xFF070E1A).withValues(alpha: 0.98),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: effectiveAccent.withValues(alpha: 0.22),
                            blurRadius: 36,
                            spreadRadius: 2,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Glow Aura Icon Medallion
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      effectiveAccent.withValues(alpha: 0.35),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 62,
                                width: 62,
                                decoration: BoxDecoration(
                                  gradient: effectiveGradient,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: effectiveAccent.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(icon, color: Colors.white, size: 28),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Title without yellow underline
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.3,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Message without yellow underline
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                                height: 1.45,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),

                          // Actions Row
                          Row(
                            children: [
                              // Cancel Button
                              Expanded(
                                child: InkWell(
                                  onTap: () => Navigator.of(context).pop(false),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.18),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      cancelText,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Confirm Action Button
                              Expanded(
                                child: InkWell(
                                  onTap: () => Navigator.of(context).pop(true),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    decoration: BoxDecoration(
                                      gradient: effectiveGradient,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: effectiveAccent.withValues(alpha: 0.35),
                                          blurRadius: 16,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      confirmText,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        letterSpacing: 0.2,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
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
          ),
        );
      },
    );
  }

  static Future<T?> showLuxuryBottomSheet<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    IconData? headerIcon,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Material(
          color: Colors.transparent,
          type: MaterialType.transparency,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF101E33).withValues(alpha: 0.96),
                      const Color(0xFF070E1A).withValues(alpha: 0.98),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle Bar
                      Center(
                        child: Container(
                          height: 4,
                          width: 42,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (headerIcon != null) ...[
                                Icon(headerIcon, color: AppTheme.cyanAccent, size: 22),
                                const SizedBox(width: 10),
                              ],
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Content
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
