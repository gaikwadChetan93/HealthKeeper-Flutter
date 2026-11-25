import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/vital_module_colors.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/chart_models.dart';
import '../../../core/models/vital_series.dart';
import '../../../core/state/vitals_providers.dart';
import '../../../core/widgets/animated_fab.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../config/vital_chart_config.dart';
import '../widgets/chart_legend.dart';
import '../widgets/time_range_selector.dart';
import '../widgets/trend_chart.dart';
import '../widgets/trend_header_card.dart';
import '../widgets/vitals_stats_summary.dart';

/// One vital over time: latest value and zone, chart, and statistics.
class VitalTrendScreen extends ConsumerStatefulWidget {
  final String moduleKey;
  final String memberId;

  const VitalTrendScreen(
      {super.key, required this.moduleKey, required this.memberId});

  @override
  ConsumerState<VitalTrendScreen> createState() => _VitalTrendScreenState();
}

class _VitalTrendScreenState extends ConsumerState<VitalTrendScreen> {
  TimeRange _range = TimeRange.thirtyDays;

  VitalSeriesKey get _key =>
      (memberId: widget.memberId, module: widget.moduleKey, range: _range);

  @override
  Widget build(BuildContext context) {
    final module = ModuleRegistry.getModuleByKey(widget.moduleKey);
    final config = VitalChartConfig.getConfig(widget.moduleKey);
    final series = ref.watch(vitalSeriesProvider(_key));

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: config?.title ?? module?.domainName ?? widget.moduleKey,
            onBack: () => context.pop(),
            actions: [
              IconButton(
                tooltip: 'All readings',
                icon: const Icon(Icons.list_alt, color: Colors.white),
                onPressed: () => context
                    .push(Routes.healthList(widget.moduleKey, widget.memberId)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.spacingM),
            child: TimeRangeSelector(
                selected: _range, onChanged: (r) => setState(() => _range = r)),
          ),
          Expanded(
            child: series.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => LoadErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(vitalSeriesProvider(_key))),
              data: (s) => s.isEmpty
                  ? _empty(module?.icon, config)
                  : _content(s, config),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedFab(
        onPressed: () =>
            context.push(Routes.healthAdd(widget.moduleKey, widget.memberId)),
      ),
    );
  }

  Widget _empty(IconData? icon, VitalChartConfig? config) => EmptyStateWidget(
        icon: icon ?? Icons.show_chart,
        title: _range.days == null
            ? 'No readings yet'
            : 'No readings in the last ${_range.days} days',
        description: config?.emptyStateMessage ??
            'Add readings to see how they change over time.',
        ctaLabel: 'Add Reading',
        onCta: () =>
            context.push(Routes.healthAdd(widget.moduleKey, widget.memberId)),
      );

  Widget _content(VitalSeries s, VitalChartConfig? config) {
    final theme = Theme.of(context);
    final colors = [
      VitalModuleColors.getColors(widget.moduleKey).iconTint,
      theme.colorScheme.primary
    ];
    final grouped = switch (s.interval) {
      'day' => s.metrics.first.isSum ? 'Totals per day' : 'Daily averages',
      'week' =>
        s.metrics.first.isSum ? 'Average day, per week' : 'Weekly averages',
      'month' =>
        s.metrics.first.isSum ? 'Average day, per month' : 'Monthly averages',
      _ => 'Each reading',
    };

    return RefreshIndicator(
      onRefresh: () => ref.refresh(vitalSeriesProvider(_key).future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppDimens.spacingL, 0, AppDimens.spacingL, 96),
        children: [
          TrendHeaderCard(series: s, config: config, range: _range),
          const SizedBox(height: AppDimens.spacingM),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(config?.trendLabel ?? 'Trend',
                      style: theme.textTheme.titleSmall),
                  Text(grouped,
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  TrendChart(series: s, config: config, colors: colors),
                  ChartLegend(series: s, config: config, colors: colors),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.spacingM),
          for (final m in s.metrics)
            if ((s.stats[m.key]?.count ?? 0) > 0) ...[
              if (s.metrics.length > 1)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4, top: 4),
                  child: Text(m.label, style: theme.textTheme.labelLarge),
                ),
              VitalsStatsSummary(stats: _toStats(s.stats[m.key]!, m)),
            ],
          const SizedBox(height: AppDimens.spacingL),
          if (config?.healthZones != null)
            Text(
              '${config!.healthZones!.description.isEmpty ? '' : '${config.healthZones!.description} '}'
              'Zones are general guides, not a diagnosis. Talk to your doctor about your readings.',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  int get _decimals =>
      VitalChartConfig.getConfig(widget.moduleKey)?.decimalPlaces ?? 1;

  static double _round(double v, int decimals) =>
      double.parse(v.toStringAsFixed(decimals));

  VitalsStats _toStats(MetricStats st, VitalMetric m) => VitalsStats(
        min: st.min ?? 0,
        max: st.max ?? 0,
        average: _round(st.avg ?? 0, _decimals),
        lastValue: st.latest ?? 0,
        count: st.count,
        unit: m.isSum ? '${m.unit}/day' : m.unit,
      );
}
