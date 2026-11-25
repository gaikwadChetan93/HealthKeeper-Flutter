import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/auth/auth_controller.dart';

/// Asked once after first sign-in (and again if the policy changes).
/// Health records can't be saved until health-data processing is allowed.
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _healthData = false;
  bool _terms = false;
  bool _saving = false;
  String? _error;

  Future<void> _continue() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final auth = ref.read(authProvider.notifier);
    try {
      final current = await auth.consents();
      await auth.saveConsents(current['policy_version'] as String, {
        'health_data_processing': true,
        'terms_of_service': true,
        'privacy_policy': true,
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
    final ready = _healthData && _terms && !_saving;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.spacingXL),
          children: [
            Icon(Icons.verified_user_outlined,
                size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: AppDimens.spacingL),
            Text('Before you start',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDimens.spacingM),
            Text(
              'Health Keeper stores the health records you add for yourself and your family, '
              'so you can see them on any device and follow how they change. Records are '
              'stored encrypted in India, are never sold, and you can delete everything at any time.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppDimens.spacingXL),
            CheckboxListTile(
              value: _healthData,
              onChanged: (v) => setState(() => _healthData = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                  'I allow Health Keeper to store and process health records for me '
                  'and the family members I add.'),
            ),
            CheckboxListTile(
              value: _terms,
              onChanged: (v) => setState(() => _terms = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text(
                  'I agree to the Terms of Service and Privacy Policy.'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppDimens.spacingM),
                child: Text(_error!,
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
            const SizedBox(height: AppDimens.spacingXL),
            FilledButton(
              onPressed: ready ? _continue : null,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Continue'),
            ),
            const SizedBox(height: AppDimens.spacingM),
            TextButton(
              onPressed: () => ref.read(authProvider.notifier).signOut(),
              child: const Text('Not now — sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
