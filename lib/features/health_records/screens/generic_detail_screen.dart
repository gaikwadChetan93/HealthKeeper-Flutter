import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/domain_config.dart';
import '../../../core/models/field_descriptor.dart';
import '../../../core/models/record_item.dart';
import '../../../core/records/record_format.dart';
import '../../../core/state/api_providers.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../widgets/timeline_item.dart';

class GenericDetailScreen extends ConsumerWidget {
  final String moduleKey;
  final String recordId;

  const GenericDetailScreen(
      {super.key, required this.moduleKey, required this.recordId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ModuleRegistry.getModuleByKey(moduleKey);
    if (config == null) {
      return Scaffold(body: Center(child: Text('Unknown module: $moduleKey')));
    }
    final record = ref.watch(recordProvider(recordId));
    final loaded = record.valueOrNull;

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: config.domainName,
            onBack: () => context.pop(),
            actions: [
              if (loaded != null) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push(
                      Routes.healthEdit(moduleKey, loaded.memberId, loaded.id)),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context, ref, loaded),
                ),
              ],
            ],
          ),
          Expanded(
            child: record.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => LoadErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(recordProvider(recordId))),
              data: (r) => _RecordDetails(config: config, record: r),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, RecordItem record) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(recordActionsProvider).delete(record);
      if (!context.mounted) return;
      showMessage(context, 'Record deleted');
      context.pop();
    } on ApiException catch (e) {
      if (context.mounted) showMessage(context, e.message);
    }
  }
}

class _RecordDetails extends StatelessWidget {
  final DomainConfig config;
  final RecordItem record;

  const _RecordDetails({required this.config, required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shown = config.fields
        .where(
            (f) => f is! FileFieldDescriptor && record.payload[f.key] != null)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppDimens.radiusS),
                    ),
                    child: Icon(config.icon, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: AppDimens.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(RecordFormat.title(config, record),
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        Text(config.domainName,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.spacingXL),
              const Divider(),
              const SizedBox(height: AppDimens.spacingL),
              for (final f in shown)
                TimelineItem(
                    label: f.label,
                    value: RecordFormat.display(f, record.payload[f.key])),
              if (record.doctorId != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () =>
                        context.push(Routes.doctorDetail(record.doctorId!)),
                    icon: const Icon(Icons.medical_services_outlined, size: 18),
                    label: const Text('Open doctor'),
                  ),
                ),
              const SizedBox(height: AppDimens.spacingL),
              const Divider(),
              const SizedBox(height: AppDimens.spacingS),
              Text(
                'Added ${DateFormat('dd MMM yyyy, hh:mm a').format(record.createdAt)}'
                '${record.version > 1 ? ' • Updated ${DateFormat('dd MMM yyyy, hh:mm a').format(record.updatedAt)}' : ''}',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
