import 'package:flutter/material.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/models/chart_models.dart';

class TimeRangeSelector extends StatelessWidget {
  final TimeRange selected;
  final ValueChanged<TimeRange> onChanged;

  const TimeRangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _ranges = [
    TimeRange.sevenDays,
    TimeRange.thirtyDays,
    TimeRange.ninetyDays,
    TimeRange.all,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      runSpacing: 4,
      children: _ranges.map((range) {
        final isSelected = range == selected;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(range.displayName),
            selected: isSelected,
            onSelected: (_) => onChanged(range),
            labelStyle: theme.textTheme.labelSmall?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
            selectedColor: theme.colorScheme.primary,
            visualDensity: VisualDensity.compact,
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingS),
          ),
        );
      }).toList(),
    );
  }
}
