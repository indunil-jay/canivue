import 'package:flutter/material.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';

class AppBottomNavItem {
  const AppBottomNavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    this.showDot = false,
  });

  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  /// Small unread/attention indicator (e.g. unread messages).
  final bool showDot;
}

/// Shared bottom navigation bar for a role's shell (owner or veterinarian).
/// Selected items expand into a label pill; unselected items stay icon-only,
/// so five destinations stay comfortable to tap without crowding.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurface : AppColors.lightSurface).withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < items.length; i++) _buildItem(context, i, items[i], isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, AppBottomNavItem item, bool isDark) {
    final isSelected = index == currentIndex;
    final selectedColor = isDark ? AppColors.primaryOnDark : AppColors.primary;
    final unselectedColor = isDark ? AppColors.darkMutedText : AppColors.lightMutedText;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: AppRadius.mdRadius,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryOnDark.withValues(alpha: 0.16) : const Color(0xFFE3F3F0))
              : Colors.transparent,
          borderRadius: AppRadius.mdRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.inactiveIcon,
                  color: isSelected ? selectedColor : unselectedColor,
                  size: 22,
                ),
                if (item.showDot)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.errorOnDark : AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? AppColors.darkSurface : AppColors.lightSurface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.sm),
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: selectedColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
