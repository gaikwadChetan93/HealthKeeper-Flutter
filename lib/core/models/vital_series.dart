/// Trend data from the API's /vitals endpoints.

class VitalMetric {
  final String key;
  final String label;
  final String unit;

  /// Amounts that add up over a day (water, exercise) rather than readings.
  final bool isSum;

  const VitalMetric(
      {required this.key,
      required this.label,
      required this.unit,
      required this.isSum});

  factory VitalMetric.fromJson(Map<String, dynamic> j) => VitalMetric(
        key: j['key'] as String,
        label: j['label'] as String,
        unit: j['unit'] as String,
        isSum: j['agg'] == 'sum',
      );
}

class MetricStats {
  final int count;
  final double? min;
  final double? max;
  final double? avg;
  final double? latest;
  final double? first;
  final double? change;

  /// Average over the same length of time just before the chosen range.
  final double? previousAvg;
  final double? changeVsPrevious;

  const MetricStats({
    required this.count,
    this.min,
    this.max,
    this.avg,
    this.latest,
    this.first,
    this.change,
    this.previousAvg,
    this.changeVsPrevious,
  });

  static double? _d(dynamic v) => (v as num?)?.toDouble();

  factory MetricStats.fromJson(Map<String, dynamic> j) => MetricStats(
        count: j['count'] as int,
        min: _d(j['min']),
        max: _d(j['max']),
        avg: _d(j['avg']),
        latest: _d(j['latest']),
        first: _d(j['first']),
        change: _d(j['change']),
        previousAvg: _d(j['previous_avg']),
        changeVsPrevious: _d(j['change_vs_previous']),
      );
}

class SeriesPoint {
  final DateTime date;
  final Map<String, double> values;

  /// How many readings this point stands for.
  final int count;

  const SeriesPoint(
      {required this.date, required this.values, required this.count});

  factory SeriesPoint.fromJson(Map<String, dynamic> j) => SeriesPoint(
        date: _parseDate(j['date'] as String),
        values: {
          for (final e in (j['values'] as Map).entries)
            e.key as String: (e.value as num).toDouble(),
        },
        count: j['count'] as int,
      );
}

/// "2026-11-01" is a local day; a full timestamp is converted to local time.
DateTime _parseDate(String s) =>
    s.length == 10 ? DateTime.parse(s) : DateTime.parse(s).toLocal();

List<VitalMetric> _metrics(Map<String, dynamic> j) => [
      for (final m in j['metrics'] as List)
        VitalMetric.fromJson(m as Map<String, dynamic>)
    ];

Map<String, MetricStats> _stats(Map<String, dynamic> j) => {
      for (final e in (j['stats'] as Map).entries)
        e.key as String: MetricStats.fromJson(e.value as Map<String, dynamic>),
    };

List<SeriesPoint> _points(List<dynamic> list) =>
    [for (final p in list) SeriesPoint.fromJson(p as Map<String, dynamic>)];

/// Points for one vital's trend chart, and statistics per metric.
class VitalSeries {
  final String module;

  /// raw (each reading), day, week or month.
  final String interval;
  final List<VitalMetric> metrics;
  final List<SeriesPoint> points;
  final Map<String, MetricStats> stats;

  const VitalSeries({
    required this.module,
    required this.interval,
    required this.metrics,
    required this.points,
    required this.stats,
  });

  bool get isEmpty => points.isEmpty;

  factory VitalSeries.fromJson(Map<String, dynamic> j) => VitalSeries(
        module: j['module'] as String,
        interval: j['interval'] as String,
        metrics: _metrics(j),
        points: _points(j['points'] as List),
        stats: _stats(j),
      );
}

/// One card on the vitals dashboard.
class VitalSummary {
  final String module;
  final List<VitalMetric> metrics;
  final DateTime? latestDate;
  final Map<String, double> latestValues;

  /// Daily values over the summary window, for the mini chart.
  final List<SeriesPoint> sparkline;
  final Map<String, MetricStats> stats;

  const VitalSummary({
    required this.module,
    required this.metrics,
    required this.latestDate,
    required this.latestValues,
    required this.sparkline,
    required this.stats,
  });

  bool get hasReadings => latestDate != null;

  factory VitalSummary.fromJson(Map<String, dynamic> j) {
    final latest = j['latest'] as Map<String, dynamic>?;
    return VitalSummary(
      module: j['module'] as String,
      metrics: _metrics(j),
      latestDate: latest == null ? null : _parseDate(latest['date'] as String),
      latestValues: latest == null
          ? const {}
          : {
              for (final e in (latest['values'] as Map).entries)
                e.key as String: (e.value as num).toDouble(),
            },
      sparkline: _points(j['sparkline'] as List),
      stats: _stats(j),
    );
  }
}
