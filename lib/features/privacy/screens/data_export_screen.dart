import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/widgets/standard_app_header.dart';

class DataExportScreen extends StatelessWidget {
  const DataExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: 'Export My Data',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.download_for_offline_outlined,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: AppDimens.spacingXL),
                  Text(
                    'Your Data, Your Right',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.spacingM),
                  Text(
                    'Under GDPR Article 20, you have the right to receive '
                    'your personal data in a structured, commonly used, and '
                    'machine-readable format.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.spacingXXL),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What\'s included:',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppDimens.spacingM),
                          _ExportInfoRow(
                            icon: Icons.people_outline,
                            label: 'Family member profiles',
                            theme: theme,
                          ),
                          const SizedBox(height: AppDimens.spacingS),
                          _ExportInfoRow(
                            icon: Icons.monitor_heart_outlined,
                            label: 'All health records & vitals',
                            theme: theme,
                          ),
                          const SizedBox(height: AppDimens.spacingS),
                          _ExportInfoRow(
                            icon: Icons.medical_services_outlined,
                            label: 'Doctor & appointment data',
                            theme: theme,
                          ),
                          const SizedBox(height: AppDimens.spacingS),
                          _ExportInfoRow(
                            icon: Icons.note_outlined,
                            label: 'Notes and attachments',
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preparing your data export...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Export All Data'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.spacingL,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacingM),
                  Text(
                    'Your data will be exported as a JSON file.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _ExportInfoRow({
    required this.icon,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: AppDimens.spacingM),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
