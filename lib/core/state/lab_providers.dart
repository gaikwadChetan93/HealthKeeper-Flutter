import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../auth/auth_controller.dart';
import '../models/lab.dart';

/// The list of tests the app offers. Not personal; loaded once per app run.
final labCatalogProvider = FutureProvider<LabCatalog>((ref) async {
  return LabCatalog.fromJson(await ref
      .read(apiClientProvider)
      .get('/v1/lab-tests') as Map<String, dynamic>);
});

/// Latest result of every test a member has, grouped by panel.
final labSummaryProvider = FutureProvider.autoDispose
    .family<List<LabTestSummary>, String>((ref, memberId) async {
  final data = await ref
      .read(apiClientProvider)
      .get('/v1/members/$memberId/lab-tests/summary') as Map<String, dynamic>;
  return [
    for (final t in data['tests'] as List)
      LabTestSummary.fromJson(t as Map<String, dynamic>)
  ];
});

/// A member's lab reports, newest first (without their results).
final labReportsProvider = FutureProvider.autoDispose
    .family<List<LabReport>, String>((ref, memberId) async {
  final data = await ref
          .read(apiClientProvider)
          .get('/v1/members/$memberId/lab-reports', query: {'limit': '100'})
      as Map<String, dynamic>;
  return [
    for (final r in data['items'] as List)
      LabReport.fromJson(r as Map<String, dynamic>, memberId: memberId)
  ];
});

final labReportProvider =
    FutureProvider.autoDispose.family<LabReport, String>((ref, id) async {
  return LabReport.fromJson(await ref
      .read(apiClientProvider)
      .get('/v1/lab-reports/$id') as Map<String, dynamic>);
});

typedef LabSeriesKey = ({String memberId, String testId});

final labSeriesProvider = FutureProvider.autoDispose
    .family<LabSeries, LabSeriesKey>((ref, key) async {
  return LabSeries.fromJson(await ref
          .read(apiClientProvider)
          .get('/v1/members/${key.memberId}/lab-tests/'
              '${Uri.encodeComponent(key.testId)}/series')
      as Map<String, dynamic>);
});

/// One result being typed in.
class LabResultDraft {
  final String testId;

  /// For a custom test (not in the catalog): its name, sent instead of [testId].
  final String? customName;
  final double value;
  final String unit;
  final double? refLow;
  final double? refHigh;

  LabResultDraft.of(LabTestDef test,
      {required this.value, required this.unit, this.refLow, this.refHigh})
      : testId = test.id,
        customName = test.isCustom ? test.name : null;

  const LabResultDraft(
      {required this.testId,
      this.customName,
      required this.value,
      required this.unit,
      this.refLow,
      this.refHigh});

  Map<String, dynamic> toJson() => {
        if (customName != null) 'name': customName else 'test_id': testId,
        'value': value,
        'unit': unit,
        if (refLow != null) 'ref_low': refLow,
        if (refHigh != null) 'ref_high': refHigh,
      };
}

final labActionsProvider = Provider((ref) => LabActions(ref));

/// Saving and changing lab results; refreshes the screens that show them.
class LabActions {
  final Ref _ref;
  const LabActions(this._ref);

  ApiClient get _api => _ref.read(apiClientProvider);

  Future<LabReport> createReport(String memberId,
      {required DateTime date,
      String? labName,
      required List<LabResultDraft> results,
      required String idempotencyKey}) async {
    final data = await _api.post('/v1/members/$memberId/lab-reports',
        idempotencyKey: idempotencyKey,
        body: {
          'report_date': date.toIso8601String().substring(0, 10),
          if (labName != null && labName.trim().isNotEmpty)
            'lab_name': labName.trim(),
          'results': [for (final r in results) r.toJson()],
        }) as Map<String, dynamic>;
    _changed(memberId);
    return LabReport.fromJson(data);
  }

  /// Sends the value with its unit and the report's range (null clears it).
  Future<void> updateResult(LabResultItem r,
      {required double value,
      required String unit,
      double? refLow,
      double? refHigh}) async {
    await _api.patch('/v1/lab-results/${r.id}', version: r.version, body: {
      'value': value,
      'unit': unit,
      'ref_low': refLow,
      'ref_high': refHigh
    });
    _changed(r.memberId, reportId: r.reportId);
  }

  Future<void> deleteResult(LabResultItem r) async {
    await _api.delete('/v1/lab-results/${r.id}');
    _changed(r.memberId, reportId: r.reportId);
  }

  Future<void> deleteReport(LabReport report) async {
    await _api.delete('/v1/lab-reports/${report.id}');
    _changed(report.memberId);
  }

  Future<void> suggestTest(String name, {String? unit, String? note}) async {
    await _api.post('/v1/lab-test-suggestions', body: {
      'name': name.trim(),
      if (unit != null && unit.trim().isNotEmpty) 'unit': unit.trim(),
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });
  }

  void _changed(String memberId, {String? reportId}) {
    _ref.invalidate(labSummaryProvider(memberId));
    _ref.invalidate(labReportsProvider(memberId));
    _ref.invalidate(labSeriesProvider);
    if (reportId != null) _ref.invalidate(labReportProvider(reportId));
  }
}
