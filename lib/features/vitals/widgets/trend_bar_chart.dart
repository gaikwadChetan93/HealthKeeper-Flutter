import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/models/vital_series.dart';
import '../vital_format.dart';
import 'chart_style.dart';

/// Bars for amounts that add up over a day (water, exercise minutes). Over weeks
/// or months each bar is the average day.
class TrendBarChart extends StatelessWidget with ChartStyle {
  final VitalSeries series;
  final List<Color> colors;

  const TrendBarChart({super.key, required this.series, required this.colors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metric =
        series.metrics.first; // exercise: minutes; calories show in the stats
    final points =
        series.points.where((p) => p.values[metric.key] != null).toList();
    final (_, maxY, step) =
        yRange(points.map((p) => p.values[metric.key]!), fromZero: true);
    final width = (220 / math.max(points.length, 1)).clamp(3.0, 18.0);
    final labelEvery = math.max((points.length / 4).ceil(), 1);

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: step,
          getDrawingHorizontalLine: (_) => FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
              strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: step,
              getTitlesWidget: (v, meta) => Text(
                  VitalFormat.number(v, decimals: step < 1 ? 1 : 0),
                  style: small(context)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= points.length || i % labelEvery != 0)
                  return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(axisLabel(series, points[i].date),
                      style: small(context)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: points[i].values[metric.key]!,
                width: width,
                color: colors.first,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(width / 3)),
              ),
            ]),
        ],
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.inverseSurface,
            fitInsideHorizontally: true,
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              '${dateLabel(series, points[group.x].date)}\n',
              TextStyle(
                  color: theme.colorScheme.onInverseSurface, fontSize: 11),
              children: [
                TextSpan(
                  text: '${VitalFormat.number(rod.toY)} ${metric.unit}'
                      '${series.interval == 'week' || series.interval == 'month' ? ' a day' : ''}',
                  style: TextStyle(
                      color: colors.first,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
