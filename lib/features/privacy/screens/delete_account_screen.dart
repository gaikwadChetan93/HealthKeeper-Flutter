import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/widgets/standard_app_header.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: 'Delete Account',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.spacingXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 80,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: AppDimens.spacingXL),
                  Text(
                    'Delete Your Account?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.spacingM),
                  Text(
                    'This action is permanent and cannot be undone. '
                    'Please read carefully before proceeding.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.spacingXXL),
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What will be deleted:',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: AppDimens.spacingM),
                          _DeleteInfoRow(
                            label: 'Your account and profile',
                            theme: theme,
                          ),
                          const SizedBox(height: AppDimens.spacingS),
                          _DeleteInfoRow(
                            label: 'All family member data',
                            theme: theme,
                          ),
                          const SizedBox(height: AppDimens.spacingS),
                          _DeleteInfoRow(
                            label: 'All health records and vitals',
                            theme: theme,
                          ),
                          const SizedBox(height: AppDimens.spacingS),
                          _DeleteInfoRow(
                            label: 'Cloud backups and preferences',
                            theme: theme,
                          ),
                          const SizedBox(height: AppDimens.spacingS),
                          _DeleteInfoRow(
                            label: 'Active subscriptions',
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => _showConfirmationDialog(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.spacingL,
                      ),
                    ),
                    child: const Text('Delete My Account'),
                  ),
                  const SizedBox(height: AppDimens.spacingM),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.spacingL,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Are you absolutely sure?'),
        content: const Text(
          'This will permanently delete all your data. '
          'This action cannot be reversed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion requested.'),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Yes, Delete Everything'),
          ),
        ],
      ),
    );
  }
}

class _DeleteInfoRow extends StatelessWidget {
  final String label;
  final ThemeData theme;

  const _DeleteInfoRow({
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.close, size: 18, color: Colors.red.shade700),
        const SizedBox(width: AppDimens.spacingM),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red.shade900,
            ),
          ),
        ),
      ],
    );
  }
}
