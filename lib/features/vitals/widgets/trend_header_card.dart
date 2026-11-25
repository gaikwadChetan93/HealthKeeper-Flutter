import 'package:flutter/material.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/models/chart_models.dart';
import '../../../core/models/vital_series.dart';
import '../config/vital_chart_config.dart';
import '../vital_format.dart';
import 'health_zone_badge.dart';

/// Top of the trend screen: the latest value with its zone, and the average
/// over the chosen range compared with the period before it.
class TrendHeaderCard extends StatelessWidget {
  final VitalSeries series;
  final VitalChartConfig? config;
  final TimeRange range;

  const TrendHeaderCard(
      {super.key,
      required this.series,
      required this.config,
      required this.range});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metrics = series.metrics;
    final decimals = config?.decimalPlaces ?? 1;
    final latest = {
      for (final m in metrics)
        if (series.stats[m.key]?.latest != null)
          m.key: series.stats[m.key]!.latest!,
    };
    final avg = {
      for (final m in metrics)
        if (series.stats[m.key]?.avg != null) m.key: series.stats[m.key]!.avg!,
    };
    final primary = series.stats[metrics.first.key];
    final change = primary?.changeVsPrevious;
    final sumMetric = metrics.first.isSum;
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sumMetric ? 'Latest day' : 'Latest reading', style: muted),
            const SizedBox(height: 4),
            Text.rich(TextSpan(children: [
              TextSpan(
                text: VitalFormat.values(metrics, latest, decimals: decimals),
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' ${VitalFormat.unit(metrics)}', style: muted),
            ])),
            if (series.points.isNotEmpty)
              Text(VitalFormat.when(series.points.last.date), style: muted),
            const SizedBox(height: AppDimens.spacingS),
            Wrap(spacing: 8, runSpacing: 6, children: [
              for (var i = 0; i < metrics.length; i++)
                if (config?.zonesFor(i) != null &&
                    latest[metrics[i].key] != null)
                  _labelled(
                      metrics.length > 1 ? metrics[i].label : null,
                      HealthZoneBadge(
                          zones: config!.zonesFor(i)!,
                          value: latest[metrics[i].key]!)),
            ]),
            const Divider(height: AppDimens.spacingXL),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sumMetric ? 'Average per day' : 'Average',
                          style: muted),
                      Text(
                          '${VitalFormat.values(metrics, avg, decimals: decimals)} ${VitalFormat.unit(metrics)}',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                if (change != null && range.days != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('vs previous ${range.days} days', style: muted),
                      Row(children: [
                        Icon(
                          change.abs() < 0.05
                              ? Icons.trending_flat
                              : (change > 0
                                  ? Icons.trending_up
                                  : Icons.trending_down),
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(VitalFormat.change(change, decimals: decimals),
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary)),
                      ]),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelled(String? label, Widget badge) {
    if (label == null) return badge;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$label ', style: const TextStyle(fontSize: 12)),
      badge,
    ]);
  }
}
