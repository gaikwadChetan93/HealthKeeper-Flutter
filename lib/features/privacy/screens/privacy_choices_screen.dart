import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/models/privacy_notice.dart';
import '../../../core/state/privacy_providers.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../widgets/privacy_notice_view.dart';

/// What you've agreed to, and changing it: usage statistics on or off, and withdrawing
/// consent to health data processing (which, as the app can't work without it, means
/// deleting the account). The full privacy notice is below.
class PrivacyChoicesScreen extends ConsumerWidget {
  const PrivacyChoicesScreen({super.key});

  Future<void> _setAnalytics(BuildContext context, WidgetRef ref,
      PrivacyNotice notice, bool on) async {
    try {
      await ref
          .read(authProvider.notifier)
          .saveConsents(notice.policyVersion, {ConsentPurpose.analytics: on});
      ref.invalidate(consentsProvider);
    } catch (e) {
      if (context.mounted) showMessage(context, '$e');
    }
  }

  Future<void> _withdraw(BuildContext context, PrivacyNotice notice) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Withdraw consent?'),
        content: Text(notice.withdraw),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Keep my records')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Continue to delete')),
        ],
      ),
    );
    if (go == true && context.mounted) context.push(Routes.deleteAccount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notice = ref.watch(privacyNoticeProvider);
    final consents = ref.watch(consentsProvider);
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Scaffold(
      body: Column(children: [
        StandardAppHeader(title: 'Your Choices', onBack: () => context.pop()),
        Expanded(
          child: switch ((notice, consents)) {
            (AsyncData(value: final n), AsyncData(value: final c)) => ListView(
                padding: const EdgeInsets.all(AppDimens.spacingL),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.spacingL),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Health data processing',
                                style: theme.textTheme.titleSmall),
                            const SizedBox(height: 4),
                            Text(
                                'On. Needed to keep records for you and your family.',
                                style: muted),
                            TextButton(
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  foregroundColor: theme.colorScheme.error),
                              onPressed: () => _withdraw(context, n),
                              child: const Text('Withdraw consent'),
                            ),
                          ]),
                    ),
                  ),
                  Card(
                    child: SwitchListTile(
                      value: c[ConsentPurpose.analytics] ?? false,
                      onChanged: (v) => _setAnalytics(context, ref, n, v),
                      title: const Text('Share usage statistics'),
                      subtitle: const Text(
                          'Helps us find problems. Never includes health data.'),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacingL),
                  Text('Privacy notice', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppDimens.spacingS),
                  PrivacyNoticeView(notice: n),
                ],
              ),
            (AsyncError(:final error), _) ||
            (_, AsyncError(:final error)) =>
              LoadErrorView(
                  error: error,
                  onRetry: () {
                    ref.invalidate(privacyNoticeProvider);
                    ref.invalidate(consentsProvider);
                  }),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ]),
    );
  }
}
