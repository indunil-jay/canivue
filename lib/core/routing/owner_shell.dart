import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:canivue/core/design_system/components/app_bottom_nav_bar.dart';

/// Bottom-nav shell for the dog-owner role: Home / Health / Community /
/// Messages / Profile (brief §6). Each branch keeps its own [Scaffold] and
/// [AppBar]; this widget only owns the persistent bottom navigation bar so
/// switching tabs preserves each branch's scroll position and stack.
class OwnerShell extends StatelessWidget {
  const OwnerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    AppBottomNavItem(activeIcon: Icons.home_rounded, inactiveIcon: Icons.home_outlined, label: 'Home'),
    AppBottomNavItem(activeIcon: Icons.monitor_heart_rounded, inactiveIcon: Icons.monitor_heart_outlined, label: 'Health'),
    AppBottomNavItem(activeIcon: Icons.groups_rounded, inactiveIcon: Icons.groups_outlined, label: 'Community'),
    AppBottomNavItem(activeIcon: Icons.chat_bubble_rounded, inactiveIcon: Icons.chat_bubble_outline_rounded, label: 'Messages'),
    AppBottomNavItem(activeIcon: Icons.person_rounded, inactiveIcon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
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
