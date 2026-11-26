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

class BloodGlucoseChartScreen extends ConsumerStatefulWidget {
  final int memberId;

  const BloodGlucoseChartScreen({super.key, required this.memberId});

  @override
  ConsumerState<BloodGlucoseChartScreen> createState() =>
      _BloodGlucoseChartScreenState();
}

class _BloodGlucoseChartScreenState
    extends ConsumerState<BloodGlucoseChartScreen> {
  TimeRange _timeRange = TimeRange.thirtyDays;

  @override
  Widget build(BuildContext context) {
    final records = MockData.bloodGlucoseRecords(widget.memberId);
    final dataPoints = records
        .map((r) => ChartDataPoint(
              timestamp: r.measurementDate,
              value: r.glucose,
              label: r.mealContext?.displayName,
            ))
        .toList();

    final stats = VitalsStats(
      min: 88,
      max: 140,
      average: 107,
      lastValue: records.isNotEmpty ? records.first.glucose : 0,
      count: records.length,
      unit: 'mg/dL',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (records.isNotEmpty)
            HealthZoneBadge(
              zones: HealthZoneDefinitions.bloodGlucose,
              value: records.first.glucose,
            ),
          const SizedBox(height: AppDimens.spacingL),
          if (records.length >= 2)
            TrendIndicatorCard(
              lastValue: records.first.glucose,
              previousValue: records[1].glucose,
              unit: 'mg/dL',
              label: 'Latest Glucose',
            ),
          const SizedBox(height: AppDimens.spacingL),
          TimeRangeSelector(
            selected: _timeRange,
            onChanged: (r) => setState(() => _timeRange = r),
          ),
          const SizedBox(height: AppDimens.spacingL),
          VitalsLineChart(
            dataPoints: dataPoints,
            primaryColor: const Color(0xFFAB47BC),
          ),
          const SizedBox(height: AppDimens.spacingXL),
          VitalsStatsSummary(stats: stats),
        ],
      ),
    );
  }
}
