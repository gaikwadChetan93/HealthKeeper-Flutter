import 'package:flutter/material.dart';

import '../../../core/models/chart_models.dart';
import '../../../core/models/vital_series.dart';
import '../config/vital_chart_config.dart';

/// Explains the chart: which line is which, and what the shaded zones mean.
class ChartLegend extends StatelessWidget {
  final VitalSeries series;
  final VitalChartConfig? config;
  final List<Color> colors;

  const ChartLegend(
      {super.key,
      required this.series,
      required this.config,
      required this.colors});

  @override
  Widget build(BuildContext context) {
    final bars = config?.chartType == ChartType.bar;
    final lines = bars
        ? series.metrics.take(1).toList()
        : series.metrics.take(2).toList();
    final zones = !bars && lines.length == 1 ? config?.healthZones : null;
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Wrap(
        spacing: 14,
        runSpacing: 6,
        children: [
          if (lines.length > 1)
            for (var i = 0; i < lines.length; i++)
              _item(context, colors[i % colors.length], lines[i].label,
                  round: true),
          if (zones != null)
            for (final z in zones.zones)
              _item(context, z.color.withValues(alpha: 0.35), z.label),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, Color color, String label,
      {bool round = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: round ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: round ? null : BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
