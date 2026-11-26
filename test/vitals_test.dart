import 'package:flutter_test/flutter_test.dart';
import 'package:health_keeper/core/models/health_zone_definitions.dart';
import 'package:health_keeper/core/models/vital_series.dart';
import 'package:health_keeper/features/vitals/vital_format.dart';
import 'package:health_keeper/features/vitals/widgets/chart_style.dart';

class _Style with ChartStyle {}

const _bp = [
  VitalMetric(key: 'systolic', label: 'Systolic', unit: 'mmHg', isSum: false),
  VitalMetric(key: 'diastolic', label: 'Diastolic', unit: 'mmHg', isSum: false),
];
const _exercise = [
  VitalMetric(key: 'duration', label: 'Duration', unit: 'min', isSum: true),
  VitalMetric(key: 'calories', label: 'Calories', unit: 'kcal', isSum: true),
];

void main() {
  test('values read naturally', () {
    expect(
        VitalFormat.values(_bp, {'systolic': 120, 'diastolic': 80}), '120/80');
    expect(VitalFormat.unit(_bp), 'mmHg');
    expect(VitalFormat.values(_exercise, {'duration': 45, 'calories': 300}),
        '45 min · 300 kcal');
    expect(VitalFormat.unit(_exercise), '');
    expect(VitalFormat.number(68.456), '68.5');
    expect(VitalFormat.change(-3), '−3');
    expect(VitalFormat.change(0.01), 'No change');
  });

  test('relative days', () {
    final now = DateTime(2026, 11, 25, 9);
    expect(VitalFormat.when(DateTime(2026, 11, 25, 7), now: now), 'Today');
    expect(VitalFormat.when(DateTime(2026, 11, 24, 23), now: now), 'Yesterday');
    expect(VitalFormat.when(DateTime(2026, 11, 22), now: now), '3 days ago');
    expect(VitalFormat.when(DateTime(2026, 10, 1), now: now), '1 Oct 2026');
  });

  test('chart axes use tidy steps', () {
    final s = _Style();
    expect(s.yRange([63, 127], fromZero: false), (60.0, 140.0, 20.0));
    expect(s.yRange([602, 3092], fromZero: true), (0.0, 4000.0, 1000.0));
    final (lo, hi, step) = s.yRange([65.5, 70.2], fromZero: false);
    expect([lo, hi, step], [64.0, 72.0, 2.0]);
    final (flatLo, flatHi, _) = s.yRange([7, 7], fromZero: false);
    expect(flatLo < 7 && flatHi > 7, isTrue);
  });

  test('a value between two zones falls in the one it has reached', () {
    expect(HealthZoneDefinitions.bloodGlucose.getZoneForValue(99.5).label,
        'In fasting range');
    expect(HealthZoneDefinitions.bloodGlucose.getZoneForValue(100).label,
        'Above range');
    expect(
        HealthZoneDefinitions.bloodPressureSystolic.getZoneForValue(89.5).label,
        'Low');
  });

  test('series from the API', () {
    final s = VitalSeries.fromJson({
      'module': 'blood_pressure',
      'interval': 'raw',
      'metrics': [
        {'key': 'systolic', 'label': 'Systolic', 'unit': 'mmHg', 'agg': 'avg'},
      ],
      'points': [
        {
          'date': '2026-11-01T13:30:00+05:30',
          'values': {'systolic': 120},
          'count': 1
        },
        {
          'date': '2026-11-02',
          'values': {'systolic': 125.5},
          'count': 2
        },
      ],
      'stats': {
        'systolic': {
          'count': 2,
          'min': 120,
          'max': 125.5,
          'avg': 122.75,
          'latest': 125.5,
          'previous_avg': null
        },
      },
    });
    expect(s.points.first.date, DateTime.utc(2026, 11, 1, 8).toLocal());
    expect(s.points.last.date, DateTime(2026, 11, 2));
    expect(s.stats['systolic']!.avg, 122.75);
    expect(s.stats['systolic']!.previousAvg, isNull);
  });
}
