/// The two primary roles in Canivue — each gets a distinct navigation shell
/// and home experience (see `canivue-architecture` skill).
enum UserRole { dogOwner, veterinarian }

/// The signed-in user. Plain domain entity — no Flutter imports.
class AppUser {
  const AppUser({
    required this.email,
    required this.name,
    this.role = UserRole.dogOwner,
  });

  final String email;
  final String name;
  final UserRole role;

  AppUser copyWith({String? email, String? name, UserRole? role}) {
    return AppUser(
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }
}
