import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:canivue/features/auth/screens/forgot_password_screen.dart';
import 'package:canivue/features/auth/screens/otp_verification_screen.dart';
import 'package:canivue/features/auth/screens/reset_password_screen.dart';
import 'package:canivue/features/auth/screens/signup_screen.dart';
import 'package:canivue/features/home/screens/home_screen.dart';
import 'package:canivue/features/pets/screens/pet_list_screen.dart';
import 'package:canivue/features/profile/screens/personal_information_screen.dart';
import 'package:canivue/features/profile/widgets/profile_side_sheet.dart';
import 'package:canivue/main.dart';

void main() {
  testWidgets('CanivueApp launches with SignInScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CanivueApp());

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('SignUpScreen renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpScreen(),
      ),
    );

    expect(find.text('Create an Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
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
      const MaterialApp(
        home: HomeScreen(
          userEmail: 'alex@canivue.com',
          userName: 'Alex',
        ),
      ),
    );

    expect(find.text('Hello, Alex 👋'), findsOneWidget);
    expect(find.text('Quick Services'), findsOneWidget);
    expect(find.text('Health Check'), findsOneWidget);
    expect(find.text('Vaccinations'), findsOneWidget);
  });

  testWidgets('ProfileSideSheet renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileSideSheet(
            userEmail: 'alex@canivue.com',
            userName: 'Alex',
          ),
        ),
      ),
    );

    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('alex@canivue.com'), findsOneWidget);
    expect(find.text('MY PETS'), findsOneWidget);
    expect(find.text('Buddy'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('Add Another Pet'), findsOneWidget);
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
}
