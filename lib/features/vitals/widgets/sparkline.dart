import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A small line with no axes, showing the shape of recent values.
class Sparkline extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double width;
  final double height;

  const Sparkline(
      {super.key,
      required this.values,
      required this.color,
      this.width = 84,
      this.height = 36});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return SizedBox(width: width, height: height);
    final spots = values.length == 1
        ? [
            FlSpot(0, values.first),
            FlSpot(1, values.first)
          ] // one reading: a flat line
        : [
            for (var i = 0; i < values.length; i++)
              FlSpot(i.toDouble(), values[i])
          ];
    final lo = values.reduce((a, b) => a < b ? a : b);
    final hi = values.reduce((a, b) => a > b ? a : b);
    final pad = hi == lo ? (hi.abs() * 0.1 + 1) : (hi - lo) * 0.2;

    return SizedBox(
      width: width,
      height: height,
      child: LineChart(
        LineChartData(
          minY: lo - pad,
          maxY: hi + pad,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: values.length > 2,
              preventCurveOverShooting: true,
              color: color,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, bar) => spot == bar.spots.last,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                    radius: 2.5, color: color, strokeWidth: 0),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0)
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: Duration.zero,
      ),
    );
  }
}
