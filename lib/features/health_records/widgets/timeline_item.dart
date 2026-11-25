import 'package:flutter/material.dart';

import '../../../app/theme/app_dimens.dart';

/// One labelled value on the record detail screen, with a timeline marker.
class TimelineItem extends StatelessWidget {
  final String label;
  final String value;

  const TimelineItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: theme.colorScheme.primary, shape: BoxShape.circle),
              ),
              Container(
                  width: 2,
                  height: 30,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            ],
          ),
          const SizedBox(width: AppDimens.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
