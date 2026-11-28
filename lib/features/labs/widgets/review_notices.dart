import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../core/models/lab_upload.dart';
import 'suggest_test_dialog.dart';
import '../lab_format.dart';

/// Warnings before saving: someone else's report, or one already saved.
class ReviewNotices extends StatelessWidget {
  final UploadExtracted extracted;
  final String? memberName;
  final String fileName;

  const ReviewNotices(
      {super.key,
      required this.extracted,
      required this.memberName,
      required this.fileName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final review = extracted.results.where((r) => r.needsReview).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(fileName,
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      const SizedBox(height: 4),
      Text(
        'We read ${LabFormat.results(extracted.results.length)}. Check each value against the report'
        '${review > 0 ? ' — $review are marked to double-check' : ''}. Untick anything that’s wrong.',
        style: theme.textTheme.bodyMedium,
      ),
      if (extracted.fromScan)
        const _Banner(
          icon: Icons.document_scanner_outlined,
          text:
              'This report was a scan, so the values were read from an image. '
              'Check every value and decimal point against the paper report before saving.',
        ),
      if (extracted.nameMismatch)
        _Banner(
          icon: Icons.person_search_outlined,
          text:
              'The name on this report doesn’t look like ${memberName ?? 'this family member'}. '
              'Make sure you’re saving it for the right person.',
        ),
      if (extracted.duplicateOfReportId != null)
        _Banner(
          icon: Icons.content_copy_outlined,
          text: 'You’ve saved this report before.',
          action: TextButton(
            onPressed: () =>
                context.push(Routes.labReport(extracted.duplicateOfReportId!)),
            child: const Text('Open it'),
          ),
        ),
      const SizedBox(height: 16),
    ]);
  }
}

class _Banner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? action;

  const _Banner({required this.icon, required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(top: 12),
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Icon(icon, color: scheme.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: TextStyle(color: scheme.onTertiaryContainer))),
          if (action != null) action!,
        ]),
      ),
    );
  }
}

/// Lines that looked like results but whose test we don't know, so nothing is guessed.
/// Each can be added as the person's own test (under its printed name) or suggested to us.
class UnrecognisedList extends ConsumerWidget {
  final List<String> lines;

  /// What was read from each line; when given, each line can be added.
  final List<UnrecognisedRow> rows;
  final ValueChanged<UnrecognisedRow>? onAdd;

  const UnrecognisedList(
      {super.key, required this.lines, this.rows = const [], this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = rows.isNotEmpty
        ? [for (final r in rows) (r.text, r)]
        : [for (final l in lines) (l, null as UnrecognisedRow?)];
    if (items.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: EdgeInsets.zero,
      title: Text(
          '${items.length} line${items.length == 1 ? '' : 's'} we didn’t recognise'),
      subtitle: Text(onAdd != null && rows.isNotEmpty
          ? 'Not saved unless you add them. Add one to save it under the name printed, or suggest the test to us.'
          : 'Not saved. Add them as tests, or suggest the test to us.'),
      children: [
        for (final (text, row) in items)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(text),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              TextButton(
                onPressed: () => showSuggestTestDialog(context, ref,
                    initialName:
                        row?.printedName ?? text.split(RegExp(r'\s{2,}')).first,
                    initialUnit: row?.unit ?? ''),
                child: const Text('Suggest'),
              ),
              if (row != null && onAdd != null)
                FilledButton.tonal(
                    onPressed: () => onAdd!(row), child: const Text('Add')),
            ]),
          ),
      ],
    );
  }
}
