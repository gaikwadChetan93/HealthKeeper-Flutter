import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/models/lab.dart';
import '../../vitals/widgets/chart_style.dart';
import '../lab_format.dart';

/// One test over time. Each point is coloured by its flag; behind the line is
/// the latest report's range, or the guideline bands when that's what was used.
class LabTrendChart extends StatelessWidget with ChartStyle {
  final LabSeries series;

  const LabTrendChart({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pts = series.points;
    if (pts.isEmpty) return const SizedBox(height: 220);
    final start = pts.first.takenOn;
    double x(DateTime d) => d.difference(start).inDays.toDouble();
    final span = x(pts.last.takenOn);
    final latest = pts.last;
    final reportRange = latest.rangeSource == 'report' ? latest : null;
    final values = [
      ...pts.map((p) => p.value),
      if (reportRange?.refLow != null) reportRange!.refLow!,
      if (reportRange?.refHigh != null) reportRange!.refHigh!,
    ];
    final (minY, maxY, step) = yRange(values, fromZero: false);
    final d = series.decimals + 1;

    final bands = <HorizontalRangeAnnotation>[
      if (reportRange != null)
        HorizontalRangeAnnotation(
          y1: math.max(reportRange.refLow ?? minY, minY),
          y2: math.min(reportRange.refHigh ?? maxY, maxY),
          color: AppColors.zoneNormal.withValues(alpha: 0.09),
        )
      else if (series.guideline != null)
        for (final b in series.guideline!.bands)
          if ((b.max ?? maxY) > minY && (b.min ?? minY) < maxY)
            HorizontalRangeAnnotation(
              y1: math.max(b.min ?? minY, minY),
              y2: math.min(b.max ?? maxY, maxY),
              color: LabFormat.color(b.level, theme.colorScheme)
                  .withValues(alpha: 0.08),
            ),
    ];

    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, right: 16),
        child: LineChart(LineChartData(
          minX: span == 0 ? -1 : -span * 0.04,
          maxX: span == 0 ? 1 : span * 1.04,
          minY: minY,
          maxY: maxY,
          rangeAnnotations: RangeAnnotations(horizontalRangeAnnotations: bands),
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
                getTitlesWidget: (v, _) => Text(
                    LabFormat.number(v, step < 1 ? 2 : 0),
                    style: small(context)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: span > 0,
                reservedSize: 24,
                interval: math.max(span / 3, 1),
                getTitlesWidget: (v, _) => (v < 0 || v > span)
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                            DateFormat('MMM yy')
                                .format(start.add(Duration(days: v.round()))),
                            style: small(context)),
                      ),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (final p in pts) FlSpot(x(p.takenOn), p.value)],
              color: theme.colorScheme.primary,
              barWidth: 2,
              dotData: FlDotData(
                getDotPainter: (spot, _, __, i) => FlDotCirclePainter(
                  radius: 5,
                  color: LabFormat.color(pts[i].flag, theme.colorScheme),
                  strokeWidth: 2,
                  strokeColor: theme.colorScheme.surface,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => theme.colorScheme.inverseSurface,
              fitInsideHorizontally: true,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${DateFormat('d MMM yyyy').format(pts[s.spotIndex].takenOn)}\n',
                    TextStyle(
                        color: theme.colorScheme.onInverseSurface,
                        fontSize: 11),
                    children: [
                      TextSpan(
                        text:
                            '${LabFormat.number(s.y, d)} ${series.unit} · ${LabFormat.chip(pts[s.spotIndex])}',
                        style: TextStyle(
                            color: theme.colorScheme.onInverseSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 13),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
