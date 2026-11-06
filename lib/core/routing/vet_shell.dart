import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:canivue/core/widgets/floating_capsule_nav_bar.dart';

/// Bottom-nav shell for the veterinarian role — Dashboard / Patients /
/// Messages / Profile.
///
/// Features the floating frosted capsule navigation bar matching the
/// modern, tactile pet sanctuary design vibe across Canivue.
///
/// Supports fluid scroll-to-hide:
/// - Automatically collapses out of the way when the user scrolls down
/// - Smoothly returns into view when scrolling up or swapping up from the bottom edge
class VetShell extends StatefulWidget {
  const VetShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    CapsuleNavItem(
      activeIcon: Icons.dashboard_rounded,
      inactiveIcon: Icons.dashboard_outlined,
      label: 'Dashboard',
    ),
    CapsuleNavItem(
      activeIcon: Icons.pets_rounded,
      inactiveIcon: Icons.pets_outlined,
      label: 'Patients',
    ),
    CapsuleNavItem(
      activeIcon: Icons.chat_bubble_rounded,
      inactiveIcon: Icons.chat_bubble_outline_rounded,
      label: 'Messages',
      showDot: true,
    ),
    CapsuleNavItem(
      activeIcon: Icons.medical_services_rounded,
      inactiveIcon: Icons.medical_services_outlined,
      label: 'Profile',
    ),
  ];

  @override
  State<VetShell> createState() => _VetShellState();
}

class _VetShellState extends State<VetShell> {
  bool _isNavVisible = true;

  @override
  void didUpdateWidget(covariant VetShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex != widget.navigationShell.currentIndex) {
      if (!_isNavVisible) {
        setState(() => _isNavVisible = true);
      }
    }
  }

  bool _onScrollNotification(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification.metrics.pixels <= 35) {
      if (!_isNavVisible) {
        setState(() => _isNavVisible = true);
      }
      return false;
    }

    if (notification.direction == ScrollDirection.reverse) {
      if (_isNavVisible) {
        setState(() => _isNavVisible = false);
      }
    } else if (notification.direction == ScrollDirection.forward) {
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
        items: VetShell._items,
        currentIndex: widget.navigationShell.currentIndex,
        isVisible: _isNavVisible,
        onTap: (index) {
          if (!_isNavVisible) {
            setState(() => _isNavVisible = true);
          }
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
