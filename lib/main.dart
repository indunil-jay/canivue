import 'package:flutter/material.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/features/onboarding/screens/onboarding_screen.dart';

void main() {
  runApp(const CanivueApp());
}

class CanivueApp extends StatelessWidget {
  const CanivueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canivue',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
    );
  }
}
