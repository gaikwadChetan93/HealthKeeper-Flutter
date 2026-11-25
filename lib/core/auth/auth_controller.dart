import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_exception.dart';
import '../api/token_store.dart';
import '../models/record_item.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: ApiConfig.baseUrl, tokens: TokenStore());
});

enum AuthStatus { starting, signedOut, signedIn }

class AuthState {
  final AuthStatus status;
  final Me? me;

  /// Set when starting up failed for a reason other than being signed out
  /// (e.g. no network), so the splash screen can offer to retry.
  final String? startupError;

  const AuthState(this.status, {this.me, this.startupError});

  bool get needsConsent => me != null && !me!.healthDataConsent;
  bool get needsProfile =>
      me != null && me!.healthDataConsent && me!.selfMemberId == null;
  bool get isReady =>
      status == AuthStatus.signedIn && !needsConsent && !needsProfile;
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(apiClientProvider));
});

class AuthController extends StateNotifier<AuthState> {
  final ApiClient _api;

  AuthController(this._api) : super(const AuthState(AuthStatus.starting)) {
    _api.onSessionEnded = () {
      if (mounted && state.status == AuthStatus.signedIn) {
        state = const AuthState(AuthStatus.signedOut);
      }
    };
    restore();
  }

  /// On launch: a stored refresh token means the person is still signed in.
  Future<void> restore() async {
    state = const AuthState(AuthStatus.starting);
    try {
      if (!await _api.refreshSession()) {
        state = const AuthState(AuthStatus.signedOut);
        return;
      }
      await reloadMe();
    } on ApiException catch (e) {
      state = e.isUnauthenticated
          ? const AuthState(AuthStatus.signedOut)
          : AuthState(AuthStatus.starting, startupError: e.message);
    }
  }

  Future<void> reloadMe() async {
    final me = Me.fromJson(await _api.get('/v1/me') as Map<String, dynamic>);
    state = AuthState(AuthStatus.signedIn, me: me);
  }

  /// Local development only: the backend accepts this when HK_ENV=local.
  Future<void> devSignIn(String email, String name) async {
    final data = await _api.post('/v1/auth/dev-token', auth: false, body: {
      'email': email,
      'name': name,
      'platform': 'android',
      'device_name': 'Emulator'
    });
    await _signedIn(data as Map<String, dynamic>);
  }

  /// Exchanges a Google ID token (from the Google sign-in SDK) for our tokens.
  Future<void> googleSignIn(String idToken) async {
    final data = await _api.post('/v1/auth/token',
        auth: false, body: {'id_token': idToken, 'platform': 'android'});
    await _signedIn(data as Map<String, dynamic>);
  }

  Future<void> _signedIn(Map<String, dynamic> data) async {
    await _api.tokens
        .save(access: data['access_token'], refresh: data['refresh_token']);
    await reloadMe();
  }

  Future<void> signOut() async {
    try {
      await _api.post('/v1/auth/logout');
    } catch (_) {
      // Signing out on this device works even if the server can't be reached.
    }
    await _api.tokens.clear();
    state = const AuthState(AuthStatus.signedOut);
  }

  Future<Map<String, dynamic>> consents() async =>
      await _api.get('/v1/me/consents') as Map<String, dynamic>;

  Future<void> saveConsents(
      String policyVersion, Map<String, bool> granted) async {
    await _api.put('/v1/me/consents', body: {
      'policy_version': policyVersion,
      'consents': [
        for (final e in granted.entries) {'purpose': e.key, 'granted': e.value},
      ],
    });
    await reloadMe();
  }
}
