import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../core/models/lab_upload.dart';
import 'suggest_test_dialog.dart';

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
        'We read ${extracted.results.length} results. Check each value against the report'
        '${review > 0 ? ' — $review are marked to double-check' : ''}. Untick anything that’s wrong.',
        style: theme.textTheme.bodyMedium,
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
class UnrecognisedList extends ConsumerWidget {
  final List<String> lines;
  const UnrecognisedList({super.key, required this.lines});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (lines.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
          '${lines.length} line${lines.length == 1 ? '' : 's'} we didn’t recognise'),
      subtitle: const Text(
          'Not saved. Add them as tests, or suggest the test to us.'),
      children: [
        for (final l in lines)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(l),
            trailing: TextButton(
              onPressed: () => showSuggestTestDialog(context, ref,
                  initialName: l.split(RegExp(r'\s{2,}')).first),
              child: const Text('Suggest'),
            ),
          ),
      ],
    );
  }
}
