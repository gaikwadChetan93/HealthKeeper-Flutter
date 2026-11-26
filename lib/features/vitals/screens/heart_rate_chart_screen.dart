import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/chart_models.dart';
import '../../../core/models/health_zone_definitions.dart';
import '../widgets/health_zone_badge.dart';
import '../widgets/time_range_selector.dart';
import '../widgets/trend_indicator_card.dart';
import '../widgets/vitals_line_chart.dart';
import '../widgets/vitals_stats_summary.dart';

class HeartRateChartScreen extends ConsumerStatefulWidget {
  final int memberId;

  const HeartRateChartScreen({super.key, required this.memberId});

  @override
  ConsumerState<HeartRateChartScreen> createState() =>
      _HeartRateChartScreenState();
}

class _HeartRateChartScreenState
    extends ConsumerState<HeartRateChartScreen> {
  TimeRange _timeRange = TimeRange.thirtyDays;

  @override
  Widget build(BuildContext context) {
    final records = MockData.heartRateRecords(widget.memberId);
    final dataPoints = records
        .map((r) => ChartDataPoint(
              timestamp: r.measurementDate,
              value: r.bpm.toDouble(),
              label: r.activityContext?.displayName,
            ))
        .toList();

    final stats = VitalsStats(
      min: 68,
      max: 110,
      average: 83,
      lastValue: records.isNotEmpty ? records.first.bpm.toDouble() : 0,
      count: records.length,
      unit: 'bpm',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (records.isNotEmpty)
            HealthZoneBadge(
              zones: HealthZoneDefinitions.heartRate,
              value: records.first.bpm.toDouble(),
            ),
          const SizedBox(height: AppDimens.spacingL),
          if (records.length >= 2)
            TrendIndicatorCard(
              lastValue: records.first.bpm.toDouble(),
              previousValue: records[1].bpm.toDouble(),
              unit: 'bpm',
              label: 'Latest Heart Rate',
            ),
          const SizedBox(height: AppDimens.spacingL),
          TimeRangeSelector(
            selected: _timeRange,
            onChanged: (r) => setState(() => _timeRange = r),
          ),
          const SizedBox(height: AppDimens.spacingL),
          VitalsLineChart(
            dataPoints: dataPoints,
            primaryColor: const Color(0xFFFF6B8A),
          ),
          const SizedBox(height: AppDimens.spacingXL),
          VitalsStatsSummary(stats: stats),
        ],
      ),
    );
  }
}
