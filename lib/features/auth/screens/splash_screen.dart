import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/canivue_liquid_logo.dart';
import 'package:canivue/features/auth/domain/app_user.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';

/// App launch splash (brief §5) — branded liquid-glass pause while the session is
/// resolved, then routes to the right place: role-based shell if already
/// signed in, onboarding otherwise.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final user = ref.read(authControllerProvider);
      if (user == null) {
        context.go('/onboarding');
      } else if (user.role == UserRole.veterinarian) {
        context.go('/vet-dashboard');
      } else {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Ambient fluid background aura
          Positioned(
            top: -100,
            right: -80,
            width: 340,
            height: 340,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyanAccent.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -80,
            width: 320,
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.royalViolet.withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Central Liquid Glass Landing Logo Preview
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CanivueLandingLogoPreview(
                  logoSize: 110,
                  titleSize: 34,
                  subtitleSize: 12.5,
                  spacing: 24,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyanAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
