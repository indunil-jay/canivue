import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item model for [FloatingCapsuleNavBar].
class CapsuleNavItem {
  const CapsuleNavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    this.badgeCount = 0,
    this.showDot = false,
  });

  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final int badgeCount;
  final bool showDot;
}

/// Floating capsule navigation bar inspired by modern, tactile pet care apps
/// (PawMate, Pupora, Pawsure).
///
/// Features:
/// - Floating rounded capsule geometry (`BorderRadius.circular(32)`)
/// - Frosted glass reflection backdrop
/// - Fluid animated pill selector for active tab
/// - Apple-style press-scaling & haptic feedback
/// - Subtle ambient drop shadow with dark-mode adaptation
/// - Respects safe area and reduced-motion preferences
class FloatingCapsuleNavBar extends StatelessWidget {
  const FloatingCapsuleNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<CapsuleNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final navBackground = isDark
        ? const Color(0xE6161922)
        : const Color(0xF2FFFFFF);

    final borderColor = isDark
        ? const Color(0x33FFFFFF)
        : const Color(0x1F181A20);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: navBackground,
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : const Color(0x1A181A20),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: isDark
                          ? const Color(0x1A0F766E)
                          : const Color(0x0D0F766E),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = index == currentIndex;

                    return _CapsuleNavItemWidget(
                      item: item,
                      isSelected: isSelected,
                      isDark: isDark,
                      reduceMotion: reduceMotion,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTap(index);
                      },
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CapsuleNavItemWidget extends StatefulWidget {
  const _CapsuleNavItemWidget({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.reduceMotion,
    required this.onTap,
  });

  final CapsuleNavItem item;
  final bool isSelected;
  final bool isDark;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  State<_CapsuleNavItemWidget> createState() => _CapsuleNavItemWidgetState();
}

class _CapsuleNavItemWidgetState extends State<_CapsuleNavItemWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final activeBgColor = widget.isDark
        ? const Color(0xFF242A38)
        : const Color(0xFF181A20);

    final activeContentColor = Colors.white;

    final inactiveContentColor = widget.isDark
        ? const Color(0xFF8C96A8)
        : const Color(0xFF757D8A);

    final duration = widget.reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 240);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSelected ? 16 : 12,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected ? activeBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: activeBgColor.withValues(alpha: widget.isDark ? 0.4 : 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    widget.isSelected
                        ? widget.item.activeIcon
                        : widget.item.inactiveIcon,
                    size: 21,
                    color: widget.isSelected ? activeContentColor : inactiveContentColor,
                  ),
                  if (widget.item.showDot || widget.item.badgeCount > 0)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isSelected ? activeBgColor : Colors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 8),
                AnimatedOpacity(
                  opacity: widget.isSelected ? 1.0 : 0.0,
                  duration: duration,
                  child: Text(
                    widget.item.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: activeContentColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
