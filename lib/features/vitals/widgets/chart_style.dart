import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/vital_series.dart';

/// Labels, axis range and text style shared by the trend charts.
mixin ChartStyle {
  /// Full date for a tooltip.
  String dateLabel(VitalSeries series, DateTime d) {
    if (series.interval == 'month') return DateFormat('MMM yy').format(d);
    if (series.interval == 'raw') return DateFormat('d MMM, h:mm a').format(d);
    return DateFormat('d MMM yyyy').format(d);
  }

  /// Short date under the chart.
  String axisLabel(VitalSeries series, DateTime d) => series.interval == 'month'
      ? DateFormat('MMM yy').format(d)
      : DateFormat('d MMM').format(d);

  /// Y axis range rounded to tidy steps (1, 2, 2.5 or 5 × 10ⁿ) with about four
  /// gridlines, so the labels read 60 · 80 · 100 rather than 63 · 85 · 106.
  (double, double, double) yRange(Iterable<double> values,
      {required bool fromZero}) {
    var lo = values.reduce(math.min), hi = values.reduce(math.max);
    if (fromZero) lo = 0;
    if (hi - lo < 1e-9) {
      final pad = math.max(hi.abs() * 0.1, 1);
      lo = fromZero ? 0 : lo - pad;
      hi += pad;
    }
    final step = niceStep((hi - lo) / 4);
    final min = fromZero ? 0.0 : (lo / step).floor() * step;
    var max = (hi / step).ceil() * step;
    if (max - hi < step * 0.15) max += step; // room above the highest point
    return (min, max, step);
  }

  static double niceStep(double rough) {
    final mag = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
    for (final m in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
      if (rough <= m * mag) return m * mag;
    }
    return 10 * mag;
  }

  TextStyle? small(BuildContext c) => Theme.of(c)
      .textTheme
      .labelSmall
      ?.copyWith(color: Theme.of(c).colorScheme.onSurfaceVariant, fontSize: 10);
}
