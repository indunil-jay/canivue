import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:canivue/main.dart';

void main() {
  testWidgets('SignUpScreen renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CanivueApp());

    expect(find.text('Create an Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
