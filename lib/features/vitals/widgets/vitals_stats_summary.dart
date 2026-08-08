import 'package:flutter/material.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/models/chart_models.dart';

class VitalsStatsSummary extends StatelessWidget {
  final VitalsStats stats;

  const VitalsStatsSummary({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'Min', value: stats.min, unit: stats.unit),
        _StatCard(label: 'Max', value: stats.max, unit: stats.unit),
        _StatCard(label: 'Avg', value: stats.average, unit: stats.unit),
        _StatCard(label: 'Last', value: stats.lastValue, unit: stats.unit),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double value;
  final String unit;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingM),
          child: Column(
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
