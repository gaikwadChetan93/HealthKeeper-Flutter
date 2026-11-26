import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/route_constants.dart';
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
import '../../../core/state/active_person_provider.dart';
import '../../../core/state/module_providers.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../health_records/config/module_screen_config.dart';
import '../../home/widgets/add_sheet.dart';

/// A single vital's overview card: latest reading, a sparkline of recent
/// history, and the trend versus the previous reading.
class _VitalCard {
  final String moduleKey;
  final IconData icon;
  final Color hue;
  final String title;
  final String value;
  final String unit;
  final DateTime latestDate;
  final List<double> sparkValues;
  final double trendDelta;

  const _VitalCard({
    required this.moduleKey,
    required this.icon,
    required this.hue,
    required this.title,
    required this.value,
    required this.unit,
    required this.latestDate,
    required this.sparkValues,
    required this.trendDelta,
  });
}

_VitalCard? _buildVitalCard(WidgetRef ref, String moduleKey, IconData icon, String title, int memberId) {
  final hue = VitalModuleColors.getIconTint(moduleKey);

  List<T>? sorted<T>(List<T>? records, DateTime Function(T) dateOf) {
    if (records == null || records.isEmpty) return null;
    final list = [...records]..sort((a, b) => dateOf(a).compareTo(dateOf(b)));
    return list;
  }

  _VitalCard fromNumeric<T>({
    required List<T> list,
    required DateTime Function(T) dateOf,
    required double Function(T) numOf,
    required String Function(T) valueOf,
    required String unit,
  }) {
    final spark = list.map(numOf).toList();
    final latest = list.last;
    final delta = list.length > 1 ? numOf(latest) - numOf(list[list.length - 2]) : 0.0;
    return _VitalCard(
      moduleKey: moduleKey,
      icon: icon,
      hue: hue,
      title: title,
      value: valueOf(latest),
      unit: unit,
      latestDate: dateOf(latest),
      sparkValues: spark,
      trendDelta: delta,
    );
  }

  switch (moduleKey) {
    case 'blood_pressure':
      final list = sorted(ref.watch(bloodPressureProvider(memberId)).records.valueOrNull, (BloodPressure r) => r.measurementDate);
      if (list == null) return null;
      return fromNumeric<BloodPressure>(
        list: list,
        dateOf: (r) => r.measurementDate,
        numOf: (r) => r.systolic.toDouble(),
        valueOf: (r) => '${r.systolic}/${r.diastolic}',
        unit: 'mmHg',
      );
    case 'weight':
      final list = sorted(ref.watch(weightProvider(memberId)).records.valueOrNull, (Weight r) => r.measurementDate);
      if (list == null) return null;
      return fromNumeric<Weight>(
        list: list,
        dateOf: (r) => r.measurementDate,
        numOf: (r) => r.weight,
        valueOf: (r) => r.weight.toStringAsFixed(1),
        unit: list.last.unit.abbreviation,
      );
    case 'height':
      final list = sorted(ref.watch(heightProvider(memberId)).records.valueOrNull, (Height r) => r.measurementDate);
      if (list == null) return null;
      return fromNumeric<Height>(
        list: list,
        dateOf: (r) => r.measurementDate,
        numOf: (r) => r.height,
        valueOf: (r) => r.height.toStringAsFixed(0),
        unit: list.last.unit.abbreviation,
      );
    case 'blood_glucose':
      final list = sorted(ref.watch(bloodGlucoseProvider(memberId)).records.valueOrNull, (BloodGlucose r) => r.measurementDate);
      if (list == null) return null;
      return fromNumeric<BloodGlucose>(
        list: list,
        dateOf: (r) => r.measurementDate,
        numOf: (r) => r.glucose,
        valueOf: (r) => r.glucose.toStringAsFixed(0),
        unit: list.last.unit.abbreviation,
      );
    case 'heart_rate':
      final list = sorted(ref.watch(heartRateProvider(memberId)).records.valueOrNull, (HeartRate r) => r.measurementDate);
      if (list == null) return null;
      return fromNumeric<HeartRate>(
        list: list,
        dateOf: (r) => r.measurementDate,
        numOf: (r) => r.bpm.toDouble(),
        valueOf: (r) => '${r.bpm}',
        unit: 'bpm',
      );
    case 'temperature':
      final list = sorted(ref.watch(temperatureProvider(memberId)).records.valueOrNull, (Temperature r) => r.measurementDate);
      if (list == null) return null;
      return fromNumeric<Temperature>(
        list: list,
        dateOf: (r) => r.measurementDate,
        numOf: (r) => r.temperature,
        valueOf: (r) => r.temperature.toStringAsFixed(1),
        unit: list.last.unit.abbreviation,
      );
    case 'oxygen_saturation':
      final list = sorted(ref.watch(oxygenSaturationProvider(memberId)).records.valueOrNull, (OxygenSaturation r) => r.measurementDate);
      if (list == null) return null;
      return fromNumeric<OxygenSaturation>(
        list: list,
        dateOf: (r) => r.measurementDate,
        numOf: (r) => r.spO2,
        valueOf: (r) => r.spO2.toStringAsFixed(0),
        unit: '%',
      );
    case 'sleep':
      final list = sorted(ref.watch(sleepProvider(memberId)).records.valueOrNull, (SleepRecord r) => r.sleepDate);
      if (list == null) return null;
      return fromNumeric<SleepRecord>(
        list: list,
        dateOf: (r) => r.sleepDate,
        numOf: (r) => r.hoursSlept,
        valueOf: (r) => r.hoursSlept.toStringAsFixed(1),
        unit: 'hrs',
      );
    case 'exercise':
      final list = sorted(ref.watch(exerciseProvider(memberId)).records.valueOrNull, (Exercise r) => r.exerciseDate);
      if (list == null) return null;
      return fromNumeric<Exercise>(
        list: list,
        dateOf: (r) => r.exerciseDate,
        numOf: (r) => r.duration.toDouble(),
        valueOf: (r) => '${r.duration}',
        unit: 'min',
      );
    case 'hydration':
      final list = sorted(ref.watch(hydrationProvider(memberId)).records.valueOrNull, (Hydration r) => r.date);
      if (list == null) return null;
      return fromNumeric<Hydration>(
        list: list,
        dateOf: (r) => r.date,
        numOf: (r) => r.waterIntake,
        valueOf: (r) => r.waterIntake.toStringAsFixed(0),
        unit: list.last.unit.abbreviation,
      );
  }
  return null;
}

