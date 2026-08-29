import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:canivue/core/routing/owner_shell.dart';
import 'package:canivue/core/routing/vet_shell.dart';
import 'package:canivue/features/auth/domain/app_user.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/auth/screens/forgot_password_screen.dart';
import 'package:canivue/features/auth/screens/signin_screen.dart';
import 'package:canivue/features/auth/screens/signup_screen.dart';
import 'package:canivue/features/community/presentation/screens/community_screen.dart';
import 'package:canivue/features/health/presentation/screens/health_screen.dart';
import 'package:canivue/features/home/screens/home_screen.dart';
import 'package:canivue/features/messages/presentation/screens/messages_screen.dart';
import 'package:canivue/features/onboarding/screens/onboarding_screen.dart';
import 'package:canivue/features/profile/screens/profile_screen.dart';
import 'package:canivue/features/vet_portal/presentation/screens/vet_dashboard_screen.dart';
import 'package:canivue/features/vet_portal/presentation/screens/vet_patient_list_screen.dart';
import 'package:canivue/features/vet_portal/presentation/screens/vet_professional_profile_screen.dart';

/// Top-level app navigation. Owns the auth ↔ role-based-shell boundary;
/// nested, contextual navigation within a screen (a detail page, a wizard
/// step, a bottom sheet) stays on `Navigator.push` from inside that screen
/// — see the `canivue-architecture` skill.
///
/// The dog-owner and veterinarian experiences are separate shells with
/// separate route prefixes (`/home...` vs `/vet-...`); the redirect below
/// keeps each role confined to its own shell.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) {
      final user = ref.read(authControllerProvider);
      final signedIn = user != null;
      final location = state.matchedLocation;
      final inAuthArea = location.startsWith('/onboarding') ||
          location.startsWith('/sign-in') ||
          location.startsWith('/sign-up') ||
          location.startsWith('/forgot-password');
      final inVetArea = location.startsWith('/vet-');

      if (!signedIn && !inAuthArea) return '/sign-in';
      if (!signedIn) return null;

      final isVet = user.role == UserRole.veterinarian;
      if (inAuthArea) return isVet ? '/vet-dashboard' : '/home';
      // Keep each role confined to its own shell.
      if (isVet && !inVetArea) return '/vet-dashboard';
      if (!isVet && inVetArea) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/sign-in', builder: (context, state) => const SignInScreen()),
      GoRoute(path: '/sign-up', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => OwnerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (context, state) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/health', builder: (context, state) => const HealthScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/community', builder: (context, state) => const CommunityScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/messages', builder: (context, state) => const MessagesScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())]),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => VetShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/vet-dashboard', builder: (context, state) => const VetDashboardScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/vet-patients', builder: (context, state) => const VetPatientListScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/vet-messages', builder: (context, state) => const MessagesScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/vet-profile', builder: (context, state) => const VetProfessionalProfileScreen())]),
        ],
      ),
    ],
  );
});
