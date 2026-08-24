import 'package:flutter/material.dart';
import 'package:canivue/features/auth/screens/signin_screen.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      home: const SignInScreen(),
    );
  }
}


