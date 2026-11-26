/// An error from the API, parsed from {"error": {code, message, fields, request_id}}.
class ApiException implements Exception {
  final int status;
  final String code;
  final String message;

  /// Field name -> problem, e.g. {"payload.systolic": "must be a number"}.
  final Map<String, String> fields;
  final String? requestId;

  const ApiException({
    required this.status,
    required this.code,
    required this.message,
    this.fields = const {},
    this.requestId,
  });

  factory ApiException.network() => const ApiException(
        status: 0,
        code: 'network',
        message: 'Can’t reach Health Keeper. Check your internet connection.',
      );

  bool get isUnauthenticated => status == 401;
  bool get isConflict => status == 409;
  bool get isValidation => status == 422;

  /// Form field errors with the "payload." prefix removed.
  Map<String, String> get formFieldErrors => {
        for (final e in fields.entries)
          e.key.replaceFirst('payload.', ''): e.value,
      };

  @override
  String toString() => message;
}
