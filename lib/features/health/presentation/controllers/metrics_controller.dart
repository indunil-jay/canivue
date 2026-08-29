import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:canivue/features/health/data/fake_metrics_repository.dart';
import 'package:canivue/features/health/domain/metric_series.dart';
import 'package:canivue/features/health/domain/metrics_repository.dart';

final metricsRepositoryProvider = Provider<MetricsRepository>((ref) => FakeMetricsRepository());

typedef MetricQuery = ({String dogId, HealthMetric metric, MetricTimeRange range});

final metricSeriesProvider = FutureProvider.family<MetricSeries, MetricQuery>((ref, query) {
  return ref.watch(metricsRepositoryProvider).fetchSeries(query.dogId, query.metric, query.range);
});

/// UI-selection state — which metric and time range the health chart card
/// is currently showing. Kept per-widget-tree-lifetime (not per dog) so the
/// user's chosen view persists while switching dogs.
final selectedMetricProvider = StateProvider<HealthMetric>((ref) => HealthMetric.heartRate);
final selectedMetricRangeProvider = StateProvider<MetricTimeRange>((ref) => MetricTimeRange.weekly);
