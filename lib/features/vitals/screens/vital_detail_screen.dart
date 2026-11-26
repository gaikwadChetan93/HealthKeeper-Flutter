import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/vital_module_colors.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/blood_glucose.dart';
import '../../../core/models/blood_pressure.dart';
import '../../../core/models/exercise.dart';
import '../../../core/models/heart_rate.dart';
import '../../../core/models/height.dart';
import '../../../core/models/hydration.dart';
import '../../../core/models/oxygen_saturation.dart';
import '../../../core/models/sleep.dart';
import '../../../core/models/temperature.dart';
import '../../../core/models/weight.dart';
import '../../../core/state/module_providers.dart';

/// One plotted reading. [secondary] is only set for blood pressure
/// (diastolic alongside systolic) — every other vital charts a single line.
class _Point {
  final int recordId;
  final DateTime date;
  final double primary;
  final double? secondary;
  final String display;

  const _Point({
    required this.recordId,
    required this.date,
    required this.primary,
    this.secondary,
    required this.display,
  });
}

class _Series {
  final List<_Point> points;
  final String unit;
  final String? secondaryLabel;
  final void Function(WidgetRef ref, int recordId) onDelete;

  const _Series({
    required this.points,
    required this.unit,
    this.secondaryLabel,
    required this.onDelete,
  });
}

_Series? _buildSeries(WidgetRef ref, String moduleKey, int memberId) {
  List<T>? sorted<T>(List<T>? records, DateTime Function(T) dateOf) {
    if (records == null || records.isEmpty) return null;
    final list = [...records]..sort((a, b) => dateOf(a).compareTo(dateOf(b)));
    return list;
  }

  switch (moduleKey) {
    case 'blood_pressure':
      final list = sorted(ref.watch(bloodPressureProvider(memberId)).records.valueOrNull, (BloodPressure r) => r.measurementDate);
      if (list == null) return null;
      return _Series(
        unit: 'mmHg',
        secondaryLabel: 'Diastolic',
        onDelete: (ref, id) => ref.read(bloodPressureProvider(memberId).notifier).removeRecord(id),
        points: [
          for (final r in list)
            _Point(
              recordId: r.id,
              date: r.measurementDate,
              primary: r.systolic.toDouble(),
              secondary: r.diastolic.toDouble(),
              display: '${r.systolic}/${r.diastolic}',
            ),
        ],
      );
    case 'weight':
      final list = sorted(ref.watch(weightProvider(memberId)).records.valueOrNull, (Weight r) => r.measurementDate);
      if (list == null) return null;
      return _Series(
        unit: list.last.unit.abbreviation,
        onDelete: (ref, id) => ref.read(weightProvider(memberId).notifier).removeRecord(id),
        points: [
          for (final r in list)
            _Point(recordId: r.id, date: r.measurementDate, primary: r.weight, display: r.weight.toStringAsFixed(1)),
        ],
      );
    case 'height':
      final list = sorted(ref.watch(heightProvider(memberId)).records.valueOrNull, (Height r) => r.measurementDate);
      if (list == null) return null;
      return _Series(
        unit: list.last.unit.abbreviation,
        onDelete: (ref, id) => ref.read(heightProvider(memberId).notifier).removeRecord(id),
        points: [
          for (final r in list)
            _Point(recordId: r.id, date: r.measurementDate, primary: r.height, display: r.height.toStringAsFixed(0)),
        ],
      );
    case 'blood_glucose':
      final list = sorted(ref.watch(bloodGlucoseProvider(memberId)).records.valueOrNull, (BloodGlucose r) => r.measurementDate);
      if (list == null) return null;
      return _Series(
        unit: list.last.unit.abbreviation,
        onDelete: (ref, id) => ref.read(bloodGlucoseProvider(memberId).notifier).removeRecord(id),
        points: [
          for (final r in list)
            _Point(recordId: r.id, date: r.measurementDate, primary: r.glucose, display: r.glucose.toStringAsFixed(0)),
        ],
      );
    case 'heart_rate':
      final list = sorted(ref.watch(heartRateProvider(memberId)).records.valueOrNull, (HeartRate r) => r.measurementDate);
      if (list == null) return null;
      return _Series(
        unit: 'bpm',
        onDelete: (ref, id) => ref.read(heartRateProvider(memberId).notifier).removeRecord(id),
        points: [
          for (final r in list)
            _Point(recordId: r.id, date: r.measurementDate, primary: r.bpm.toDouble(), display: '${r.bpm}'),
        ],
      );
    case 'temperature':
      final list = sorted(ref.watch(temperatureProvider(memberId)).records.valueOrNull, (Temperature r) => r.measurementDate);
      if (list == null) return null;
      return _Series(
        unit: list.last.unit.abbreviation,
        onDelete: (ref, id) => ref.read(temperatureProvider(memberId).notifier).removeRecord(id),
        points: [
          for (final r in list)
            _Point(recordId: r.id, date: r.measurementDate, primary: r.temperature, display: r.temperature.toStringAsFixed(1)),
        ],
      );
    case 'oxygen_saturation':
      final list = sorted(ref.watch(oxygenSaturationProvider(memberId)).records.valueOrNull, (OxygenSaturation r) => r.measurementDate);
      if (list == null) return null;
      return _Series(
        unit: '%',
        onDelete: (ref, id) => ref.read(oxygenSaturationProvider(memberId).notifier).removeRecord(id),
        points: [
          for (final r in list)
            _Point(recordId: r.id, date: r.measurementDate, primary: r.spO2, display: r.spO2.toStringAsFixed(0)),
        ],
      );
    case 'sleep':
      final list = sorted(ref.watch(sleepProvider(memberId)).records.valueOrNull, (SleepRecord r) => r.sleepDate);
      if (list == null) return null;
      return _Series(
        unit: 'hrs',
        onDelete: (ref, id) => ref.read(sleepProvider(memberId).notifier).removeRecord(id),
        points: [
          for (final r in list)
            _Point(recordId: r.id, date: r.sleepDate, primary: r.hoursSlept, display: r.hoursSlept.toStringAsFixed(1)),
        ],
      );
    case 'exercise':
      final list = sorted(ref.watch(exerciseProvider(memberId)).records.valueOrNull, (Exercise r) => r.exerciseDate);
      if (list == null) return null;
      return _Series(
        unit: 'min',
        onDelete: (ref, id) => ref.read(exerciseProvider(memberId).notifier).removeRecord(id),
        points: [
          for (final r in list)
            _Point(recordId: r.id, date: r.exerciseDate, primary: r.duration.toDouble(), display: '${r.duration}'),
        ],
      );
    case 'hydration':
      final list = sorted(ref.watch(hydrationProvider(memberId)).records.valueOrNull, (Hydration r) => r.date);
      if (list == null) return null;
      return _Series(
        unit: list.last.unit.abbreviation,
        onDelete: (ref, id) => ref.read(hydrationProvider(memberId).notifier).removeRecord(id),
        points: [
          for (final r in list)
            _Point(recordId: r.id, date: r.date, primary: r.waterIntake, display: r.waterIntake.toStringAsFixed(0)),
        ],
      );
  }
  return null;
}

