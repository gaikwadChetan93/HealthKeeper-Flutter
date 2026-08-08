import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/health_record.dart';
import '../../../core/widgets/animated_fab.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/generic_record_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../config/module_screen_config.dart';

class GenericListScreen extends ConsumerStatefulWidget {
  final String moduleKey;
  final int memberId;

  const GenericListScreen({
    super.key,
    required this.moduleKey,
    required this.memberId,
  });

  @override
  ConsumerState<GenericListScreen> createState() => _GenericListScreenState();
}

class _GenericListScreenState extends ConsumerState<GenericListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final config = ModuleRegistry.getModuleByKey(widget.moduleKey);
    if (config == null) {
      return Scaffold(body: Center(child: Text('Unknown module: ${widget.moduleKey}')));
    }

    final screenConfig = ModuleScreenConfig.getConfig(widget.moduleKey);
    final provider = screenConfig.getProvider(widget.memberId);
    final state = ref.watch(provider);

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: config.domainName,
            onBack: () => context.pop(),
          ),
          // Search bar
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
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          // Records list
          Expanded(
            child: state.records.when(
              loading: () => const ShimmerLoading(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (records) {
                final filtered = _filterRecords(records, screenConfig);
                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: config.icon,
                    title: config.emptyStateTitle,
                    description: config.emptyStateDescription,
                    ctaLabel: config.emptyStateCTA,
                    onCta: () => context.push(
                      Routes.healthAdd(widget.moduleKey, widget.memberId),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final record = filtered[i];
                    return GenericRecordCard(
                      title: screenConfig.getTitle(record),
                      subtitle: screenConfig.getSubtitle(record),
                      date: screenConfig.getDate(record),
                      icon: config.icon,
                      moduleKey: widget.moduleKey,
                      syncStatus: record.syncStatus,
                      onTap: () => context.push(
                        Routes.healthDetail(widget.moduleKey, record.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedFab(
        onPressed: () => context.push(
          Routes.healthAdd(widget.moduleKey, widget.memberId),
        ),
      ),
    );
  }

  List<HealthRecord> _filterRecords(
    List<HealthRecord> records,
    ScreenConfig screenConfig,
  ) {
    if (_searchQuery.isEmpty) return records;
    final query = _searchQuery.toLowerCase();
    return records.where((r) {
      return screenConfig.getTitle(r).toLowerCase().contains(query) ||
          (screenConfig.getSubtitle(r)?.toLowerCase().contains(query) ?? false);
    }).toList();
  }
}
