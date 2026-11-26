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

class BloodPressureChartScreen extends ConsumerStatefulWidget {
  final int memberId;

  const BloodPressureChartScreen({super.key, required this.memberId});

  @override
  ConsumerState<BloodPressureChartScreen> createState() =>
      _BloodPressureChartScreenState();
}

class _BloodPressureChartScreenState
    extends ConsumerState<BloodPressureChartScreen> {
  TimeRange _timeRange = TimeRange.thirtyDays;

  @override
  Widget build(BuildContext context) {
    final records = MockData.bloodPressureRecords(widget.memberId);
    final dataPoints = records
        .map((r) => ChartDataPoint(
              timestamp: r.measurementDate,
              value: r.systolic.toDouble(),
              secondaryValue: r.diastolic.toDouble(),
            ))
        .toList();

    final systolicStats = VitalsStats(
      min: 115,
      max: 130,
      average: 121.6,
      lastValue: records.isNotEmpty ? records.first.systolic.toDouble() : 0,
      count: records.length,
      unit: 'mmHg',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health zone badge
          if (records.isNotEmpty)
            Row(
              children: [
                HealthZoneBadge(
                  zones: HealthZoneDefinitions.bloodPressureSystolic,
                  value: records.first.systolic.toDouble(),
                ),
                const SizedBox(width: AppDimens.spacingS),
                Text(
                  'Systolic',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),

          const SizedBox(height: AppDimens.spacingL),

          // Trend card
          if (records.length >= 2)
            TrendIndicatorCard(
              lastValue: records.first.systolic.toDouble(),
              previousValue: records[1].systolic.toDouble(),
              unit: 'mmHg',
              label: 'Latest Systolic',
            ),

          const SizedBox(height: AppDimens.spacingL),

          // Time range selector
          TimeRangeSelector(
            selected: _timeRange,
            onChanged: (r) => setState(() => _timeRange = r),
          ),

          const SizedBox(height: AppDimens.spacingL),

          // Dual line chart
          VitalsLineChart(
            dataPoints: dataPoints,
            showSecondaryLine: true,
            primaryColor: const Color(0xFFF97035),
            secondaryColor: const Color(0xFF42A5F5),
          ),

          const SizedBox(height: AppDimens.spacingS),

          // Legend
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: Color(0xFFF97035), label: 'Systolic'),
              SizedBox(width: AppDimens.spacingL),
              _LegendDot(color: Color(0xFF42A5F5), label: 'Diastolic'),
            ],
          ),

          const SizedBox(height: AppDimens.spacingXL),

          // Stats summary
          VitalsStatsSummary(stats: systolicStats),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
