import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/route_constants.dart';
import '../../../core/models/lab.dart';
import '../../../core/state/lab_providers.dart';
import '../../../core/widgets/animated_fab.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../lab_format.dart';
import '../widgets/add_lab_choice.dart';
import '../widgets/lab_result_tile.dart';
import '../widgets/pending_uploads.dart';

/// A member's lab results: latest of each test grouped by panel, and the reports.
class LabResultsScreen extends ConsumerStatefulWidget {
  final String memberId;

  const LabResultsScreen({super.key, required this.memberId});

  @override
  ConsumerState<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends ConsumerState<LabResultsScreen> {
  int _tab = 0;

  void _add() => showAddLabChoice(context, ref, widget.memberId);

  Widget _empty() => EmptyStateWidget(
        icon: Icons.biotech_outlined,
        title: 'No Lab Results Yet',
        description:
            'Add the results from a lab report to see them here and follow how they change.',
        ctaLabel: 'Add Lab Results',
        onCta: _add,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(title: 'Lab Results', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                    value: 0,
                    label: Text('By test'),
                    icon: Icon(Icons.biotech_outlined, size: 18)),
                ButtonSegment(
                    value: 1,
                    label: Text('Reports'),
                    icon: Icon(Icons.description_outlined, size: 18)),
              ],
              selected: {_tab},
              showSelectedIcon: false,
              onSelectionChanged: (v) => setState(() => _tab = v.first),
            ),
          ),
          PendingUploads(memberId: widget.memberId),
          Expanded(child: _tab == 0 ? _byTest() : _reports()),
        ],
      ),
      floatingActionButton: AnimatedFab(onPressed: _add),
    );
  }

  Widget _byTest() {
    final summary = ref.watch(labSummaryProvider(widget.memberId));
    return summary.when(
      loading: () => const ShimmerLoading(),
      error: (e, _) => LoadErrorView(
          error: e,
          onRetry: () => ref.invalidate(labSummaryProvider(widget.memberId))),
      data: (tests) {
        if (tests.isEmpty) return _empty();
        final theme = Theme.of(context);
        final flagged = tests.where((t) => t.latest.isFlagged).length;
        final rows = <Widget>[
          if (flagged > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                  '$flagged of ${tests.length} latest results are outside their range',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
        ];
        String? category;
        for (final t in tests) {
          if (t.category != category) {
            category = t.category;
            rows.add(Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(category,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.primary)),
            ));
          }
          rows.add(LabResultTile(
            result: t.latest,
            showDate: true,
            trailingNote: _change(t),
            onTap: () =>
                context.push(Routes.labTest(widget.memberId, t.testId)),
          ));
        }
        rows.add(const SizedBox(height: 96));
        return RefreshIndicator(
          onRefresh: () =>
              ref.refresh(labSummaryProvider(widget.memberId).future),
          child: ListView(padding: EdgeInsets.zero, children: rows),
        );
      },
    );
  }

  String? _change(LabTestSummary t) {
    if (t.previousValue == null) {
      return t.count == 1 ? null : '${t.count} results';
    }
    final diff = t.latest.value - t.previousValue!;
    final arrow = diff.abs() < 1e-9 ? '→' : (diff > 0 ? '↑' : '↓');
    return '$arrow ${LabFormat.number(diff.abs(), t.latest.decimals + 1)} since last · ${t.count} results';
  }

  Widget _reports() {
    final reports = ref.watch(labReportsProvider(widget.memberId));
    return reports.when(
      loading: () => const ShimmerLoading(),
      error: (e, _) => LoadErrorView(
          error: e,
          onRetry: () => ref.invalidate(labReportsProvider(widget.memberId))),
      data: (list) => list.isEmpty
          ? _empty()
          : RefreshIndicator(
              onRefresh: () =>
                  ref.refresh(labReportsProvider(widget.memberId).future),
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: list.length,
                itemBuilder: (_, i) => _ReportCard(report: list[i]),
              ),
            ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final LabReport report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.description_outlined),
        title: Text(DateFormat('d MMM yyyy').format(report.reportDate),
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text([
          if (report.labName != null) report.labName!,
          '${report.resultCount} result${report.resultCount == 1 ? '' : 's'}',
        ].join(' · ')),
        trailing: report.flaggedCount == 0
            ? null
            : Text('${report.flaggedCount} outside range',
                style: TextStyle(
                    color: LabFormat.color('high', theme.colorScheme),
                    fontSize: 12)),
        onTap: () => context.push(Routes.labReport(report.id)),
      ),
    );
  }
}
