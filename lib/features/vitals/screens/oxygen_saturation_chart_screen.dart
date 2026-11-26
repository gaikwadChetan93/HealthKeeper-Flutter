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

class OxygenSaturationChartScreen extends ConsumerStatefulWidget {
  final int memberId;

  const OxygenSaturationChartScreen({super.key, required this.memberId});

  @override
  ConsumerState<OxygenSaturationChartScreen> createState() =>
      _OxygenSaturationChartScreenState();
}

class _OxygenSaturationChartScreenState
    extends ConsumerState<OxygenSaturationChartScreen> {
  TimeRange _timeRange = TimeRange.thirtyDays;

  @override
  Widget build(BuildContext context) {
    final records = MockData.oxygenSaturationRecords(widget.memberId);
    final dataPoints = records
        .map((r) => ChartDataPoint(
              timestamp: r.measurementDate,
              value: r.spO2,
            ))
        .toList();

    final stats = VitalsStats(
      min: 97,
      max: 99,
      average: 98,
      lastValue: records.isNotEmpty ? records.first.spO2 : 0,
      count: records.length,
      unit: '%',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (records.isNotEmpty)
            HealthZoneBadge(
              zones: HealthZoneDefinitions.oxygenSaturation,
              value: records.first.spO2,
            ),
          const SizedBox(height: AppDimens.spacingL),
          if (records.length >= 2)
            TrendIndicatorCard(
              lastValue: records.first.spO2,
              previousValue: records[1].spO2,
              unit: '%',
              label: 'Latest SpO2',
            ),
          const SizedBox(height: AppDimens.spacingL),
          TimeRangeSelector(
            selected: _timeRange,
            onChanged: (r) => setState(() => _timeRange = r),
          ),
          const SizedBox(height: AppDimens.spacingL),
          VitalsLineChart(
            dataPoints: dataPoints,
            primaryColor: const Color(0xFFFFB300),
          ),
          const SizedBox(height: AppDimens.spacingXL),
          VitalsStatsSummary(stats: stats),
        ],
      ),
    );
  }
}
