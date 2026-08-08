import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/widgets/standard_app_header.dart';

enum _BackupState { notSignedIn, noBackups, hasBackups }

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  // Mock state — replace with real auth/backup logic
  _BackupState _currentState = _BackupState.notSignedIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: 'Backup & Restore',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: switch (_currentState) {
              _BackupState.notSignedIn => _NotSignedInView(
                  onSignIn: () {
                    setState(() => _currentState = _BackupState.noBackups);
                  },
                ),
              _BackupState.noBackups => _NoBackupsView(
                  onCreateBackup: () {
                    setState(() => _currentState = _BackupState.hasBackups);
                  },
                ),
              _BackupState.hasBackups => _HasBackupsView(
                  onRefresh: () {
                    // TODO: Refresh backup list
                  },
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _NotSignedInView extends StatelessWidget {
  final VoidCallback onSignIn;

  const _NotSignedInView({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.spacingXXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 80,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppDimens.spacingXL),
          Text(
            'Sign In to Back Up',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.spacingM),
          Text(
            'Sign in with your account to back up your health data '
            'securely to the cloud and restore it on any device.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.spacingXXL),
          FilledButton.icon(
            onPressed: onSignIn,
            icon: const Icon(Icons.login),
            label: const Text('Sign In'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spacingXXL,
                vertical: AppDimens.spacingL,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoBackupsView extends StatelessWidget {
  final VoidCallback onCreateBackup;

  const _NoBackupsView({required this.onCreateBackup});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.spacingXXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_outlined,
            size: 80,
            color: colorScheme.primary,
          ),
          const SizedBox(height: AppDimens.spacingXL),
          Text(
            'No Backups Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.spacingM),
          Text(
            'Create your first backup to keep your health data safe. '
            'Backups are encrypted and stored securely.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.spacingXXL),
          FilledButton.icon(
            onPressed: onCreateBackup,
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Create First Backup'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spacingXXL,
                vertical: AppDimens.spacingL,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HasBackupsView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _HasBackupsView({required this.onRefresh});

  // Mock backup data
  static const _mockBackups = [
    _MockBackup('Aug 5, 2026 – 10:30 AM', '2.4 MB', true),
    _MockBackup('Aug 1, 2026 – 3:15 PM', '2.3 MB', false),
    _MockBackup('Jul 25, 2026 – 9:00 AM', '2.1 MB', false),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.spacingXL,
            AppDimens.spacingXL,
            AppDimens.spacingXL,
            AppDimens.spacingM,
          ),
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Creating backup...')),
              );
            },
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Back Up Now'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.spacingL,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spacingXL,
            vertical: AppDimens.spacingS,
          ),
          child: Text(
            'Previous Backups',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spacingL,
            ),
            itemCount: _mockBackups.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimens.spacingS),
            itemBuilder: (context, index) {
              final backup = _mockBackups[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    backup.isLatest
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_outlined,
                    color: backup.isLatest
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  title: Text(backup.date),
                  subtitle: Text(backup.size),
                  trailing: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Restoring backup from ${backup.date}...'),
                        ),
                      );
                    },
                    child: const Text('Restore'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MockBackup {
  final String date;
  final String size;
  final bool isLatest;

  const _MockBackup(this.date, this.size, this.isLatest);
}
