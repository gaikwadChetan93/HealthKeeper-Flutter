import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../widgets/settings_item.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authProvider.select((s) => s.me));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          const StandardAppHeader(title: 'Settings'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.spacingL,
              ),
              children: [
                if (me != null) ...[
                  SettingsItem(
                    icon: Icons.account_circle_outlined,
                    title: me.name,
                    subtitle:
                        '${me.email} • ${me.planId == 'free' ? 'Free plan' : me.planId}',
                    onTap: () => context.push(Routes.manageSubscription),
                  ),
                  const Divider(height: 1, indent: 76),
                ],
                SettingsItem(
                  icon: Icons.shield_outlined,
                  title: 'Privacy & Data',
                  subtitle: 'Manage your data and privacy preferences',
                  onTap: () => context.push(Routes.privacyAndData),
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
                const Divider(height: 1, indent: 76),
                SettingsItem(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Your records stay safe on Health Keeper',
                  onTap: () => _confirmSignOut(context, ref),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppDimens.spacingXL),
                  child: Text(
                    'Health Keeper • Made with love for your wellness',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Sign out?'),
        content:
            const Text('You can sign in again any time to see your records.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Sign Out')),
        ],
      ),
    );
    if (ok == true) await ref.read(authProvider.notifier).signOut();
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
