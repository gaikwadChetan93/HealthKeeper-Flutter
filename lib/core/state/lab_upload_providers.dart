import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../auth/auth_controller.dart';
import '../models/lab.dart';
import '../models/lab_upload.dart';
import 'lab_providers.dart';

/// One upload, re-checked until the server has finished reading it.
final labUploadProvider =
    StreamProvider.autoDispose.family<LabUpload, String>((ref, id) async* {
  final api = ref.read(apiClientProvider);
  var wait = const Duration(milliseconds: 800);
  while (true) {
    final up = LabUpload.fromJson(
        await api.get('/v1/lab-uploads/$id') as Map<String, dynamic>);
    yield up;
    if (!up.isProcessing) return;
    await Future<void>.delayed(wait);
    if (wait < const Duration(seconds: 3)) wait *= 1.5;
  }
});

/// Uploads not yet saved (reading, ready to review, needing a password, or failed).
/// Refreshes itself while any is still being read.
final labUploadsProvider = FutureProvider.autoDispose
    .family<List<LabUpload>, String>((ref, memberId) async {
  final data = await ref
      .read(apiClientProvider)
      .get('/v1/members/$memberId/lab-uploads') as Map<String, dynamic>;
  final items = [
    for (final u in data['items'] as List)
      LabUpload.fromJson(u as Map<String, dynamic>)
  ];
  if (items.any((u) => u.isProcessing)) {
    final t = Timer(const Duration(seconds: 3), ref.invalidateSelf);
    ref.onDispose(t.cancel);
  }
  return items;
});

final labUploadActionsProvider = Provider((ref) => LabUploadActions(ref));

class LabUploadActions {
  final Ref _ref;
  const LabUploadActions(this._ref);

  ApiClient get _api => _ref.read(apiClientProvider);

  Future<LabUpload> upload(
      String memberId, List<int> bytes, String fileName) async {
    final data = await _api.upload('/v1/members/$memberId/lab-uploads',
        bytes: bytes,
        filename: fileName,
        contentType: 'application/pdf',
        idempotencyKey: ApiClient.newIdempotencyKey()) as Map<String, dynamic>;
    _ref.invalidate(labUploadsProvider(memberId));
    return LabUpload.fromJson(data);
  }

  /// The password goes to the server once to open the PDF; it is never stored.
  Future<void> unlock(LabUpload up, String password) async {
    await _api.post('/v1/lab-uploads/${up.id}/password',
        body: {'password': password});
    _ref.invalidate(labUploadProvider(up.id));
  }

  Future<LabReport> confirm(LabUpload up,
      {required DateTime date,
      String? labName,
      required List<LabResultDraft> results}) async {
    final data = await _api.post('/v1/lab-uploads/${up.id}/confirm', body: {
      'report_date': date.toIso8601String().substring(0, 10),
      if (labName != null && labName.trim().isNotEmpty)
        'lab_name': labName.trim(),
      'results': [for (final r in results) r.toJson()],
    }) as Map<String, dynamic>;
    _changed(up);
    return LabReport.fromJson(data);
  }

  Future<void> discard(LabUpload up) async {
    await _api.delete('/v1/lab-uploads/${up.id}');
    _changed(up);
  }

  void _changed(LabUpload up) {
    _ref.invalidate(labUploadsProvider(up.memberId));
    _ref.invalidate(labUploadProvider(up.id));
    _ref.invalidate(labSummaryProvider(up.memberId));
    _ref.invalidate(labReportsProvider(up.memberId));
    _ref.invalidate(labSeriesProvider);
  }
}
