import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:canivue/core/widgets/floating_capsule_nav_bar.dart';

/// Bottom-nav shell for the dog-owner role: Home / Health / Community /
/// Messages / Profile (brief §6).
///
/// Features a floating frosted capsule navigation bar inspired by
/// high-end modern pet apps (PawMate, Pupora).
class OwnerShell extends StatelessWidget {
  const OwnerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    CapsuleNavItem(
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
      label: 'Home',
    ),
    CapsuleNavItem(
      activeIcon: Icons.monitor_heart_rounded,
      inactiveIcon: Icons.monitor_heart_outlined,
      label: 'Health',
    ),
    CapsuleNavItem(
      activeIcon: Icons.groups_rounded,
      inactiveIcon: Icons.groups_outlined,
      label: 'Community',
    ),
    CapsuleNavItem(
      activeIcon: Icons.chat_bubble_rounded,
      inactiveIcon: Icons.chat_bubble_outline_rounded,
      label: 'Messages',
      showDot: true,
    ),
    CapsuleNavItem(
      activeIcon: Icons.person_rounded,
      inactiveIcon: Icons.person_outline_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: FloatingCapsuleNavBar(
        items: _items,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Returning to the already-active tab pops it back to its root.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
