import 'package:intl/intl.dart';

import '../../core/models/vital_series.dart';

/// Display text for vital values.
class VitalFormat {
  VitalFormat._();

  static String number(double v, {int decimals = 1}) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(decimals);
  }

  /// "120/80" for blood pressure, "45 min · 300 kcal" for exercise, "68.5" otherwise.
  static String values(List<VitalMetric> metrics, Map<String, double> values,
      {int decimals = 1}) {
    String? v(VitalMetric m) => values[m.key] == null
        ? null
        : number(values[m.key]!, decimals: decimals);
    if (metrics.length == 2 && metrics[0].unit == metrics[1].unit) {
      final a = v(metrics[0]), b = v(metrics[1]);
      if (a != null && b != null) return '$a/$b';
    }
    if (metrics.length > 1) {
      return [
        for (final m in metrics)
          if (v(m) != null) '${v(m)} ${m.unit}',
      ].join(' · ');
    }
    return v(metrics.first) ?? '—';
  }

  /// The unit to show after [values], or empty when it is already included.
  static String unit(List<VitalMetric> metrics) {
    if (metrics.length == 1 || metrics[0].unit == metrics[1].unit)
      return metrics.first.unit;
    return '';
  }

  /// "Today", "Yesterday", "3 days ago" or a date.
  static String when(DateTime date, {DateTime? now}) {
    now ??= DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(date.year, date.month, date.day))
        .inDays;
    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    return DateFormat('d MMM yyyy').format(date);
  }

  /// "+4.5", "−2", "No change".
  static String change(double diff, {int decimals = 1}) {
    if (diff.abs() < 0.05) return 'No change';
    return '${diff > 0 ? '+' : '−'}${number(diff.abs(), decimals: decimals)}';
  }
}
