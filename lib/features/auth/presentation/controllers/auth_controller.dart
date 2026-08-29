import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/auth/domain/app_user.dart';

/// Holds the current session. `null` means signed out.
///
/// This is intentionally the only piece of "real" auth state right now —
/// there is no backend yet, so `signIn`/`signUp` just record who the demo
/// user claims to be. Swapping in a real auth service later means changing
/// the body of these methods, not the provider shape or any call site.
class AuthController extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  void signIn({required String email, required String name, UserRole role = UserRole.dogOwner}) {
    state = AppUser(email: email, name: name, role: role);
  }

  void signUp({required String email, required String name, UserRole role = UserRole.dogOwner}) {
    state = AppUser(email: email, name: name, role: role);
  }

  void signOut() {
    state = null;
  }
}

final authControllerProvider = NotifierProvider<AuthController, AppUser?>(AuthController.new);

/// Convenience provider for "is anyone signed in".
final isSignedInProvider = Provider<bool>((ref) => ref.watch(authControllerProvider) != null);
