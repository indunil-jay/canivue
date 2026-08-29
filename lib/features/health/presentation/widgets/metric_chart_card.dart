import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:canivue/core/design_system/components/error_state.dart';
import 'package:canivue/core/design_system/components/skeleton_loader.dart';
import 'package:canivue/core/design_system/tokens/tokens.dart';
import 'package:canivue/core/widgets/luxury_segmented_bar.dart';
import 'package:canivue/features/health/domain/metric_series.dart';
import 'package:canivue/features/health/presentation/controllers/metrics_controller.dart';

/// Interactive health-monitoring chart (brief §10): metric selector, a
/// daily/weekly/monthly range switch, a baseline reference line, tooltips,
/// and abnormal points rendered as a distinct highlighted dot instead of
/// just more raw numbers.
class MetricChartCard extends ConsumerWidget {
  const MetricChartCard({super.key, required this.dogId});

  final String dogId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final metric = ref.watch(selectedMetricProvider);
    final range = ref.watch(selectedMetricRangeProvider);
    final seriesAsync = ref.watch(metricSeriesProvider((dogId: dogId, metric: metric, range: range)));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: HealthMetric.values.map((m) {
              final selected = m == metric;
              return ChoiceChip(
                label: Text(m.label),
                selected: selected,
                onSelected: (_) => ref.read(selectedMetricProvider.notifier).state = m,
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  fontWeight: FontWeight.bold,
                ),
                selectedColor: isDark ? AppColors.primaryOnDark : AppColors.primary,
                backgroundColor: isDark ? AppColors.darkElevatedSurface : AppColors.lightBackground,
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          LuxurySegmentedBar(
            segments: MetricTimeRange.values.map((r) => r.label).toList(),
            selectedIndex: range.index,
            onChanged: (index) => ref.read(selectedMetricRangeProvider.notifier).state = MetricTimeRange.values[index],
          ),
          const SizedBox(height: AppSpacing.xl),
          seriesAsync.when(
            loading: () => const SkeletonBox(height: 180),
            error: (_, _) => ErrorState(
              message: "We couldn't load this chart.",
              onRetry: () => ref.invalidate(metricSeriesProvider((dogId: dogId, metric: metric, range: range))),
            ),
            data: (series) => _Chart(series: series),
          ),
        ],
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.series});

  final MetricSeries series;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lineColor = isDark ? AppColors.primaryOnDark : AppColors.primary;
    final abnormalColor = isDark ? AppColors.errorOnDark : AppColors.error;
    final gridColor = (isDark ? AppColors.darkBorder : AppColors.lightBorder).withValues(alpha: 0.6);
    final labelColor = isDark ? AppColors.darkMutedText : AppColors.lightMutedText;

    final points = series.points;
    final values = points.map((p) => p.value).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b) * 0.92);
    final maxY = (values.reduce((a, b) => a > b ? a : b) * 1.08);

    String dateLabel(int index) {
      final date = points[index].date;
      return series.range == MetricTimeRange.daily ? DateFormat('h a').format(date) : DateFormat('MMM d').format(date);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Baseline avg: ${series.baselineAverage.toStringAsFixed(1)} ${series.metric.unit}',
              style: theme.textTheme.labelSmall?.copyWith(color: labelColor),
            ),
            if (points.any((p) => p.isAbnormal))
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(height: 8, width: 8, decoration: BoxDecoration(color: abnormalColor, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('Abnormal reading', style: theme.textTheme.labelSmall?.copyWith(color: abnormalColor, fontWeight: FontWeight.bold)),
                ],
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: (maxY - minY) / 3, getDrawingHorizontalLine: (_) => FlLine(color: gridColor, strokeWidth: 1)),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: (points.length / 4).clamp(1, points.length).toDouble(),
                    getTitlesWidget: (value, meta) {
                      final index = value.round();
                      if (index < 0 || index >= points.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(dateLabel(index), style: theme.textTheme.labelSmall?.copyWith(color: labelColor, fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),
              extraLinesData: ExtraLinesData(horizontalLines: [
                HorizontalLine(y: series.baselineAverage, color: labelColor.withValues(alpha: 0.6), strokeWidth: 1, dashArray: const [6, 4]),
              ]),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => isDark ? AppColors.darkElevatedSurface : AppColors.lightTextPrimary,
                  getTooltipItems: (spots) => spots.map((spot) {
                    final index = spot.x.round();
                    return LineTooltipItem(
                      '${spot.y.toStringAsFixed(1)} ${series.metric.unit}\n${dateLabel(index)}',
                      TextStyle(color: isDark ? AppColors.darkTextPrimary : Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [for (int i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].value)],
                  isCurved: true,
                  color: lineColor,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) {
                      final abnormal = points[index].isAbnormal;
                      return FlDotCirclePainter(
                        radius: abnormal ? 5 : 2.5,
                        color: abnormal ? abnormalColor : lineColor,
                        strokeWidth: abnormal ? 2 : 0,
                        strokeColor: (isDark ? AppColors.darkCard : AppColors.lightCard),
                      );
                    },
                  ),
                  belowBarData: BarAreaData(show: true, color: lineColor.withValues(alpha: isDark ? 0.12 : 0.08)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
