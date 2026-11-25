import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../core/models/lab.dart';
import '../../../core/state/lab_providers.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../lab_format.dart';
import '../widgets/lab_flag_chip.dart';
import '../widgets/lab_result_tile.dart';
import '../widgets/lab_trend_chart.dart';

/// One test over time: latest result, chart, and every result.
class LabTestScreen extends ConsumerWidget {
  final String memberId;
  final String testId;

  const LabTestScreen(
      {super.key, required this.memberId, required this.testId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (memberId: memberId, testId: testId);
    final series = ref.watch(labSeriesProvider(key));
    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
              title: series.valueOrNull?.name ?? 'Lab Test',
              onBack: () => context.pop()),
          Expanded(
            child: series.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => LoadErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(labSeriesProvider(key))),
              data: (s) => s.points.isEmpty
                  ? const Center(child: Text('No results for this test yet'))
                  : _body(context, s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, LabSeries s) {
    final theme = Theme.of(context);
    final latest = s.points.last;
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final first = s.points.first;
    final change = latest.value - first.value;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Latest result', style: muted),
              const SizedBox(height: 4),
              Row(children: [
                Text(LabFormat.value(latest),
                    style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            LabFormat.color(latest.flag, theme.colorScheme))),
                const SizedBox(width: 12),
                LabFlagChip(result: latest),
              ]),
              const SizedBox(height: 4),
              Text(LabFormat.rangeText(latest), style: muted),
              if (latest.rangeSource == 'report' && latest.flagLabel != null)
                Text(latest.flagLabel!, style: muted),
              if (s.points.length > 1) ...[
                const Divider(height: 24),
                Text(
                  '${change >= 0 ? 'Up' : 'Down'} ${LabFormat.number(change.abs(), s.decimals + 1)} ${s.unit} '
                  'since the first of ${s.points.length} results',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 12),
        if (s.points.length > 1)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trend', style: theme.textTheme.titleSmall),
                    Text(
                      latest.rangeSource == 'report'
                          ? 'Shaded: range on your latest report'
                          : s.guideline != null
                              ? 'Shaded: guideline bands (${s.guideline!.source})'
                              : 'No range to shade — add one from your report',
                      style: muted,
                    ),
                    LabTrendChart(series: s),
                  ]),
            ),
          ),
        const SizedBox(height: 12),
        Text('All results', style: theme.textTheme.titleSmall),
        for (final p in s.points.reversed)
          LabResultTile(
              result: p,
              showDate: true,
              onTap: () => context.push(Routes.labReport(p.reportId))),
        const SizedBox(height: 16),
        Text('Not medical advice. Talk to your doctor about your results.',
            style: muted, textAlign: TextAlign.center),
      ],
    );
  }
}
