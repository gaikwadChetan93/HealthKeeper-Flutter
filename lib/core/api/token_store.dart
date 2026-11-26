import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The refresh token lives in the platform keystore; the short-lived access
/// token only in memory. No health data is ever stored on the device.
class TokenStore {
  static const _refreshKey = 'hk_refresh_token';
  final FlutterSecureStorage _storage;

  String? accessToken;

  TokenStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> readRefreshToken() async {
    try {
      return await _storage.read(key: _refreshKey);
    } catch (_) {
      // A keystore that can't be read (e.g. after a device restore) means signing in again.
      await clear();
      return null;
    }
  }

  Future<void> save({required String access, required String refresh}) async {
    accessToken = access;
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<void> clear() async {
    accessToken = null;
    try {
      await _storage.delete(key: _refreshKey);
    } catch (_) {}
  }
}
