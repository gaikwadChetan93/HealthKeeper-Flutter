import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/models/chart_models.dart';
import '../../../core/models/vital_series.dart';
import '../config/vital_chart_config.dart';
import '../vital_format.dart';
import 'chart_style.dart';
import 'trend_bar_chart.dart';

/// Trend chart for one vital. Lines on a real time axis (readings far apart are
/// drawn far apart) with the health zones shaded behind; bars for daily amounts
/// ([TrendBarChart]).
class TrendChart extends StatelessWidget with ChartStyle {
  final VitalSeries series;
  final VitalChartConfig? config;
  final List<Color> colors;

  const TrendChart(
      {super.key,
      required this.series,
      required this.config,
      required this.colors});

  static const height = 240.0;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) return const SizedBox(height: height);
    final bars = config?.chartType == ChartType.bar;
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, right: 16),
        child: bars
            ? TrendBarChart(series: series, colors: colors)
            : _lines(context),
      ),
    );
  }

  Widget _lines(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = series.metrics.take(2).toList();
    final start = series.points.first.date;
    double x(DateTime d) => d.difference(start).inMinutes / (60 * 24);
    final span = x(series.points.last.date);
    final all = [
      for (final p in series.points)
        ...metrics.map((m) => p.values[m.key]).whereType<double>()
    ];
    final (minY, maxY, step) = yRange(all, fromZero: false);
    final zones = metrics.length == 1 ? config?.healthZones : null;
    final decimals = config?.decimalPlaces ?? 1;

    return LineChart(
      LineChartData(
        minX: span == 0 ? -1 : -span * 0.03,
        maxX: span == 0 ? 1 : span * 1.03,
        minY: minY,
        maxY: maxY,
        rangeAnnotations: RangeAnnotations(horizontalRangeAnnotations: [
          if (zones != null)
            for (final z in zones.zones)
              if (z.max >= minY && z.min <= maxY)
                HorizontalRangeAnnotation(
                  y1: math.max(z.min, minY),
                  y2: math.min(z.max + 1, maxY),
                  color: z.color.withValues(alpha: 0.07),
                ),
        ]),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: step,
          getDrawingHorizontalLine: (_) => FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
              strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: step,
              getTitlesWidget: (v, meta) => Text(
                  VitalFormat.number(v, decimals: step < 1 ? 1 : 0),
                  style: small(context)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: span > 0,
              reservedSize: 24,
              interval: math.max(span / 3, 0.01),
              getTitlesWidget: (v, meta) => (v < 0 || v > span)
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                          axisLabel(
                              series,
                              start.add(
                                  Duration(minutes: (v * 24 * 60).round()))),
                          style: small(context)),
                    ),
            ),
          ),
        ),
        lineBarsData: [
          for (var i = 0; i < metrics.length; i++)
            LineChartBarData(
              spots: [
                for (final p in series.points)
                  if (p.values[metrics[i].key] != null)
                    FlSpot(x(p.date), p.values[metrics[i].key]!),
              ],
              isCurved: series.points.length > 2,
              preventCurveOverShooting: true,
              color: colors[i % colors.length],
              barWidth: 2.5,
              dotData: FlDotData(
                show: series.points.length <= 40,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3.2,
                  color: colors[i % colors.length],
                  strokeWidth: 1.5,
                  strokeColor: theme.colorScheme.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: metrics.length == 1,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors[0].withValues(alpha: 0.18),
                    colors[0].withValues(alpha: 0)
                  ],
                ),
              ),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.inverseSurface,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (spots) => [
              for (var i = 0; i < spots.length; i++)
                LineTooltipItem(
                  i == 0
                      ? '${dateLabel(series, start.add(Duration(minutes: (spots[i].x * 24 * 60).round())))}\n'
                      : '',
                  TextStyle(
                      color: theme.colorScheme.onInverseSurface, fontSize: 11),
                  children: [
                    TextSpan(
                      text:
                          '${metrics.length > 1 ? '${metrics[spots[i].barIndex].label} ' : ''}'
                          '${VitalFormat.number(spots[i].y, decimals: decimals)} ${metrics[spots[i].barIndex].unit}',
                      style: TextStyle(
                          color: spots[i].bar.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
