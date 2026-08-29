import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/features/auth/domain/app_user.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';

/// App launch splash (brief §5) — brief branded pause while the session is
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
    Future.delayed(const Duration(milliseconds: 1100), () {
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 32, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.pets_rounded, color: Colors.white, size: 44),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Canivue',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Canine Health Intelligence',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryOnDark.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
