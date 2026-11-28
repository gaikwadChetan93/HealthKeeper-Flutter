import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/records/record_format.dart';
import '../../../core/state/api_providers.dart';
import '../../../core/widgets/animated_fab.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/generic_record_card.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../../vitals/config/vital_chart_config.dart';

class GenericListScreen extends ConsumerStatefulWidget {
  final String moduleKey;
  final String memberId;

  const GenericListScreen(
      {super.key, required this.moduleKey, required this.memberId});

  @override
  ConsumerState<GenericListScreen> createState() => _GenericListScreenState();
}

class _GenericListScreenState extends ConsumerState<GenericListScreen> {
  String _query = '';
  Timer? _debounce;

  RecordsKey get _key =>
      (memberId: widget.memberId, module: widget.moduleKey, query: _query);

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Search runs on the server, a moment after typing stops.
  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = v.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = ModuleRegistry.getModuleByKey(widget.moduleKey);
    if (config == null) {
      return Scaffold(
          body: Center(child: Text('Unknown module: ${widget.moduleKey}')));
    }
    final records = ref.watch(recordsProvider(_key));

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: config.domainName,
            onBack: () => context.pop(),
            actions: [
              if (VitalChartConfig.getConfig(widget.moduleKey) != null)
                IconButton(
                  tooltip: 'Trends',
                  icon: const Icon(Icons.show_chart),
                  onPressed: () => context.push(
                      Routes.vitalChart(widget.moduleKey, widget.memberId)),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.spacingL),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search ${config.domainName.toLowerCase()}...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.spacingL,
                  vertical: AppDimens.spacingS,
                ),
              ),
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: records.when(
              skipLoadingOnReload: true,
              loading: () => const ShimmerLoading(),
              error: (e, _) => LoadErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(recordsProvider(_key))),
              data: (page) {
                if (page.items.isEmpty) {
                  return _query.isNotEmpty
                      ? Center(child: Text('Nothing matches “$_query”'))
                      : EmptyStateWidget(
                          icon: config.icon,
                          title: config.emptyStateTitle,
                          description: config.emptyStateDescription,
                          ctaLabel: config.emptyStateCTA,
                          onCta: () => context.push(Routes.healthAdd(
                              widget.moduleKey, widget.memberId)),
                        );
                }
                final more = page.nextCursor != null;
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(recordsProvider(_key).future),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: page.items.length + (more ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == page.items.length) {
                        ref.read(recordsProvider(_key).notifier).loadMore();
                        return const Padding(
                          padding: EdgeInsets.all(AppDimens.spacingL),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final r = page.items[i];
                      return GenericRecordCard(
                        title: RecordFormat.title(config, r),
                        subtitle: RecordFormat.subtitle(config, r),
                        date: r.recordDate,
                        icon: config.icon,
                        moduleKey: widget.moduleKey,
                        onTap: () => context
                            .push(Routes.healthDetail(widget.moduleKey, r.id)),
                      );
                    },
                  ),
                );
              },
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
}
