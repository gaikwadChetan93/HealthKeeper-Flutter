import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/vital_module_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/chart_models.dart';
import '../widgets/time_range_selector.dart';
import '../widgets/trend_indicator_card.dart';
import '../widgets/vitals_line_chart.dart';
import '../widgets/vitals_stats_summary.dart';

class GenericVitalChartScreen extends ConsumerStatefulWidget {
  final String vitalKey;
  final int memberId;

  const GenericVitalChartScreen({
    super.key,
    required this.vitalKey,
    required this.memberId,
  });

  @override
  ConsumerState<GenericVitalChartScreen> createState() =>
      _GenericVitalChartScreenState();
}

class _GenericVitalChartScreenState
    extends ConsumerState<GenericVitalChartScreen> {
  TimeRange _timeRange = TimeRange.thirtyDays;

  @override
  Widget build(BuildContext context) {
    final dataPoints = _getDataPoints();
    final stats = _getStats(dataPoints);
    final color = VitalModuleColors.getIconTint(widget.vitalKey);

    if (dataPoints.isEmpty) {
      return Center(
        child: Text(
          'No data recorded yet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dataPoints.length >= 2)
            TrendIndicatorCard(
              lastValue: dataPoints.last.value,
              previousValue: dataPoints[dataPoints.length - 2].value,
              unit: stats.unit,
              label: 'Latest',
            ),
          const SizedBox(height: AppDimens.spacingL),
          TimeRangeSelector(
            selected: _timeRange,
            onChanged: (r) => setState(() => _timeRange = r),
          ),
          const SizedBox(height: AppDimens.spacingL),
          VitalsLineChart(
            dataPoints: dataPoints,
            primaryColor: color,
          ),
          const SizedBox(height: AppDimens.spacingXL),
          VitalsStatsSummary(stats: stats),
        ],
      ),
    );
  }

  List<ChartDataPoint> _getDataPoints() {
    return switch (widget.vitalKey) {
      'weight' => MockData.weightRecords(widget.memberId)
          .map((r) => ChartDataPoint(
                timestamp: r.measurementDate,
                value: r.weight,
              ))
          .toList(),
      'height' => MockData.heightRecords(widget.memberId)
          .map((r) => ChartDataPoint(
                timestamp: r.measurementDate,
                value: r.height,
              ))
          .toList(),
      'temperature' => MockData.temperatureRecords(widget.memberId)
          .map((r) => ChartDataPoint(
                timestamp: r.measurementDate,
                value: r.temperature,
              ))
          .toList(),
      'sleep' => MockData.sleepRecords(widget.memberId)
          .map((r) => ChartDataPoint(
                timestamp: r.sleepDate,
                value: r.hoursSlept,
              ))
          .toList(),
      'exercise' => MockData.exerciseRecords(widget.memberId)
          .map((r) => ChartDataPoint(
                timestamp: r.exerciseDate,
                value: r.duration.toDouble(),
              ))
          .toList(),
      'hydration' => MockData.hydrationRecords(widget.memberId)
          .map((r) => ChartDataPoint(
                timestamp: r.date,
                value: r.waterIntake,
              ))
          .toList(),
      _ => [],
    };
  }

  VitalsStats _getStats(List<ChartDataPoint> points) {
    if (points.isEmpty) return VitalsStats.empty;

    final values = points.map((p) => p.value).toList();
    values.sort();
    final sum = values.reduce((a, b) => a + b);

    final unit = switch (widget.vitalKey) {
      'weight' => 'kg',
      'height' => 'cm',
      'temperature' => '°F',
      'sleep' => 'hrs',
      'exercise' => 'min',
      'hydration' => 'ml',
      _ => '',
    };

    return VitalsStats(
      min: values.first,
      max: values.last,
      average: sum / values.length,
      lastValue: points.last.value,
      count: points.length,
      unit: unit,
    );
  }
}
