import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:canivue/features/auth/domain/app_user.dart';
import 'package:canivue/features/auth/presentation/controllers/auth_controller.dart';
import 'package:canivue/features/auth/screens/forgot_password_screen.dart';
import 'package:canivue/features/auth/screens/otp_verification_screen.dart';
import 'package:canivue/features/auth/screens/reset_password_screen.dart';
import 'package:canivue/features/auth/screens/signup_screen.dart';
import 'package:canivue/features/health_check/screens/health_check_capture_screen.dart';
import 'package:canivue/features/home/screens/home_screen.dart';
import 'package:canivue/features/pets/models/pet_model.dart';
import 'package:canivue/features/pets/screens/add_edit_pet_screen.dart';
import 'package:canivue/features/pets/screens/pet_detail_screen.dart';
import 'package:canivue/features/pets/screens/pet_list_screen.dart';
import 'package:canivue/features/profile/screens/personal_information_screen.dart';
import 'package:canivue/features/profile/screens/profile_screen.dart';
import 'package:canivue/main.dart';

/// Test-only [AuthController] that starts already signed in, so screens
/// gated behind [authControllerProvider] can be smoke-tested in isolation.
class _SignedInAuthController extends AuthController {
  @override
  AppUser? build() => const AppUser(email: 'alex@canivue.com', name: 'Alex');
}

void main() {
  testWidgets('CanivueApp launches with the onboarding flow smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CanivueApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Your Dog\'s Health,\nAll in One Place'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Onboarding Skip navigates to SignInScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CanivueApp());
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('SignUpScreen renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignUpScreen(),
        ),
      ),
    );

    expect(find.text('Create an Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('ForgotPasswordScreen renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ForgotPasswordScreen(),
      ),
    );

    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
  });

  testWidgets('OtpVerificationScreen renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OtpVerificationScreen(email: 'test@example.com'),
      ),
    );

    expect(find.text('Enter Verification Code'), findsOneWidget);
    expect(find.textContaining('test@example.com'), findsOneWidget);
    expect(find.text('Verify Code'), findsOneWidget);
  });

  testWidgets('ResetPasswordScreen renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ResetPasswordScreen(email: 'test@example.com'),
      ),
    );

    expect(find.text('Set New Password'), findsOneWidget);
    expect(find.text('New Password'), findsOneWidget);
    expect(find.text('Confirm New Password'), findsOneWidget);
    expect(find.text('Reset Password'), findsOneWidget);
  });

  testWidgets('HomeScreen renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authControllerProvider.overrideWith(_SignedInAuthController.new)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Hello, Alex 👋'), findsOneWidget);
    expect(find.text('Quick Services'), findsOneWidget);
    expect(find.text('Health Check'), findsOneWidget);
    expect(find.text('Vaccinations'), findsOneWidget);
  });

  testWidgets('ProfileScreen renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authControllerProvider.overrideWith(_SignedInAuthController.new)],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('alex@canivue.com'), findsOneWidget);
    expect(find.text('MY DOGS'), findsOneWidget);
    expect(find.text('Buddy'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('Add Another Dog'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });

  testWidgets('PersonalInformationScreen renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PersonalInformationScreen(
          userEmail: 'alex@canivue.com',
          userName: 'Alex Taylor',
        ),
      ),
    );

    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('BASIC DETAILS'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  testWidgets('PetListScreen renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PetListScreen(),
      ),
    );

    expect(find.textContaining('My Pets'), findsOneWidget);
    expect(find.text('Buddy'), findsOneWidget);
    expect(find.text('Golden Retriever'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('Charlie'), findsOneWidget);
  });

  testWidgets('PetDetailScreen renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PetDetailScreen(
          pet: Pet.samplePets.first,
        ),
      ),
    );

    expect(find.text('Buddy'), findsWidgets);
    expect(find.text('Golden Retriever • Dog'), findsOneWidget);
    expect(find.text('Medical & Care'), findsOneWidget);
    expect(find.text('Diet & Routine'), findsOneWidget);
    expect(find.text('Notes & Info'), findsOneWidget);
    expect(find.text('Book Vet'), findsOneWidget);
  });

  testWidgets('AddEditPetScreen renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AddEditPetScreen(),
      ),
    );

    expect(find.text('Add New Pet'), findsOneWidget);
    expect(find.text('PET DETAILS'), findsOneWidget);
    expect(find.text('Pet Name'), findsOneWidget);
    expect(find.text('Breed'), findsOneWidget);
    expect(find.text('Save Pet Profile'), findsOneWidget);
  });

  testWidgets('HealthCheckCaptureScreen renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HealthCheckCaptureScreen(pets: Pet.samplePets),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500)); // flush flutter_animate's deferred effect scheduling

    expect(find.text('AI Health Check'), findsOneWidget);
    expect(find.text('1 · PHOTO EVIDENCE (OPTIONAL)'), findsOneWidget);
    expect(find.text('2 · SMART COLLAR (OPTIONAL)'), findsOneWidget);
    expect(find.text('Run AI Analysis'), findsOneWidget);
  });

  testWidgets('AI Health Check produces a fused, explainable result', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HealthCheckCaptureScreen(pets: Pet.samplePets),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500)); // flush flutter_animate's deferred effect scheduling

    await tester.enterText(
      find.byType(TextFormField),
      'Scratching a lot for 3 days, redness behind the ears, seems worse today',
    );

    final runButton = find.text('Run AI Analysis');
    await tester.ensureVisible(runButton);
    await tester.pump();
    await tester.tap(runButton);
    await tester.pump(); // start the analyzing overlay (has a repeating animation)
    await tester.pump(const Duration(milliseconds: 1900)); // clear the simulated fusion delay
    await tester.pump(const Duration(milliseconds: 500)); // let the page transition finish

    expect(find.text('Health Check Results'), findsOneWidget);
    expect(find.text('Confidence-Weighted Fusion'), findsOneWidget);
    expect(find.text('Disease Progression Risk (DPRPE)'), findsOneWidget);
    expect(find.text('Book Vet Consultation'), findsOneWidget);
  });
}