String _relativeWhen(DateTime d) {
  final now = DateTime.now();
  final diff = DateTime(now.year, now.month, now.day).difference(DateTime(d.year, d.month, d.day)).inDays;
  final time = DateFormat('h:mm a').format(d);
  if (diff == 0) return 'Today, $time';
  if (diff == 1) return 'Yesterday, $time';
  return DateFormat('d MMM, h:mm a').format(d);
}

class VitalsScreen extends ConsumerWidget {
  const VitalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person = ref.watch(activePersonProvider);
    final memberId = ref.watch(activePersonIdOrFallbackProvider);

    final tracked = <_VitalCard>[];
    final untracked = <({String key, IconData icon, String title})>[];
    var isLoading = false;

    for (final module in ModuleRegistry.vitalOverviewModules) {
      if (ref.watch(ModuleScreenConfig.getConfig(module.domainKey).getProvider(memberId)).records.isLoading) {
        isLoading = true;
      }
      final card = _buildVitalCard(ref, module.domainKey, module.icon, module.domainName, memberId);
      if (card != null) {
        tracked.add(card);
      } else {
        untracked.add((key: module.domainKey, icon: module.icon, title: module.domainName));
      }
    }
    tracked.sort((a, b) => b.latestDate.compareTo(a.latestDate));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (person?.name ?? '').toUpperCase(),
                      style: AppTypography.eyebrow.copyWith(letterSpacing: .12),
                    ),
                    const SizedBox(height: 7),
                    Text('Vitals', style: AppTypography.heroTitle.copyWith(fontSize: 26)),
                    const SizedBox(height: 6),
                    Text(
                      tracked.isEmpty
                          ? 'No measures tracked yet'
                          : '${tracked.length} measure${tracked.length == 1 ? '' : 's'} tracked',
                      style: AppTypography.bodySecondary,
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(0, 18, 0, 0),
                sliver: SliverToBoxAdapter(child: ShimmerLoading()),
              )
            else if (tracked.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 22, 14, 0),
                  child: _FreshVitalsCard(onAdd: () => showAddSheet(context, ref)),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
                sliver: SliverList.builder(
                  itemCount: tracked.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _VitalOverviewCard(
                      data: tracked[i],
                      onTap: () => context.push(Routes.vitalChart(tracked[i].moduleKey, memberId)),
                    ),
                  ),
                ),
              ),
            if (!isLoading && untracked.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                  child: Text('Not tracked yet', style: AppTypography.sectionTitle.copyWith(fontSize: 13)),
                ),
              ),
            if (!isLoading && untracked.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final u in untracked)
                        _UntrackedChip(
                          icon: u.icon,
                          label: u.title,
                          onTap: () => context.push(Routes.vitalEntry(u.key, memberId)),
                        ),
                    ],
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }
}

