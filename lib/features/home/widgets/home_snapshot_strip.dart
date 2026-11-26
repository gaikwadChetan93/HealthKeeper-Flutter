import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/models/blood_pressure.dart';
import '../../../core/models/heart_rate.dart';
import '../../../core/models/weight.dart';
import '../../../core/state/module_providers.dart';
import '../../../core/widgets/hk_card.dart';

/// The 3-metric strip under the person's name on Home: blood pressure,
/// weight and resting heart rate, each showing the latest reading and a
/// simple trend versus the previous one. Real data, not sample copy — reads
/// straight off the same family-parameterised vital providers the Vitals
/// tab uses.
class HomeSnapshotStrip extends ConsumerWidget {
  final int memberId;

  const HomeSnapshotStrip({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bp = ref.watch(bloodPressureProvider(memberId)).records.valueOrNull;
    final weight = ref.watch(weightProvider(memberId)).records.valueOrNull;
    final hr = ref.watch(heartRateProvider(memberId)).records.valueOrNull;

    const moduleKeys = ['blood_pressure', 'weight', 'heart_rate'];

    final metrics = [
      _metricFrom<BloodPressure>(
        label: 'Blood pressure',
        hue: AppColors.hueBloodPressure,
        records: bp,
        dateOf: (r) => r.measurementDate,
        valueOf: (r) => '${r.systolic}/${r.diastolic}',
        deltaOf: (a, b) => (a.systolic - b.systolic).toDouble(),
        unit: '',
      ),
      _metricFrom<Weight>(
        label: 'Weight',
        hue: AppColors.hueWeight,
        records: weight,
        dateOf: (r) => r.measurementDate,
        valueOf: (r) => r.weight.toStringAsFixed(1),
        deltaOf: (a, b) => a.weight - b.weight,
        unit: 'kg',
      ),
      _metricFrom<HeartRate>(
        label: 'Resting HR',
        hue: AppColors.hueHeartRate,
        records: hr,
        dateOf: (r) => r.measurementDate,
        valueOf: (r) => '${r.bpm}',
        deltaOf: (a, b) => (a.bpm - b.bpm).toDouble(),
        unit: 'bpm',
      ),
    ];

    if (metrics.every((m) => m == null)) return const SizedBox.shrink();

    return HkCard(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          for (var i = 0; i < metrics.length; i++)
            Expanded(
              child: InkWell(
                onTap: metrics[i] == null
                    ? null
                    : () => context.push(Routes.vitalChart(moduleKeys[i], memberId)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: i == 0
                        ? null
                        : const Border(left: BorderSide(color: AppColors.dividerFaint)),
                  ),
                  child: metrics[i] ?? const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget? _metricFrom<T>({
    required String label,
    required Color hue,
    required List<T>? records,
    required DateTime Function(T) dateOf,
    required String Function(T) valueOf,
    required double Function(T latest, T previous) deltaOf,
    required String unit,
  }) {
    if (records == null || records.isEmpty) return null;
    final sorted = [...records]..sort((a, b) => dateOf(b).compareTo(dateOf(a)));
    final latest = sorted.first;

    String trendText = 'First reading';
    IconData trendIcon = Icons.remove;
    Color trendColor = AppColors.textMuted;
    if (sorted.length > 1) {
      final delta = deltaOf(latest, sorted[1]);
      if (delta.abs() < 0.05) {
        trendText = 'Stable';
        trendIcon = Icons.trending_flat;
        trendColor = AppColors.success;
      } else if (delta < 0) {
        trendText = '${delta.toStringAsFixed(1)} $unit'.trim();
        trendIcon = Icons.trending_down;
        trendColor = AppColors.success;
      } else {
        trendText = '+${delta.toStringAsFixed(1)} $unit'.trim();
        trendIcon = Icons.trending_up;
        trendColor = AppColors.textMuted;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: hue, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                style: AppTypography.captionSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(valueOf(latest), style: AppTypography.metricMedium),
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(trendIcon, size: 13, color: trendColor),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                trendText,
                style: AppTypography.captionSmall.copyWith(color: trendColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
