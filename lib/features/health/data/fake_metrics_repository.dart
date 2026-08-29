import 'dart:math';

import 'package:canivue/features/health/domain/metric_series.dart';
import 'package:canivue/features/health/domain/metrics_repository.dart';

/// Generates a plausible, deterministic-per-dog series with a baseline and
/// the occasional abnormal point, so the UI has real "highlight the
/// abnormal change" moments to render (brief §10) instead of a flat line.
class FakeMetricsRepository implements MetricsRepository {
  static const _baselines = {
    HealthMetric.heartRate: 76.0,
    HealthMetric.activity: 7200.0,
    HealthMetric.sleep: 8.6,
    HealthMetric.temperature: 38.5,
    HealthMetric.weight: 24.0,
    HealthMetric.hydration: 600.0,
  };

  static const _variance = {
    HealthMetric.heartRate: 10.0,
    HealthMetric.activity: 2200.0,
    HealthMetric.sleep: 1.4,
    HealthMetric.temperature: 0.3,
    HealthMetric.weight: 0.6,
    HealthMetric.hydration: 120.0,
  };

  int _pointCount(MetricTimeRange range) => switch (range) {
        MetricTimeRange.daily => 12,
        MetricTimeRange.weekly => 7,
        MetricTimeRange.monthly => 30,
      };

  Duration _step(MetricTimeRange range) => switch (range) {
        MetricTimeRange.daily => const Duration(hours: 2),
        MetricTimeRange.weekly => const Duration(days: 1),
        MetricTimeRange.monthly => const Duration(days: 1),
      };

  @override
  Future<MetricSeries> fetchSeries(String dogId, HealthMetric metric, MetricTimeRange range) async {
    await Future.delayed(const Duration(milliseconds: 450));

    final baseline = _baselines[metric]!;
    final variance = _variance[metric]!;
    final count = _pointCount(range);
    final step = _step(range);
    final seed = dogId.hashCode ^ metric.index ^ range.index;
    final random = Random(seed);
    final abnormalIndex = count > 3 ? random.nextInt(count - 2) + 1 : -1;

    final now = DateTime.now();
    final points = <MetricPoint>[];
    for (int i = count - 1; i >= 0; i--) {
      final date = now.subtract(step * i);
      final isAbnormal = (count - 1 - i) == abnormalIndex;
      final wobble = (random.nextDouble() - 0.5) * 2 * variance * 0.4;
      final spike = isAbnormal ? variance * (random.nextBool() ? 1.6 : -1.6) : 0.0;
      final value = (baseline + wobble + spike).clamp(baseline - variance * 2, baseline + variance * 2.2);
      points.add(MetricPoint(date: date, value: value, isAbnormal: isAbnormal));
    }

    return MetricSeries(metric: metric, range: range, points: points, baselineAverage: baseline);
  }
}
