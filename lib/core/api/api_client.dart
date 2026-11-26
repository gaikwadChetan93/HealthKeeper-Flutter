import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'token_store.dart';

/// Talks to the Health Keeper API. Adds the access token, refreshes it when it
/// expires, and turns error responses into [ApiException].
class ApiClient {
  final String baseUrl;
  final TokenStore tokens;
  final http.Client _http;

  /// Called when the session can't be refreshed, so the app returns to sign-in.
  void Function()? onSessionEnded;

  Future<bool>? _refreshing;

  ApiClient(
      {required this.baseUrl, required this.tokens, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  Future<dynamic> get(String path, {Map<String, String?>? query}) =>
      _request('GET', path, query: query);

  Future<dynamic> post(String path,
          {Object? body, String? idempotencyKey, bool auth = true}) =>
      _request('POST', path, body: body, auth: auth, headers: {
        if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey
      });

  Future<dynamic> put(String path, {Object? body}) =>
      _request('PUT', path, body: body);

  /// Updates send the version being changed, so edits from two devices can't
  /// silently overwrite each other (the API answers 409).
  Future<dynamic> patch(String path,
          {required Object body, required int version}) =>
      _request('PATCH', path, body: body, headers: {'If-Match': '"$version"'});

  Future<dynamic> delete(String path) => _request('DELETE', path);

  /// Exchanges a refresh token for new tokens. Returns false if signing in again is needed.
  Future<bool> refreshSession() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final refresh = await tokens.readRefreshToken();
    if (refresh == null) return false;
    try {
      final data = await _request('POST', '/v1/auth/refresh',
          body: {'refresh_token': refresh},
          auth: false) as Map<String, dynamic>;
      await tokens.save(
          access: data['access_token'], refresh: data['refresh_token']);
      return true;
    } on ApiException catch (e) {
      if (e.isUnauthenticated) {
        await tokens.clear();
        return false;
      }
      rethrow;
    }
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    Map<String, String?>? query,
    Map<String, String> headers = const {},
    bool auth = true,
    bool retried = false,
  }) async {
    if (auth && tokens.accessToken == null && !await refreshSession()) {
      _sessionEnded();
    }
    final params = {
      for (final e in (query ?? const <String, String?>{}).entries)
        if (e.value != null && e.value!.isNotEmpty) e.key: e.value!,
    };
    final uri = Uri.parse('$baseUrl$path')
        .replace(queryParameters: params.isEmpty ? null : params);
    final request = http.Request(method, uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'X-Request-ID': _requestId(),
        if (auth && tokens.accessToken != null)
          'Authorization': 'Bearer ${tokens.accessToken}',
        ...headers,
      });
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    http.Response response;
    try {
      response = await http.Response.fromStream(
          await _http.send(request).timeout(ApiConfig.requestTimeout));
    } on SocketException {
      throw ApiException.network();
    } on TimeoutException {
      throw ApiException.network();
    } on http.ClientException {
      throw ApiException.network();
    }

    if (response.statusCode == 401 && auth && !retried) {
      final code = _error(response).code;
      if (code == 'token_expired' || code == 'unauthenticated') {
        tokens.accessToken = null;
        if (await refreshSession()) {
          return _request(method, path,
              body: body,
              query: query,
              headers: headers,
              auth: auth,
              retried: true);
        }
      }
      _sessionEnded();
    }
    if (response.statusCode >= 400) {
      final error = _error(response);
      if (error.isUnauthenticated && auth) _sessionEnded(error);
      throw error;
    }
    if (response.statusCode == 204 || response.body.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Never _sessionEnded([ApiException? error]) {
    tokens.clear();
    onSessionEnded?.call();
    throw error ??
        const ApiException(
            status: 401,
            code: 'unauthenticated',
            message: 'Please sign in again.');
  }

  ApiException _error(http.Response r) {
    try {
      final e = (jsonDecode(utf8.decode(r.bodyBytes))
          as Map<String, dynamic>)['error'] as Map<String, dynamic>;
      return ApiException(
        status: r.statusCode,
        code: e['code'] as String? ?? 'error',
        message: e['message'] as String? ?? 'Something went wrong',
        fields: {
          for (final f in ((e['fields'] as Map?) ?? const {}).entries)
            '${f.key}': '${f.value}',
        },
        requestId: e['request_id'] as String?,
      );
    } catch (_) {
      return ApiException(
          status: r.statusCode,
          code: 'error',
          message: 'Something went wrong (${r.statusCode})');
    }
  }

  static final _random = Random.secure();

  static String _requestId() => List.generate(
      16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

  /// A random key for one save, so a retry after a dropped connection doesn't duplicate it.
  static String newIdempotencyKey() => _requestId();
}
