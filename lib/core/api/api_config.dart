import 'package:flutter/foundation.dart';

/// Where the app finds the Health Keeper API.
///
/// Set at build time:
///   flutter run --dart-define=API_BASE_URL=https://api.example.com
/// Debug builds default to the backend on the developer's machine, which the
/// Android emulator reaches at 10.0.2.2.
class ApiConfig {
  ApiConfig._();

  static const _fromBuild = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_fromBuild.isNotEmpty) return _fromBuild;
    if (kDebugMode) {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:8000'
          : 'http://localhost:8000';
    }
    throw StateError('Build with --dart-define=API_BASE_URL=https://...');
  }

  /// The sign-in without Google exists only on a local backend, so the
  /// button is shown only in debug builds.
  static bool get showDevSignIn => kDebugMode;

  static const requestTimeout = Duration(seconds: 20);
}
