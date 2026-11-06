import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/accessibility/accessibility_provider.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/notifications/widgets/notification_badge_button.dart';

/// Top bar inspired by Facebook's signature mobile header and top navigation.
///
/// Features:
/// 1. Top Header Row:
///    - Bold branded lowercase "canivue" logo with modern typography
///    - Facebook-style circular action icons: Search, AI Camera Scan (+), Notifications, Accessibility
/// 2. Iconic Facebook Navigation Tab Bar:
///    - 5 horizontal tabs: [Home/Services, AI Health, Pets, Vet Care, Community]
///    - Fluid active indicator underline & high-contrast tint
///    - Large 48x48+ tap targets for WCAG 2.2 accessibility
///    - Tactile Apple-style haptic feedback
///    - Screen reader semantics
class FacebookTopAppBar extends ConsumerWidget {
  const FacebookTopAppBar({
    super.key,
    required this.selectedTabIndex,
    required this.onTabSelected,
    required this.onSearchTap,
    required this.onScannerTap,
    this.badgeCount,
  });

  final int selectedTabIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onSearchTap;
  final VoidCallback onScannerTap;
  final int? badgeCount;

  static const List<_FacebookTabSpec> _tabs = [
    _FacebookTabSpec(
      icon: Icons.home_rounded,
      selectedIcon: Icons.home_rounded,
      label: 'Home & Services',
      shortLabel: 'Home',
    ),
    _FacebookTabSpec(
      icon: Icons.health_and_safety_outlined,
      selectedIcon: Icons.health_and_safety_rounded,
      label: 'AI Health Scanner',
      shortLabel: 'AI Health',
      showBadgeDot: true,
    ),
    _FacebookTabSpec(
      icon: Icons.pets_outlined,
      selectedIcon: Icons.pets_rounded,
      label: 'My Dogs & Profiles',
      shortLabel: 'Pets',
    ),
    _FacebookTabSpec(
      icon: Icons.medical_services_outlined,
      selectedIcon: Icons.medical_services_rounded,
      label: 'Vet Care & Clinics',
      shortLabel: 'Vet Care',
    ),
    _FacebookTabSpec(
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
      label: 'Pet Parent Community',
      shortLabel: 'Community',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final a11y = ref.watch(accessibilityProvider);

    final bg = isDark ? const Color(0xFF151922) : Colors.white;
    final borderColor = a11y.highContrast
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? const Color(0x22FFFFFF) : const Color(0xFFE5E7EB));

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(color: borderColor, width: a11y.highContrast ? 2.0 : 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Facebook App Branding & Quick Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Row(
                children: [
                  // Facebook-style bold brand logo
                  Semantics(
                    header: true,
                    label: 'Canivue Pet Health App',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'canive',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.2,
                            color: a11y.highContrast
                                ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E))
                                : (isDark ? Colors.white : const Color(0xFF0F766E)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFED25E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'HUB',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF181A20),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Facebook-style circular action buttons
                  _buildCircleActionButton(
                    icon: Icons.search_rounded,
                    tooltip: 'Search dogs, vets, records',
                    semanticsLabel: 'Search all services and records',
                    onTap: onSearchTap,
                    isDark: isDark,
                    a11y: a11y,
                  ),
                  const SizedBox(width: 8),

                  _buildCircleActionButton(
                    icon: Icons.add_a_photo_rounded,
                    tooltip: 'Launch AI Health Scanner',
                    semanticsLabel: 'Open AI Vision camera scanner',
                    highlightColor: const Color(0xFF10B981),
                    onTap: onScannerTap,
                    isDark: isDark,
                    a11y: a11y,
                  ),
                  const SizedBox(width: 8),

                  const NotificationBadgeButton(),
                  const SizedBox(width: 8),

                  // Accessibility button (Universal quick tools)
                  _buildCircleActionButton(
                    icon: Icons.accessibility_new_rounded,
                    tooltip: 'Accessibility options',
                    semanticsLabel: 'Open accessibility controls',
                    highlightColor: const Color(0xFF3B82F6),
                    onTap: () => AccessibilityBottomSheet.show(context),
                    isDark: isDark,
                    a11y: a11y,
                  ),
                ],
              ),
            ),

            // Row 2: Facebook-style Iconic Horizontal Tabs
            SizedBox(
              height: 48,
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final isSelected = index == selectedTabIndex;

                  final activeColor = a11y.highContrast
                      ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E))
                      : (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E));
                  final inactiveColor =
                      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: isSelected,
                      label: '${tab.label} tab, ${index + 1} of ${_tabs.length}',
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onTabSelected(index);
                        },
                        splashColor: activeColor.withValues(alpha: 0.12),
                        highlightColor: activeColor.withValues(alpha: 0.08),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Tab Icon with optional badge dot
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    isSelected ? tab.selectedIcon : tab.icon,
                                    size: isSelected ? 26 : 24,
                                    color: isSelected ? activeColor : inactiveColor,
                                  ),
                                  if (tab.showBadgeDot)
                                    Positioned(
                                      top: -1,
                                      right: -3,
                                      child: Container(
                                        height: 8,
                                        width: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEF4444),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Facebook-style active bottom underline bar
                            Positioned(
                              bottom: 0,
                              left: 8,
                              right: 8,
                              child: AnimatedContainer(
                                duration: a11y.reduceMotion
                                    ? Duration.zero
                                    : const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                height: isSelected ? 3.5 : 0,
                                decoration: BoxDecoration(
                                  color: activeColor,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(3),
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: activeColor.withValues(alpha: 0.4),
                                            blurRadius: 4,
                                            offset: const Offset(0, -1),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    required String tooltip,
    required String semanticsLabel,
    required VoidCallback onTap,
    required bool isDark,
    required AccessibilityState a11y,
    Color? highlightColor,
  }) {
    final buttonBg = isDark ? const Color(0xFF242A38) : const Color(0xFFF1F5F9);
    final iconColor = highlightColor ?? (isDark ? Colors.white : const Color(0xFF1E293B));

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(22),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: buttonBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: a11y.highContrast
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? const Color(0x22FFFFFF) : const Color(0xFFE2E8F0)),
                  width: a11y.highContrast ? 1.8 : 1.0,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FacebookTabSpec {
  const _FacebookTabSpec({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.shortLabel,
    this.showBadgeDot = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String shortLabel;
  final bool showBadgeDot;
}
