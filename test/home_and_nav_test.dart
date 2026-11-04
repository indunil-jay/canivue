import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:canivue/core/widgets/floating_capsule_nav_bar.dart';
import 'package:canivue/core/widgets/ambient_paw_backdrop.dart';
import 'package:canivue/features/home/domain/dashboard_summary.dart';
import 'package:canivue/features/home/presentation/widgets/home_category_pills.dart';
import 'package:canivue/features/home/presentation/widgets/home_hero_pet_card.dart';
import 'package:canivue/features/home/presentation/widgets/home_quick_action_tiles.dart';
import 'package:canivue/features/pets/models/pet_model.dart';

void main() {
  final samplePet = Pet.samplePets.first;

  testWidgets('FloatingCapsuleNavBar renders all items and handles selection', (tester) async {
    int selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox(),
          bottomNavigationBar: StatefulBuilder(
            builder: (context, setState) {
              return FloatingCapsuleNavBar(
                items: const [
                  CapsuleNavItem(activeIcon: Icons.home, inactiveIcon: Icons.home_outlined, label: 'Home'),
                  CapsuleNavItem(activeIcon: Icons.favorite, inactiveIcon: Icons.favorite_border, label: 'Health'),
                  CapsuleNavItem(activeIcon: Icons.person, inactiveIcon: Icons.person_outline, label: 'Profile'),
                ],
                currentIndex: selectedIndex,
                onTap: (index) {
                  setState(() => selectedIndex = index);
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    // Tap Health
    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();

    expect(selectedIndex, 1);
    expect(find.text('Health'), findsOneWidget);
  });

  testWidgets('AmbientPawBackdrop renders container guides and children', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AmbientPawBackdrop(
            showContainerLines: true,
            showPawWatermarks: true,
            showParticles: true,
            child: Center(
              child: Text('Ambient Pet Sanctuary'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Ambient Pet Sanctuary'), findsOneWidget);
    expect(find.byType(AmbientPawBackdrop), findsOneWidget);
  });

  testWidgets('HomeHeroPetCard displays pet info and telemetry pill', (tester) async {
    final summary = DashboardSummary(
      healthScore: 95,
      vitals: const VitalsSnapshot(
        heartRateBpm: 84,
        temperatureC: 38.5,
        activityStepsToday: 6200,
        activityGoalSteps: 8000,
        sleepHoursLastNight: 9.0,
        hydrationMl: 700,
        hydrationGoalMl: 900,
        weightKg: 28.0,
      ),
      insight: const AiInsight(
        headline: 'Restorative sleep cycle optimal',
        detail: 'Luna achieved deep restorative sleep with consistent resting heart rate.',
        risk: RiskLevel.normal,
      ),
      reminders: const [],
      appointment: UpcomingAppointment(
        vetName: 'Dr. Sarah Jenkins',
        clinic: 'Bay Area Vet',
        time: DateTime.now().add(const Duration(days: 3)),
        isVideoCall: false,
      ),
      device: const DeviceStatus(
        state: DeviceConnectionState.connected,
        batteryPercent: 92,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeHeroPetCard(
            dog: samplePet,
            dogs: Pet.samplePets,
            summary: summary,
          ),
        ),
      ),
    );

    expect(find.text('Keep ${samplePet.name}\nSafe & Happy'), findsOneWidget);
    expect(find.text('84 bpm'), findsOneWidget);
    expect(find.text('38.5°C'), findsOneWidget);
    expect(find.text('95%'), findsOneWidget);
    expect(find.text('Guardian Synced'), findsOneWidget);
  });

  testWidgets('HomeQuickActionTiles renders AI Health Scanner and Collar Telemetry tiles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeQuickActionTiles(
            dog: samplePet,
            dogs: Pet.samplePets,
          ),
        ),
      ),
    );

    expect(find.text('AI Health\nScanner'), findsOneWidget);
    expect(find.text('Collar\nTelemetry'), findsOneWidget);
    expect(find.text('Multimodal Vision'), findsOneWidget);
    expect(find.text('Sync Biometrics'), findsOneWidget);
  });

  testWidgets('HomeCategoryPills renders all category items', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeCategoryPills(
            dog: samplePet,
            dogs: Pet.samplePets,
          ),
        ),
      ),
    );

    expect(find.text('Health Check'), findsOneWidget);
    expect(find.text('Vaccinations'), findsOneWidget);
    expect(find.text('My Pets'), findsOneWidget);
    expect(find.text('Telemetry'), findsOneWidget);
    expect(find.text('Nutrition'), findsOneWidget);
    expect(find.text('Find Vet'), findsOneWidget);
  });
}
