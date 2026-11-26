import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../widgets/settings_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: 'Settings',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.spacingL,
              ),
              children: [
                SettingsItem(
                  icon: Icons.group_outlined,
                  title: 'Family',
                  subtitle: 'Manage the people you look after',
                  onTap: () => context.push(Routes.family),
                ),
                const Divider(height: 1, indent: 76),
                SettingsItem(
                  icon: Icons.medical_services_outlined,
                  title: 'Doctors',
                  subtitle: 'Shared across the whole family',
                  onTap: () => context.push(Routes.doctors),
                ),
                const Divider(height: 1, indent: 76),
                SettingsItem(
                  icon: Icons.shield_outlined,
                  title: 'Privacy & Data',
                  subtitle: 'Manage your data and privacy preferences',
                  onTap: () => context.push(Routes.privacyAndData),
                ),
                const Divider(height: 1, indent: 76),
                SettingsItem(
                  icon: Icons.cloud_outlined,
                  title: 'Backup & Restore',
                  subtitle: 'Keep your health data safe in the cloud',
                  onTap: () => context.push(Routes.backupRestore),
                ),
                const Divider(height: 1, indent: 76),
                SettingsItem(
                  icon: Icons.card_giftcard_outlined,
                  title: 'Invite Friends',
                  subtitle: 'Share Health Keeper with loved ones',
                  onTap: () => context.push(Routes.inviteFriends),
                ),
                const Divider(height: 1, indent: 76),
                SettingsItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App version, licenses and more',
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.spacingXL),
            child: Text(
              'Health Keeper • Made with love for your wellness',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Health Keeper',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Health Keeper. All rights reserved.',
      applicationIcon: const Icon(
        Icons.favorite,
        size: 48,
        color: Colors.redAccent,
      ),
    );
  }
}
