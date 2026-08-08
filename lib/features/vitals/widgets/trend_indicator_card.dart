import 'package:flutter/material.dart';

import '../../../app/theme/app_dimens.dart';

class TrendIndicatorCard extends StatelessWidget {
  final double lastValue;
  final double previousValue;
  final String unit;
  final String label;

  const TrendIndicatorCard({
    super.key,
    required this.lastValue,
    required this.previousValue,
    required this.unit,
    this.label = 'Latest',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diff = lastValue - previousValue;
    final isUp = diff > 0;
    final isFlat = diff.abs() < 0.01;

    final (trendIcon, trendColor) = isFlat
        ? (Icons.trending_flat, theme.colorScheme.onSurfaceVariant)
        : isUp
            ? (Icons.trending_up, Colors.orange)
            : (Icons.trending_down, Colors.green);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingL),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      lastValue.toStringAsFixed(
                        lastValue == lastValue.roundToDouble() ? 0 : 1,
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: trendColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(trendIcon, size: 18, color: trendColor),
                  const SizedBox(width: 4),
                  Text(
                    isFlat ? '0' : '${isUp ? "+" : ""}${diff.toStringAsFixed(1)}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: trendColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
