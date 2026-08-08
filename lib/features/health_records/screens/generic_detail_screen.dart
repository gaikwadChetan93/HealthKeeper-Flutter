import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/widgets/standard_app_header.dart';

class GenericDetailScreen extends ConsumerWidget {
  final String moduleKey;
  final int recordId;

  const GenericDetailScreen({
    super.key,
    required this.moduleKey,
    required this.recordId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ModuleRegistry.getModuleByKey(moduleKey);
    if (config == null) {
      return Scaffold(body: Center(child: Text('Unknown module: $moduleKey')));
    }

    final theme = Theme.of(context);

    // Build detail fields from config
    final detailFields = config.fields
        .map((f) => _DetailField(label: f.label, key: f.key))
        .toList();

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: config.domainName,
            onBack: () => context.pop(),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () {
                  // Navigate to edit - would need memberId from record
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () => _showDeleteDialog(context),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.spacingL),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Record title
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(
                                  AppDimens.radiusS),
                            ),
                            child: Icon(config.icon,
                                color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: AppDimens.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  config.domainName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Record #$recordId',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.spacingXL),
                      const Divider(),
                      const SizedBox(height: AppDimens.spacingL),

                      // Timeline-style field display
                      ...detailFields.map((field) => _TimelineItem(
                            label: field.label,
                            value: '—', // Placeholder
                          )),

                      const SizedBox(height: AppDimens.spacingL),
                      const Divider(),
                      const SizedBox(height: AppDimens.spacingS),

                      // Timestamps
                      Text(
                        'Created: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Record deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DetailField {
  final String label;
  final String key;
  const _DetailField({required this.label, required this.key});
}

class _TimelineItem extends StatelessWidget {
  final String label;
  final String value;

  const _TimelineItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 30,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(width: AppDimens.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
