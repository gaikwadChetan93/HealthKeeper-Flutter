import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/api/api_config.dart';
import '../../../core/auth/auth_controller.dart';
import '../widgets/dev_sign_in_sheet.dart';

/// Google is the only way to sign in. Signing in is required: health records
/// are kept on the server, never only on the phone.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _isLoading = false;

  Future<void> _googleSignIn() async {
    // Needs the Google OAuth client IDs (Android + web) from Google Cloud.
    // Once they exist: get an ID token from the Google sign-in SDK and pass it
    // to ref.read(authProvider.notifier).googleSignIn(idToken).
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Google sign-in is not set up yet. Use the developer sign-in for now.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _devSignIn() async {
    final result = await showDevSignInSheet(context);
    if (result == null || !mounted) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .devSignIn(result.email, result.name);
      // The router moves on by itself once signed in.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingXL),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.lock_outline,
                  size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: AppDimens.spacingXL),
              Text(
                'Sign In',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimens.spacingM),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppDimens.spacingXL),
                child: Text(
                  'Sign in with your Google account. Your family’s records are kept securely '
                  'on Health Keeper’s servers in India, so they’re safe if you lose your phone.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _googleSignIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              if (ApiConfig.showDevSignIn) ...[
                const SizedBox(height: AppDimens.spacingL),
                TextButton.icon(
                  onPressed: _isLoading ? null : _devSignIn,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.developer_mode, size: 18),
                  label: Text(_isLoading
                      ? 'Signing in…'
                      : 'Developer sign-in (local server)'),
                ),
              ],
              const SizedBox(height: AppDimens.spacingXXL),
            ],
          ),
        ),
      ),
    );
  }
}
