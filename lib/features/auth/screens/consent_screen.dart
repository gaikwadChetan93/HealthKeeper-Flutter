import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/models/privacy_notice.dart';
import '../../../core/state/privacy_providers.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../privacy/widgets/privacy_notice_view.dart';

/// Asked after first sign-in, and again whenever the privacy notice changes.
/// Health records can't be kept without explicit consent to health data processing;
/// usage statistics are a separate, optional choice that starts off.
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _healthData = false;
  bool _terms = false;
  bool? _analytics; // null until read from what they chose before
  bool _saving = false;
  String? _error;

  Future<void> _continue(PrivacyNotice notice) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).saveConsents(notice.policyVersion, {
        ConsentPurpose.healthData: true,
        ConsentPurpose.terms: true,
        ConsentPurpose.privacy: true,
        ConsentPurpose.analytics: _analytics ?? false,
      });
      // The router moves on once the consent is recorded.
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notice = ref.watch(privacyNoticeProvider);
    final updating = ref.watch(authProvider).me?.consentUpdateRequired ?? false;
    // Keep an earlier choice about usage statistics when asking again.
    _analytics ??=
        ref.watch(consentsProvider).valueOrNull?[ConsentPurpose.analytics];

    return Scaffold(
      body: SafeArea(
        child: notice.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => LoadErrorView(
              error: e, onRetry: () => ref.invalidate(privacyNoticeProvider)),
          data: (n) => ListView(
            padding: const EdgeInsets.all(AppDimens.spacingXL),
            children: [
              Icon(Icons.verified_user_outlined,
                  size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: AppDimens.spacingL),
              Text(
                  updating
                      ? 'We’ve updated our privacy notice'
                      : 'Before you start',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              if (updating)
                Padding(
                  padding: const EdgeInsets.only(top: AppDimens.spacingS),
                  child: Text(
                      'Please read it and agree again to keep using the app.',
                      style: theme.textTheme.bodyMedium),
                ),
              const SizedBox(height: AppDimens.spacingM),
              PrivacyNoticeView(notice: n),
              const Divider(height: AppDimens.spacingXL),
              CheckboxListTile(
                value: _healthData,
                onChanged: (v) => setState(() => _healthData = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                    'I consent to Health Keeper storing and processing health records '
                    'for me and the family members I add, as described above.'),
              ),
              CheckboxListTile(
                value: _terms,
                onChanged: (v) => setState(() => _terms = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                    'I’m 18 or older and agree to the Terms of Service and Privacy Policy.'),
              ),
              SwitchListTile(
                value: _analytics ?? false,
                onChanged: (v) => setState(() => _analytics = v),
                contentPadding: EdgeInsets.zero,
                title: const Text('Share usage statistics (optional)'),
                subtitle: const Text(
                    'Helps us find problems. Never includes health data. You can change this in Settings.'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppDimens.spacingM),
                  child: Text(_error!,
                      style: TextStyle(color: theme.colorScheme.error)),
                ),
              const SizedBox(height: AppDimens.spacingL),
              FilledButton(
                onPressed: _healthData && _terms && !_saving
                    ? () => _continue(n)
                    : null,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Agree and continue'),
              ),
              const SizedBox(height: AppDimens.spacingM),
              TextButton(
                onPressed: () => ref.read(authProvider.notifier).signOut(),
                child: const Text('Not now — sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
