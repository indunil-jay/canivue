import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:canivue/features/search/presentation/screens/search_screen.dart';

void main() {
  testWidgets('SearchScreen renders searchbar, back button, and quick symptom check pills', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.text('QUICK SYMPTOM CHECKS'), findsOneWidget);
    expect(find.text('Paw Licking'), findsOneWidget);
    expect(find.text('Limping'), findsOneWidget);
  });

  testWidgets('Typing in SearchScreen updates results live and displays scope pills', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Type query
    await tester.enterText(find.byType(TextField), 'Allergies');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('All Results'), findsOneWidget);
    expect(find.text('🐾 Disease Groups'), findsOneWidget);
    expect(find.text('Skin Allergies'), findsWidgets);

    // Verify clear button appears and resets
    expect(find.byIcon(Icons.close_rounded), findsWidgets);
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('QUICK SYMPTOM CHECKS'), findsOneWidget);
  });

  testWidgets('Tapping a quick symptom pill populates search immediately', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SearchScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Paw Licking'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Skin Allergies'), findsWidgets);
  });
}
