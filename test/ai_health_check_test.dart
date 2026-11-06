import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:canivue/features/health_check/screens/health_check_capture_screen.dart';
import 'package:canivue/features/health_check/screens/health_check_result_screen.dart';
import 'package:canivue/features/health_check/models/health_check_models.dart';
import 'package:canivue/features/pets/models/pet_model.dart';

void main() {
  setUp(() {
    Animate.restartOnHotReload = false;
  });
  tearDown(() {
    Animate.restartOnHotReload = true;
  });

  testWidgets('HealthCheckCaptureScreen renders demo button and quick symptom chips', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HealthCheckCaptureScreen(pets: Pet.samplePets),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('AI Health Check'), findsOneWidget);
    expect(find.text('Quick Demo / Test Run'), findsOneWidget);
    expect(find.text('Fill Demo'), findsOneWidget);
    expect(find.text('Run AI Analysis'), findsOneWidget);

    // Tap Fill Demo
    await tester.tap(find.text('Fill Demo'));
    await tester.pump();

    // Verify symptom text is pre-filled
    expect(find.textContaining('Scratching a lot for 3 days'), findsOneWidget);
  });

  testWidgets('HealthCheckResultScreen displays fusion confidence and progression gauge', (tester) async {
    final result = HealthCheckResult(
      petName: 'Buddy',
      generatedAt: DateTime.now(),
      fusion: const FusionOutput(
        condition: 'Canine Atopic Dermatitis',
        finalConfidencePercent: 88,
        severityLabel: 'Moderate',
        modalities: [
          ModalityResult(
            name: 'Computer Vision',
            icon: Icons.camera_alt_rounded,
            available: true,
            confidencePercent: 89,
            qualityPercent: 92,
            contributionPercent: 45,
          ),
          ModalityResult(
            name: 'Collar Telemetry',
            icon: Icons.sensors_rounded,
            available: true,
            confidencePercent: 84,
            qualityPercent: 88,
            contributionPercent: 35,
          ),
          ModalityResult(
            name: 'Symptom NLP',
            icon: Icons.notes_rounded,
            available: true,
            confidencePercent: 78,
            qualityPercent: 80,
            contributionPercent: 20,
          ),
        ],
        notes: ['Wearable sensor frequency elevated during night rest.'],
      ),
      progression: const ProgressionOutput(
        horizonDays: 30,
        riskPercent: 62,
        riskLevel: RiskLevel.high,
        factors: [
          RiskFactor(
            label: 'Allergy History',
            scorePercent: 80,
            weightPercent: 40,
            contributionPoints: 32,
          ),
        ],
        mainReasons: ['Sustained scratching index exceeds 7-day average by 34%.'],
        recommendation: 'Veterinary consultation recommended within 24-48 hours.',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HealthCheckResultScreen(result: result),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Health Check Results'), findsOneWidget);
    expect(find.text('Canine Atopic Dermatitis'), findsOneWidget);
    expect(find.text('Confidence-Weighted Fusion'), findsOneWidget);
    expect(find.text('Disease Progression Risk (DPRPE)'), findsOneWidget);
    expect(find.text('Book Vet Consultation'), findsOneWidget);
  });
}
