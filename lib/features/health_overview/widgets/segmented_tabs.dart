import 'package:flutter/material.dart';

import '../../../app/theme/app_dimens.dart';

class SegmentedTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<SegmentedTabItem> tabs;

  const SegmentedTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      segments: tabs.asMap().entries.map((entry) {
        return ButtonSegment(
          value: entry.key,
          label: Text(entry.value.label),
          icon: Icon(entry.value.icon, size: 18),
        );
      }).toList(),
      selected: {selectedIndex},
      onSelectionChanged: (values) => onChanged(values.first),
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: AppDimens.spacingM),
        ),
      ),
    );
  }
}

class SegmentedTabItem {
  final String label;
  final IconData icon;

  const SegmentedTabItem({required this.label, required this.icon});
}
