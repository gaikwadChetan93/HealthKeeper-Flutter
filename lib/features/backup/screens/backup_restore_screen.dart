import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/hk_primary_button.dart';
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
      backgroundColor: AppColors.background,
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Backup list refreshed'), behavior: SnackBarBehavior.floating),
                    );
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
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 56, color: AppColors.textFaint),
          const SizedBox(height: 18),
          Text('Sign in to back up', style: AppTypography.screenTitle.copyWith(fontSize: 20), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            'Sign in with your account to back up your health data securely to the cloud and restore it on any device.',
            style: AppTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          HkPrimaryButton(label: 'Sign in', icon: Icons.login, onPressed: onSignIn, expand: false),
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
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_outlined, size: 56, color: AppColors.primary),
          const SizedBox(height: 18),
          Text('No backups yet', style: AppTypography.screenTitle.copyWith(fontSize: 20), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            'Create your first backup to keep your health data safe. Backups are encrypted and stored securely.',
            style: AppTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          HkPrimaryButton(label: 'Create first backup', icon: Icons.cloud_upload_outlined, onPressed: onCreateBackup, expand: false),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: HkPrimaryButton(
            label: 'Back up now',
            icon: Icons.cloud_upload_outlined,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Creating backup...'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
          child: Text('Previous backups', style: AppTypography.sectionTitle.copyWith(fontSize: 13)),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
            itemCount: _mockBackups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final backup = _mockBackups[index];
              return _BackupRow(backup: backup);
            },
          ),
        ),
      ],
    );
  }
}

class _BackupRow extends StatelessWidget {
  final _MockBackup backup;
  const _BackupRow({required this.backup});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimens.radiusTile),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backup.isLatest ? AppColors.primaryContainer : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppDimens.radiusChip),
            ),
            child: Icon(
              backup.isLatest ? Icons.cloud_done_outlined : Icons.cloud_outlined,
              size: 19,
              color: backup.isLatest ? AppColors.primary : AppColors.textMuted5,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(backup.date, style: AppTypography.cardTitle.copyWith(fontSize: 12.5)),
                const SizedBox(height: 2),
                Text(backup.size, style: AppTypography.captionSmall),
              ],
            ),
          ),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Restoring backup from ${backup.date}...'), behavior: SnackBarBehavior.floating),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                ),
                child: Text('Restore', style: AppTypography.chip.copyWith(color: AppColors.textMuted5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockBackup {
  final String date;
  final String size;
  final bool isLatest;

  const _MockBackup(this.date, this.size, this.isLatest);
}
