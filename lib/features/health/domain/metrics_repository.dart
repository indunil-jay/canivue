import 'package:canivue/features/health/domain/metric_series.dart';

abstract class MetricsRepository {
  Future<MetricSeries> fetchSeries(String dogId, HealthMetric metric, MetricTimeRange range);
}
