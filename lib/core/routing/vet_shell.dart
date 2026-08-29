import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:canivue/core/design_system/components/app_bottom_nav_bar.dart';

/// Bottom-nav shell for the veterinarian role — Dashboard / Patients /
/// Messages / Profile. Deliberately separate from [OwnerShell]: different
/// nav items, different home, per the `canivue-architecture` skill's rule
/// that the two roles never share a shell.
class VetShell extends StatelessWidget {
  const VetShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    AppBottomNavItem(activeIcon: Icons.dashboard_rounded, inactiveIcon: Icons.dashboard_outlined, label: 'Dashboard'),
    AppBottomNavItem(activeIcon: Icons.pets_rounded, inactiveIcon: Icons.pets_outlined, label: 'Patients'),
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
        onTap: (index) => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
      ),
    );
  }
}
