import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:canivue/core/widgets/canivue_paw_bone_logo.dart';
import 'package:canivue/features/auth/domain/app_user.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';

/// App launch splash screen — branded pause showing the new Paw & Bone logo on
/// fresh pastel mint before routing to the session destination.
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
      backgroundColor: const Color(0xFFD4EFEA),
      body: Stack(
        children: [
          // Background subtle watermark paw prints
          Positioned(
            top: -40,
            right: -40,
            child: Opacity(
              opacity: 0.05,
              child: Transform.rotate(
                angle: 0.3,
                child: const CanivuePawBoneLogo(
                  size: 260,
                  color: Color(0xFF16171B),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Opacity(
              opacity: 0.04,
              child: Transform.rotate(
                angle: -0.25,
                child: const CanivuePawBoneLogo(
                  size: 240,
                  color: Color(0xFF16171B),
                ),
              ),
            ),
          ),

          // Central Dog App Logo & Brand Text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dog App Logo Card
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.asset(
                      'assets/icons/app_dog_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.88, 0.88),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 20),

                // Brand text
                const CanivuePawBoneLogo(
                  size: 38,
                  showText: true,
                  subtitle: 'PET CARE SANCTUARY',
                  color: Color(0xFF16171B),
                  textColor: Color(0xFF16171B),
                  badgeColor: Color(0xFF10B981),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms)
                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 48),

                // Minimal smooth spinner
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF16171B).withValues(alpha: 0.7),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
