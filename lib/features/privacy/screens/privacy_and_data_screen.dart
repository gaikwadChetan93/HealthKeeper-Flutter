import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../../settings/widgets/settings_item.dart';

class PrivacyAndDataScreen extends StatelessWidget {
  const PrivacyAndDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  onTap: () {
                    // TODO: Open privacy policy URL
                  },
                ),
                const Divider(height: 1, indent: 76),
                SettingsItem(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  subtitle: 'Read our terms of service',
                  onTap: () {
                    // TODO: Open terms URL
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
