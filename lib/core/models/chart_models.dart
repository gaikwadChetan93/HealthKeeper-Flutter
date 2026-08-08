enum TimeRange {
  sevenDays('7 Days', 7),
  thirtyDays('30 Days', 30),
  ninetyDays('90 Days', 90),
  all('All', null),
  custom('Custom', null);

  final String displayName;
  final int? days;
  const TimeRange(this.displayName, this.days);
}

enum ChartType { line, bar, area }

class ChartDataPoint {
  final DateTime timestamp;
  final double value;
  final double? secondaryValue;
  final String? label;
  final String? context;

  const ChartDataPoint({
    required this.timestamp,
    required this.value,
    this.secondaryValue,
    this.label,
    this.context,
  });
}

class VitalsStats {
  final double min;
  final double max;
  final double average;
  final double? median;
  final double lastValue;
  final int count;
  final String unit;

  const VitalsStats({
    required this.min,
    required this.max,
    required this.average,
    this.median,
    required this.lastValue,
    required this.count,
    this.unit = '',
  });

  static const empty = VitalsStats(
    min: 0,
    max: 0,
    average: 0,
    lastValue: 0,
    count: 0,
  );
}

class DualVitalsStats {
  final VitalsStats primary;
  final VitalsStats secondary;

  const DualVitalsStats({
    required this.primary,
    required this.secondary,
  });
}

class ChartUiState {
  final List<ChartDataPoint> dataPoints;
  final VitalsStats stats;
  final ChartDataPoint? selectedPoint;
  final TimeRange timeRange;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final bool isLoading;
  final String? error;
  final bool showPrimaryLine;
  final bool showSecondaryLine;

  const ChartUiState({
    this.dataPoints = const [],
    this.stats = VitalsStats.empty,
    this.selectedPoint,
    this.timeRange = TimeRange.thirtyDays,
    this.customStartDate,
    this.customEndDate,
    this.isLoading = false,
    this.error,
    this.showPrimaryLine = true,
    this.showSecondaryLine = true,
  });

  ChartUiState copyWith({
    List<ChartDataPoint>? dataPoints,
    VitalsStats? stats,
    ChartDataPoint? selectedPoint,
    TimeRange? timeRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
    bool? isLoading,
    String? error,
    bool? showPrimaryLine,
    bool? showSecondaryLine,
  }) {
    return ChartUiState(
      dataPoints: dataPoints ?? this.dataPoints,
      stats: stats ?? this.stats,
      selectedPoint: selectedPoint ?? this.selectedPoint,
      timeRange: timeRange ?? this.timeRange,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      showPrimaryLine: showPrimaryLine ?? this.showPrimaryLine,
      showSecondaryLine: showSecondaryLine ?? this.showSecondaryLine,
    );
  }
}