const _ranges = ['7D', '30D', '90D', 'All'];

class VitalDetailScreen extends ConsumerStatefulWidget {
  final String moduleKey;
  final int memberId;

  const VitalDetailScreen({super.key, required this.moduleKey, required this.memberId});

  @override
  ConsumerState<VitalDetailScreen> createState() => _VitalDetailScreenState();
}

class _VitalDetailScreenState extends ConsumerState<VitalDetailScreen> {
  int _rangeIndex = 3;

  @override
  Widget build(BuildContext context) {
    final config = ModuleRegistry.getModuleByKey(widget.moduleKey);
    final series = _buildSeries(ref, widget.moduleKey, widget.memberId);
    final hue = VitalModuleColors.getIconTint(widget.moduleKey);

    if (config == null || series == null || series.points.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [_RoundButton(icon: Icons.arrow_back, onTap: () => context.pop())],
                ),
              ),
              Expanded(child: Center(child: Text('No readings yet', style: AppTypography.body))),
            ],
          ),
        ),
      );
    }

    final now = DateTime.now();
    final cutoff = switch (_rangeIndex) {
      0 => now.subtract(const Duration(days: 7)),
      1 => now.subtract(const Duration(days: 30)),
      2 => now.subtract(const Duration(days: 90)),
      _ => DateTime(1970),
    };
    var visible = series.points.where((p) => p.date.isAfter(cutoff)).toList();
    if (visible.isEmpty) visible = series.points;

    final latest = series.points.last;
    final avg = visible.map((p) => p.primary).reduce((a, b) => a + b) / visible.length;
    final minV = visible.map((p) => p.primary).reduce((a, b) => a < b ? a : b);
    final maxV = visible.map((p) => p.primary).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundButton(icon: Icons.arrow_back, onTap: () => context.pop()),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(config.icon, size: 19, color: hue),
                        const SizedBox(width: 8),
                        Text(config.domainName, style: AppTypography.sectionTitle.copyWith(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(latest.display, style: AppTypography.metricHero),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(series.unit, style: AppTypography.captionSmall),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Latest · ${DateFormat('EEE d MMM, h:mm a').format(latest.date)}',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        for (var i = 0; i < _ranges.length; i++) ...[
                          if (i > 0) const SizedBox(width: 7),
                          _RangePill(
                            label: _ranges[i],
                            selected: i == _rangeIndex,
                            onTap: () => setState(() => _rangeIndex = i),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppDimens.radiusCardL - 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text.rich(
                                TextSpan(
                                  style: AppTypography.captionSmall.copyWith(color: AppColors.textMuted),
                                  children: [
                                    const TextSpan(text: 'Average '),
                                    TextSpan(
                                      text: avg.toStringAsFixed(1),
                                      style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              if (series.secondaryLabel != null)
                                Row(
                                  children: [
                                    _LegendDot(color: hue, label: 'Systolic'),
                                    const SizedBox(width: 11),
                                    _LegendDot(color: AppColors.hueOxygen, label: series.secondaryLabel!),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 140,
                            child: _VitalLineChart(points: visible, hue: hue, hasSecondary: series.secondaryLabel != null),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _StatTile(label: 'Average', value: avg.toStringAsFixed(1))),
                        const SizedBox(width: 8),
                        Expanded(child: _StatTile(label: 'Min', value: minV.toStringAsFixed(1))),
                        const SizedBox(width: 8),
                        Expanded(child: _StatTile(label: 'Max', value: maxV.toStringAsFixed(1))),
                        const SizedBox(width: 8),
                        Expanded(child: _StatTile(label: 'Readings', value: '${visible.length}')),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        border: Border.all(color: AppColors.primarySoftBorder),
                        borderRadius: BorderRadius.circular(AppDimens.radiusTile),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.insights, size: 19, color: AppColors.primary),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              "Health Keeper describes what you recorded — it doesn't diagnose.",
                              style: AppTypography.bodySecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Readings', style: AppTypography.sectionTitle.copyWith(fontSize: 13)),
                        Text('Tap a row to delete', style: AppTypography.captionSmall),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (final p in visible.reversed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: _ReadingRow(
                          point: p,
                          unit: series.unit,
                          onTap: () => _confirmDelete(context, series, p.recordId),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, _Series series, int recordId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete reading'),
        content: const Text('Are you sure you want to delete this reading?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              series.onDelete(ref, recordId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _VitalLineChart extends StatelessWidget {
  final List<_Point> points;
  final Color hue;
  final bool hasSecondary;

  const _VitalLineChart({required this.points, required this.hue, required this.hasSecondary});

  @override
  Widget build(BuildContext context) {
    final primarySpots = [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].primary)];
    final allValues = [
      ...points.map((p) => p.primary),
      if (hasSecondary) ...points.where((p) => p.secondary != null).map((p) => p.secondary!),
    ];
    final minY = allValues.reduce((a, b) => a < b ? a : b);
    final maxY = allValues.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY).abs() < 0.001 ? 1.0 : (maxY - minY) * 0.2;

    return LineChart(
      LineChartData(
        minY: minY - pad,
        maxY: maxY + pad,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY + pad * 2) / 3,
          getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.dividerFaint, strokeWidth: 1),
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: primarySpots,
            isCurved: true,
            color: hue,
            barWidth: 2.4,
            dotData: FlDotData(show: points.length <= 12),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [hue.withValues(alpha: .22), hue.withValues(alpha: 0)],
              ),
            ),
          ),
          if (hasSecondary)
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  if (points[i].secondary != null) FlSpot(i.toDouble(), points[i].secondary!),
              ],
              isCurved: true,
              color: AppColors.hueOxygen,
              barWidth: 2,
              dotData: FlDotData(show: points.length <= 12),
              belowBarData: BarAreaData(show: false),
            ),
        ],
      ),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(label.toUpperCase(), style: AppTypography.eyebrow.copyWith(fontSize: 9)),
          const SizedBox(height: 5),
          Text(value, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

class _ReadingRow extends StatelessWidget {
  final _Point point;
  final String unit;
  final VoidCallback onTap;

  const _ReadingRow({required this.point, required this.unit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusTile),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusTile),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppDimens.radiusTile),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(point.display, style: AppTypography.cardTitle.copyWith(fontSize: 16)),
              ),
              Expanded(
                child: Text(
                  DateFormat('EEE d MMM, h:mm a').format(point.date),
                  style: AppTypography.caption,
                ),
              ),
              const Icon(Icons.delete_outline, size: 17, color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: AppTypography.captionSmall),
      ],
    );
  }
}

class _RangePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangePill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          ),
          child: Text(
            label,
            style: AppTypography.chip.copyWith(color: selected ? AppColors.onPrimary : AppColors.textMuted5),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 36, height: 36, child: Icon(icon, size: 19, color: AppColors.textMuted5)),
      ),
    );
  }
}
