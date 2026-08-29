/// Health-monitoring metrics (brief §10): trackable vitals, each viewable
/// over a selectable time range with a baseline for comparison so screens
/// can highlight abnormal changes instead of dumping raw numbers.
enum HealthMetric { heartRate, activity, sleep, temperature, weight, hydration }

enum MetricTimeRange { daily, weekly, monthly }

extension HealthMetricLabels on HealthMetric {
  String get label => switch (this) {
        HealthMetric.heartRate => 'Heart Rate',
        HealthMetric.activity => 'Activity',
        HealthMetric.sleep => 'Sleep',
        HealthMetric.temperature => 'Temperature',
        HealthMetric.weight => 'Weight',
        HealthMetric.hydration => 'Hydration',
      };

  String get unit => switch (this) {
        HealthMetric.heartRate => 'bpm',
        HealthMetric.activity => 'steps',
        HealthMetric.sleep => 'hrs',
        HealthMetric.temperature => '°C',
        HealthMetric.weight => 'kg',
        HealthMetric.hydration => 'ml',
      };
}

extension MetricTimeRangeLabels on MetricTimeRange {
  String get label => switch (this) {
        MetricTimeRange.daily => 'Daily',
        MetricTimeRange.weekly => 'Weekly',
        MetricTimeRange.monthly => 'Monthly',
      };
}

class MetricPoint {
  const MetricPoint({required this.date, required this.value, this.isAbnormal = false});

  final DateTime date;
  final double value;
  final bool isAbnormal;
}

class MetricSeries {
  const MetricSeries({
    required this.metric,
    required this.range,
    required this.points,
    required this.baselineAverage,
  });

  final HealthMetric metric;
  final MetricTimeRange range;
  final List<MetricPoint> points;

  /// The dog's historical baseline average for this metric, used to draw a
  /// reference line and judge whether recent points are abnormal.
  final double baselineAverage;
}
