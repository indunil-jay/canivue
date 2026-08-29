/// Long-term health insights (brief §30) — trend statements distilled from
/// raw sensor history, e.g. "activity increased 12% this month", rather
/// than dumping raw numbers on the owner.
enum TrendDirection { up, down, stable }

class HealthInsight {
  const HealthInsight({required this.headline, required this.detail, required this.direction, this.isPositive = true});

  final String headline;
  final String detail;
  final TrendDirection direction;

  /// Whether this trend is good news (e.g. activity up) or worth watching
  /// (e.g. sleep quality down) — independent of the arrow direction, since
  /// "down" is good for something like resting heart rate.
  final bool isPositive;
}
