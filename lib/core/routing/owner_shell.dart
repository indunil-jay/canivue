import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:canivue/core/widgets/floating_capsule_nav_bar.dart';

/// Bottom-nav shell for the dog-owner role: Home / Health / Community /
/// Messages / Profile (brief §6).
///
/// Features a floating frosted capsule navigation bar inspired by
/// high-end modern pet apps (PawMate, Pupora).
///
/// Supports fluid scroll-to-hide:
/// - Automatically collapses out of the way when the user scrolls down to read/compose
/// - Smoothly returns into view when scrolling up or swapping up from the bottom edge
class OwnerShell extends StatefulWidget {
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
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  bool _isNavVisible = true;

  @override
  void didUpdateWidget(covariant OwnerShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When switching tabs, ensure the bottom bar is always visible
    if (oldWidget.navigationShell.currentIndex != widget.navigationShell.currentIndex) {
      if (!_isNavVisible) {
        setState(() => _isNavVisible = true);
      }
    }
  }

  bool _onScrollNotification(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    // If near the top, keep navigation bar visible
    if (notification.metrics.pixels <= 35) {
      if (!_isNavVisible) {
        setState(() => _isNavVisible = true);
      }
      return false;
    }

    if (notification.direction == ScrollDirection.reverse) {
      // User is scrolling DOWN (content moving up) -> hide navigation bar
      if (_isNavVisible) {
        setState(() => _isNavVisible = false);
      }
    } else if (notification.direction == ScrollDirection.forward) {
      // User is scrolling UP (swapping towards top) -> show navigation bar
      if (!_isNavVisible) {
        setState(() => _isNavVisible = true);
      }
    }
    return false;
  }

  void _revealNav() {
    if (!_isNavVisible) {
      HapticFeedback.lightImpact();
      setState(() => _isNavVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          NotificationListener<UserScrollNotification>(
            onNotification: _onScrollNotification,
            child: widget.navigationShell,
          ),
          // Swipe up from bottom detector when navigation is collapsed/hidden
          if (!_isNavVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 44,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta != null && details.primaryDelta! < -4) {
                    _revealNav();
                  }
                },
                onTap: _revealNav,
              ),
            ),
        ],
      ),
      bottomNavigationBar: FloatingCapsuleNavBar(
        items: OwnerShell._items,
        currentIndex: widget.navigationShell.currentIndex,
        isVisible: _isNavVisible,
        onTap: (index) {
          if (!_isNavVisible) {
            setState(() => _isNavVisible = true);
          }
          widget.navigationShell.goBranch(
            index,
            // Returning to the already-active tab pops it back to its root.
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
