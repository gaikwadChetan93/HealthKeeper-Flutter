import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/models/chart_models.dart';

class VitalsLineChart extends StatelessWidget {
  final List<ChartDataPoint> dataPoints;
  final bool showSecondaryLine;
  final Color? primaryColor;
  final Color? secondaryColor;

  const VitalsLineChart({
    super.key,
    required this.dataPoints,
    this.showSecondaryLine = false,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data to display')),
      );
    }

    final theme = Theme.of(context);
    final primary = primaryColor ?? theme.colorScheme.primary;
    final secondary = secondaryColor ?? theme.colorScheme.secondary;

    final primarySpots = dataPoints.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final secondarySpots = showSecondaryLine
        ? dataPoints.asMap().entries
            .where((e) => e.value.secondaryValue != null)
            .map((e) => FlSpot(e.key.toDouble(), e.value.secondaryValue!))
            .toList()
        : <FlSpot>[];

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(
          right: AppDimens.spacingL,
          top: AppDimens.spacingM,
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (value) => FlLine(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      value.toInt().toString(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: (dataPoints.length / 5).ceilToDouble().clamp(1, 30),
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= dataPoints.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('d/M').format(dataPoints[idx].timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 9,
                        ),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: primarySpots,
                isCurved: true,
                color: primary,
                barWidth: 2.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                    radius: 3,
                    color: primary,
                    strokeWidth: 1.5,
                    strokeColor: Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: primary.withValues(alpha: 0.1),
                ),
              ),
              if (showSecondaryLine && secondarySpots.isNotEmpty)
                LineChartBarData(
                  spots: secondarySpots,
                  isCurved: true,
                  color: secondary,
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                      radius: 2.5,
                      color: secondary,
                      strokeWidth: 1.5,
                      strokeColor: Colors.white,
                    ),
                  ),
                ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) {
                  return spots.map((spot) {
                    return LineTooltipItem(
                      spot.y.toStringAsFixed(1),
                      TextStyle(
                        color: spot.bar.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
