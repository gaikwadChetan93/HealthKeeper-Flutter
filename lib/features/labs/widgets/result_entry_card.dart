import 'package:flutter/material.dart';

import '../../../core/models/lab.dart';
import '../../../core/models/lab_upload.dart';
import '../lab_format.dart';

/// One test being typed in: value, unit, and the range printed on the report.
class ResultEntry {
  final LabTestDef test;
  final value = TextEditingController();
  final low = TextEditingController();
  final high = TextEditingController();
  String unit;
  Map<String, String> errors = {};

  /// From an uploaded report: what was printed, doubts to check, and whether to save it.
  final String? printed;
  final List<String> issues;
  bool include = true;

  /// The reader wasn't sure (name, unit or range): shown first for checking.
  final bool needsReview;

  ResultEntry(this.test)
      : unit = test.unit,
        printed = null,
        issues = const [],
        needsReview = false;

  /// Pre-filled from what the server read off the report.
  ResultEntry.fromExtracted(this.test, ExtractedRow row)
      : unit = LabFormat.matchUnit(test, row.unit) ?? test.unit,
        printed =
            '“${row.printedName}” ${LabFormat.number(row.value, 4)} ${row.printedUnit}'
                '${row.refText == null ? '' : ' · ${row.refText!.replaceAll('\n', ' ')}'}',
        issues = [
          ...row.issues,
          if (LabFormat.matchUnit(test, row.unit) == null) 'Check the unit',
        ],
        needsReview =
            row.needsReview || LabFormat.matchUnit(test, row.unit) == null {
    value.text = LabFormat.number(row.value, 4);
    if (row.refLow != null) low.text = LabFormat.number(row.refLow!, 4);
    if (row.refHigh != null) high.text = LabFormat.number(row.refHigh!, 4);
  }

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

  /// For uploaded reports: a tick to leave a result out instead of removing it.
  final ValueChanged<bool>? onInclude;

  const ResultEntryCard(
      {super.key,
      required this.entry,
      required this.onRemove,
      required this.onChanged,
      this.onInclude});

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
              if (onInclude != null)
                Checkbox(
                    value: entry.include,
                    onChanged: (v) => onInclude!(v ?? false)),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Text(entry.printed ?? t.category,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ]),
              ),
              if (onInclude == null)
                IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.close),
                    onPressed: onRemove),
            ]),
            if (entry.include && entry.issues.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 8),
                child: Wrap(spacing: 6, runSpacing: 4, children: [
                  for (final i in entry.issues)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      avatar: const Icon(Icons.info_outline, size: 14),
                      label: Text(i, style: const TextStyle(fontSize: 11)),
                    ),
                ]),
              ),
            if (!entry.include)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text('Won’t be saved',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              )
            else ...[
              if (entry.errors['test_id'] != null)
                Text(entry.errors['test_id']!,
                    style: TextStyle(
                        color: theme.colorScheme.error, fontSize: 12)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  value: u,
                                  child: Text(u.isEmpty ? '(none)' : u)),
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
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                            controller: entry.low,
                            keyboardType: number,
                            decoration: dec('From', 'ref_low')),
                      ),
                      const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
          ],
        ),
      ),
    );
  }
}
