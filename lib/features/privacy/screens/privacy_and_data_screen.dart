import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/state/privacy_providers.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../../settings/widgets/settings_item.dart';

class PrivacyAndDataScreen extends ConsumerWidget {
  const PrivacyAndDataScreen({super.key});

  /// Opens a policy once the notice (which holds the links) has loaded.
  void _open(BuildContext context, WidgetRef ref, String key) {
    final notice = ref.read(privacyNoticeProvider).valueOrNull;
    if (notice != null) openPolicy(context, notice, key);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(privacyNoticeProvider); // loads the policy links
    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: 'Privacy & Data',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.spacingL,
              ),
              children: [
                SettingsItem(
                  icon: Icons.tune_outlined,
                  title: 'Your Choices',
                  subtitle: 'What you’ve agreed to, and the privacy notice',
                  onTap: () => context.push(Routes.privacyChoices),
                ),
                const Divider(height: 1, indent: 76),
                SettingsItem(
                  icon: Icons.download_outlined,
                  title: 'Export My Data',
                  subtitle: 'Download a copy of all your health data',
                  onTap: () => context.push(Routes.dataExport),
                ),
                const Divider(height: 1, indent: 76),
                SettingsItem(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete Account',
                  subtitle: 'Permanently remove your account and data',
                  onTap: () => context.push(Routes.deleteAccount),
                ),
                const Divider(height: 1, indent: 76),
                SettingsItem(
                  icon: Icons.policy_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () => _open(context, ref, 'privacy'),
                ),
                const Divider(height: 1, indent: 76),
                SettingsItem(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  subtitle: 'Read our terms of service',
                  onTap: () => _open(context, ref, 'terms'),
                ),
                const Divider(height: 1, indent: 76),
                SettingsItem(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Health Data Policy',
                  subtitle: 'How we handle consumer health data (US)',
                  onTap: () => _open(context, ref, 'health-data'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
