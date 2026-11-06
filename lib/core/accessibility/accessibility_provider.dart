import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';

/// Accessibility settings state.
class AccessibilityState {
  const AccessibilityState({
    this.highContrast = false,
    this.largeText = false,
    this.reduceMotion = false,
    this.screenReaderAssistance = false,
  });

  final bool highContrast;
  final bool largeText;
  final bool reduceMotion;
  final bool screenReaderAssistance;

  double get textScaleFactor => largeText ? 1.25 : 1.0;

  AccessibilityState copyWith({
    bool? highContrast,
    bool? largeText,
    bool? reduceMotion,
    bool? screenReaderAssistance,
  }) {
    return AccessibilityState(
      highContrast: highContrast ?? this.highContrast,
      largeText: largeText ?? this.largeText,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      screenReaderAssistance:
          screenReaderAssistance ?? this.screenReaderAssistance,
    );
  }
}

/// Accessibility state notifier for user accessibility preferences.
class AccessibilityNotifier extends StateNotifier<AccessibilityState> {
  AccessibilityNotifier() : super(const AccessibilityState());

  void toggleHighContrast() {
    state = state.copyWith(highContrast: !state.highContrast);
  }

  void toggleLargeText() {
    state = state.copyWith(largeText: !state.largeText);
  }

  void toggleReduceMotion() {
    state = state.copyWith(reduceMotion: !state.reduceMotion);
  }

  void toggleScreenReaderAssistance() {
    state = state.copyWith(
      screenReaderAssistance: !state.screenReaderAssistance,
    );
  }

  void resetDefaults() {
    state = const AccessibilityState();
  }
}

final accessibilityProvider =
    StateNotifierProvider<AccessibilityNotifier, AccessibilityState>((ref) {
  return AccessibilityNotifier();
});

/// Quick Accessibility Control Bottom Sheet.
/// Provides one-tap toggles for high contrast, enlarged text, reduced motion,
/// and screen reader optimization (WCAG 2.2 compliant).
class AccessibilityBottomSheet extends ConsumerWidget {
  const AccessibilityBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AccessibilityBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a11y = ref.watch(accessibilityProvider);
    final notifier = ref.read(accessibilityProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF1E2430) : Colors.white;
    final cardBg = isDark ? const Color(0xFF293140) : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: a11y.highContrast
            ? Border.all(color: Colors.white, width: 2)
            : Border.all(
                color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFE2E8F0),
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: a11y.highContrast
                        ? const Color(0xFF0F766E)
                        : (isDark ? const Color(0x332DD4BF) : const Color(0xFFE6F4F1)),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.accessibility_new_rounded,
                    color: Color(0xFF0F766E),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accessibility & Comfort',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        'Tailor Canive for your visual & motor preferences',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close accessibility settings',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Accessibility Options List
            _buildOptionTile(
              title: 'High Contrast Mode',
              subtitle: 'Enhances borders, cards, and text legibility',
              icon: Icons.contrast_rounded,
              value: a11y.highContrast,
              onChanged: (_) {
                HapticFeedback.selectionClick();
                notifier.toggleHighContrast();
              },
              cardBg: cardBg,
              textPrimary: textPrimary,
              textMuted: textMuted,
              isDark: isDark,
            ),
            const SizedBox(height: 10),

            _buildOptionTile(
              title: 'Enlarged Text Scale',
              subtitle: 'Increases font sizes across all navigation and cards',
              icon: Icons.format_size_rounded,
              value: a11y.largeText,
              onChanged: (_) {
                HapticFeedback.selectionClick();
                notifier.toggleLargeText();
              },
              cardBg: cardBg,
              textPrimary: textPrimary,
              textMuted: textMuted,
              isDark: isDark,
            ),
            const SizedBox(height: 10),

            _buildOptionTile(
              title: 'Reduced Motion',
              subtitle: 'Minimizes animated shifts & spring physics (WCAG 2.3.3)',
              icon: Icons.motion_photos_off_rounded,
              value: a11y.reduceMotion,
              onChanged: (_) {
                HapticFeedback.selectionClick();
                notifier.toggleReduceMotion();
              },
              cardBg: cardBg,
              textPrimary: textPrimary,
              textMuted: textMuted,
              isDark: isDark,
            ),
            const SizedBox(height: 10),

            _buildOptionTile(
              title: 'Screen Reader Assistance',
              subtitle: 'Enables high-prominence semantics & spoken action guides',
              icon: Icons.record_voice_over_rounded,
              value: a11y.screenReaderAssistance,
              onChanged: (_) {
                HapticFeedback.selectionClick();
                notifier.toggleScreenReaderAssistance();
              },
              cardBg: cardBg,
              textPrimary: textPrimary,
              textMuted: textMuted,
              isDark: isDark,
            ),
            const SizedBox(height: 18),

            // Reset button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  notifier.resetDefaults();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFCBD5E1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Reset to System Defaults',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color cardBg,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: value
              ? AppColors.primary
              : (isDark ? const Color(0x22FFFFFF) : const Color(0xFFE2E8F0)),
          width: value ? 1.6 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : (isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: value ? AppColors.primary : textMuted,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
