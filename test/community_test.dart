import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:canivue/features/community/domain/community_post.dart';
import 'package:canivue/features/community/presentation/screens/community_detail_screen.dart';
import 'package:canivue/features/community/presentation/screens/community_screen.dart';

void main() {
  testWidgets('Tapping Disease Groups tab in CommunityScreen renders groups cleanly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CommunityScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final diseaseGroupsFinder = find.text('Disease Groups');
    expect(diseaseGroupsFinder, findsOneWidget);

    await tester.tap(diseaseGroupsFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    final error = tester.takeException();
    expect(error, isNull);

    expect(find.text('Skin Allergies'), findsOneWidget);
    expect(find.text('Arthritis'), findsOneWidget);
    expect(find.text('Obesity'), findsOneWidget);
  });

  testWidgets('DiseaseCommunity safely handles missing/null optional fields without throwing', (tester) async {
    const community = DiseaseCommunity(
      id: 'comm-test',
      name: 'Test Condition',
      description: 'Testing optional fallbacks.',
      memberCount: 100,
    );

    expect(community.leadVetName, isNotEmpty);
    expect(community.leadVetRole, isNotEmpty);
    expect(community.coverEmoji, '🐾');
    expect(community.rules, isNotEmpty);
    expect(community.members, isEmpty);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: CommunityDetailScreen(community: community),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final error = tester.takeException();
    expect(error, isNull);
    expect(find.text('Test Condition'), findsOneWidget);
  });
}