class _FreshVitalsCard extends StatelessWidget {
  final VoidCallback onAdd;
  const _FreshVitalsCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimens.radiusCardL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.tint(AppColors.hueBloodPressure),
                  borderRadius: BorderRadius.circular(AppDimens.radiusChip),
                ),
                child: const Icon(Icons.monitor_heart_outlined, size: 23, color: AppColors.hueBloodPressure),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No readings yet', style: AppTypography.cardTitle.copyWith(fontSize: 15)),
                    const SizedBox(height: 3),
                    Text('One measurement is enough to begin', style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
              ),
              alignment: Alignment.center,
              child: Text('Add your first reading', style: AppTypography.button.copyWith(color: AppColors.onPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalOverviewCard extends StatelessWidget {
  final _VitalCard data;
  final VoidCallback onTap;

  const _VitalOverviewCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final trendUp = data.trendDelta > 0.05;
    final trendDown = data.trendDelta < -0.05;
    final trendIcon = trendUp ? Icons.trending_up : (trendDown ? Icons.trending_down : Icons.trending_flat);
    final trendText = trendUp
        ? '+${data.trendDelta.toStringAsFixed(1)}'
        : (trendDown ? data.trendDelta.toStringAsFixed(1) : 'Stable');

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusCardL),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusCardL),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppDimens.radiusCardL),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.tint(data.hue),
                      borderRadius: BorderRadius.circular(AppDimens.radiusChip),
                    ),
                    child: Icon(data.icon, size: 18, color: data.hue),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.title, style: AppTypography.cardTitle),
                        const SizedBox(height: 2),
                        Text(_relativeWhen(data.latestDate), style: AppTypography.captionSmall),
                      ],
                    ),
                  ),
                  if (data.sparkValues.length > 1)
                    SizedBox(width: 60, height: 20, child: _Sparkline(values: data.sparkValues, color: data.hue)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(data.value, style: AppTypography.metricLarge.copyWith(fontSize: 27)),
                      const SizedBox(width: 5),
                      Text(data.unit, style: AppTypography.captionSmall),
                    ],
                  ),
                  if (data.sparkValues.length > 1)
                    Row(
                      children: [
                        Icon(trendIcon, size: 15, color: trendUp ? AppColors.textMuted : AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          trendText,
                          style: AppTypography.captionSmall.copyWith(
                            color: trendUp ? AppColors.textMuted : AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

class _Sparkline extends StatelessWidget {
  final List<double> values;
  final Color color;

  const _Sparkline({required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    final spots = [for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])];
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY).abs() < 0.001 ? 1.0 : (maxY - minY) * 0.25;

    return LineChart(
      LineChartData(
        minY: minY - pad,
        maxY: maxY + pad,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color.withValues(alpha: .6),
            barWidth: 1.6,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
      duration: Duration.zero,
    );
  }
}

class _UntrackedChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UntrackedChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderDashed),
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.textMuted5),
              const SizedBox(width: 7),
              Text(label, style: AppTypography.chip.copyWith(color: AppColors.textMuted5)),
            ],
          ),
        ),
      ),
    );
  }
}
