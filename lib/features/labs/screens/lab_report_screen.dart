import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/route_constants.dart';
import '../../../core/models/lab.dart';
import '../../../core/state/lab_providers.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../lab_format.dart';
import '../widgets/edit_result_sheet.dart';
import '../widgets/lab_result_tile.dart';

/// One report: its results grouped by panel, each with where its range came from.
class LabReportScreen extends ConsumerWidget {
  final String reportId;

  const LabReportScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(labReportProvider(reportId));
    final loaded = report.valueOrNull;
    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: 'Lab Report',
            onBack: () => context.pop(),
            actions: [
              if (loaded != null)
                IconButton(
                  tooltip: 'Delete report',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(context, ref, loaded),
                ),
            ],
          ),
          Expanded(
            child: report.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => LoadErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(labReportProvider(reportId))),
              data: (r) => _body(context, r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, LabReport r) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final rows = <Widget>[
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(DateFormat('d MMMM yyyy').format(r.reportDate),
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          if (r.labName != null) Text(r.labName!, style: muted),
          const SizedBox(height: 4),
          Text(
              '${LabFormat.results(r.resultCount)} · ${r.flaggedCount} outside their range',
              style: muted),
        ]),
      ),
    ];
    String? category;
    for (final res in r.results) {
      if (res.category != category) {
        category = res.category;
        rows.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(category,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.primary)),
        ));
      }
      rows.add(LabResultTile(
        result: res,
        trailingNote: LabFormat.entered(res),
        onTap: () => context.push(Routes.labTest(res.memberId, res.testId)),
        onEdit: () => showEditResultSheet(context, res),
      ));
    }
    rows.add(Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Flags compare each result with the range printed on your report, or published guideline cut-offs where '
        'shown. Not medical advice — talk to your doctor about your results.',
        style: muted,
        textAlign: TextAlign.center,
      ),
    ));
    return ListView(padding: EdgeInsets.zero, children: rows);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, LabReport r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete this report?'),
        content: Text(r.resultCount == 1
            ? 'The result in it will be deleted.'
            : 'All ${r.resultCount} results in it will be deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(c).colorScheme.error),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(labActionsProvider).deleteReport(r);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) showMessage(context, '$e');
    }
  }
}
