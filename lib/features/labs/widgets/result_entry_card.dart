import 'package:flutter/material.dart';

import '../../../core/models/lab.dart';

/// One test being typed in: value, unit, and the range printed on the report.
class ResultEntry {
  final LabTestDef test;
  final value = TextEditingController();
  final low = TextEditingController();
  final high = TextEditingController();
  String unit;
  Map<String, String> errors = {};

  ResultEntry(this.test) : unit = test.unit;

  static double? parse(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.'));

  void dispose() {
    value.dispose();
    low.dispose();
    high.dispose();
  }
}

class ResultEntryCard extends StatelessWidget {
  final ResultEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const ResultEntryCard(
      {super.key,
      required this.entry,
      required this.onRemove,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = entry.test;
    InputDecoration dec(String label, String key) => InputDecoration(
        labelText: label, errorText: entry.errors[key], isDense: true);
    const number =
        TextInputType.numberWithOptions(decimal: true, signed: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Text(t.category,
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ]),
              ),
              IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.close),
                  onPressed: onRemove),
            ]),
            if (entry.errors['test_id'] != null)
              Text(entry.errors['test_id']!,
                  style:
                      TextStyle(color: theme.colorScheme.error, fontSize: 12)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: entry.value,
                    keyboardType: number,
                    decoration: dec('Result *', 'value'),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: entry.unit,
                    isExpanded: true,
                    decoration: dec('Unit', 'unit'),
                    items: [
                      for (final u in t.units)
                        DropdownMenuItem(
                            value: u, child: Text(u.isEmpty ? '(none)' : u)),
                    ],
                    onChanged: (u) {
                      entry.unit = u ?? t.unit;
                      onChanged();
                    },
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            Text('Range on your report (optional)',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: TextField(
                      controller: entry.low,
                      keyboardType: number,
                      decoration: dec('From', 'ref_low')),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Text('–')),
                Expanded(
                  child: TextField(
                      controller: entry.high,
                      keyboardType: number,
                      decoration: dec('To', 'ref_high')),
                ),
              ]),
            ),
            if (t.guideline != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: Text(
                  'Without a range we compare with published guideline cut-offs (${t.guideline!.source}).',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
