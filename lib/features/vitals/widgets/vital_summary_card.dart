import 'package:flutter/material.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/vital_module_colors.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/vital_series.dart';
import '../config/vital_chart_config.dart';
import '../vital_format.dart';
import 'health_zone_badge.dart';
import 'sparkline.dart';

/// A vital on the dashboard: latest reading, its zone, a 30-day mini chart and
/// how the 30-day average compares with the 30 days before.
class VitalSummaryCard extends StatelessWidget {
  final VitalSummary summary;
  final VoidCallback onTap;

  const VitalSummaryCard(
      {super.key, required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final module = ModuleRegistry.getModuleByKey(summary.module);
    final config = VitalChartConfig.getConfig(summary.module);
    final colors = VitalModuleColors.getColors(summary.module);
    final primary = summary.metrics.first;
    final decimals = config?.decimalPlaces ?? 1;
    final zones = config?.healthZones;
    final latest = summary.latestValues[primary.key];

    return Card(
      elevation: AppDimens.elevationS,
      margin: const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingL, vertical: AppDimens.spacingXS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingM),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.backgroundColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusS),
                ),
                child: Icon(module?.icon ?? Icons.monitor_heart_outlined,
                    color: colors.iconTint, size: 22),
              ),
              const SizedBox(width: AppDimens.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(module?.domainName ?? summary.module,
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    if (!summary.hasReadings)
                      Text('No readings yet — tap to add',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant))
                    else ...[
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: VitalFormat.values(
                                summary.metrics, summary.latestValues,
                                decimals: decimals),
                            style: theme.textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: ' ${VitalFormat.unit(summary.metrics)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(VitalFormat.when(summary.latestDate!),
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                          if (zones != null && latest != null)
                            HealthZoneBadge(
                                zones: zones, value: latest, compact: true),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (summary.hasReadings)
                _trend(context, primary, colors.iconTint, decimals),
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trend(
      BuildContext context, VitalMetric primary, Color color, int decimals) {
    final theme = Theme.of(context);
    final values = [for (final p in summary.sparkline) p.values[primary.key]]
        .whereType<double>()
        .toList();
    final change = summary.stats[primary.key]?.changeVsPrevious;
    return Padding(
      padding: const EdgeInsets.only(left: AppDimens.spacingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (values.isNotEmpty)
            Sparkline(values: values, color: color)
          else
            Text('No readings\nin 30 days',
                textAlign: TextAlign.end,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          if (change != null)
            Text(
              '${VitalFormat.change(change, decimals: decimals)} vs prev. 30d',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant, fontSize: 10),
            ),
        ],
      ),
    );
  }
}
