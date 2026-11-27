import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/widgets/standard_app_header.dart';

/// Deletes the whole account. Every device is signed out at once; the data is
/// removed from the servers after 30 days, and signing in before then offers
/// to restore it. To remove one family member, use Edit member → Delete.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  String _typed = '';
  bool _deleting = false;
  String? _error;

  static const _deleted = [
    'Your account and sign-in',
    'Your profile and every family member',
    'All health records and vitals',
    'Lab reports and uploaded report files',
    'Your saved doctors',
    'Your consent choices',
  ];

  Future<void> _delete() async {
    setState(() {
      _deleting = true;
      _error = null;
    });
    // The app's messenger outlives this screen, which closes once signed out.
    final messenger = ScaffoldMessenger.of(context);
    try {
      final purgeAfter = await ref.read(authProvider.notifier).deleteAccount();
      messenger.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
        content: Text(
            'Your account is deleted. Everything will be removed for good on '
            '${DateFormat('d MMMM yyyy').format(purgeAfter)}. Sign in before then to restore it.'),
      ));
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ready = _typed.trim() == 'DELETE' && !_deleting;

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
              title: 'Delete Account', onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppDimens.spacingXL),
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 64, color: scheme.error),
                const SizedBox(height: AppDimens.spacingL),
                Text('Delete your account?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppDimens.spacingM),
                Text(
                  'You’ll be signed out on every device straight away. Everything is removed '
                  'from our servers after 30 days. Until then you can restore your account by '
                  'signing in again.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppDimens.spacingXL),
                _DeletedList(items: _deleted),
                const SizedBox(height: AppDimens.spacingM),
                Text(
                  'Only want to remove one family member? Open them from Family and choose Delete.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppDimens.spacingXL),
                TextField(
                  enabled: !_deleting,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                      labelText: 'Type DELETE to confirm'),
                  onChanged: (v) => setState(() => _typed = v),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimens.spacingM),
                    child: Text(_error!, style: TextStyle(color: scheme.error)),
                  ),
                const SizedBox(height: AppDimens.spacingXL),
                FilledButton(
                  onPressed: ready ? _delete : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.spacingL),
                  ),
                  child: _deleting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: scheme.onError))
                      : const Text('Delete My Account'),
                ),
                const SizedBox(height: AppDimens.spacingM),
                OutlinedButton(
                  onPressed: _deleting ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.spacingL)),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeletedList extends StatelessWidget {
  final List<String> items;

  const _DeletedList({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What will be deleted',
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onErrorContainer)),
            const SizedBox(height: AppDimens.spacingM),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.spacingS),
                child: Row(
                  children: [
                    Icon(Icons.close, size: 18, color: scheme.onErrorContainer),
                    const SizedBox(width: AppDimens.spacingM),
                    Expanded(
                      child: Text(item,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: scheme.onErrorContainer)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
