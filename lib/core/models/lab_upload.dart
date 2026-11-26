/// A report PDF being read by the server, from /v1/lab-uploads.

double? _d(dynamic v) => (v as num?)?.toDouble();

/// One test read from the report, waiting for the person to check it.
class ExtractedRow {
  final String testId;
  final String name;
  final String category;
  final String printedName;
  final double value;
  final String unit;
  final String printedUnit;
  final double? refLow;
  final double? refHigh;
  final String? refText;
  final List<String> issues;
  final bool needsReview;

  const ExtractedRow({
    required this.testId,
    required this.name,
    required this.category,
    required this.printedName,
    required this.value,
    required this.unit,
    required this.printedUnit,
    required this.refLow,
    required this.refHigh,
    required this.refText,
    required this.issues,
    required this.needsReview,
  });

  factory ExtractedRow.fromJson(Map<String, dynamic> j) => ExtractedRow(
        testId: j['test_id'] as String,
        name: j['name'] as String,
        category: j['category'] as String,
        printedName: j['printed_name'] as String,
        value: _d(j['value'])!,
        unit: j['unit'] as String,
        printedUnit: (j['printed_unit'] as String?) ?? '',
        refLow: _d(j['ref_low']),
        refHigh: _d(j['ref_high']),
        refText: j['ref_text'] as String?,
        issues: [
          for (final i in (j['issues'] as List? ?? const [])) i as String
        ],
        needsReview: j['needs_review'] as bool? ?? false,
      );
}

class UploadExtracted {
  final DateTime? reportDate;

  /// The name printed on the report doesn't look like this family member's.
  final bool nameMismatch;
  final String? duplicateOfReportId;
  final List<ExtractedRow> results;

  /// Lines that looked like results but whose test isn't in the list.
  final List<String> unrecognised;

  const UploadExtracted({
    required this.reportDate,
    required this.nameMismatch,
    required this.duplicateOfReportId,
    required this.results,
    required this.unrecognised,
  });

  factory UploadExtracted.fromJson(Map<String, dynamic> j) => UploadExtracted(
        reportDate: j['report_date'] == null
            ? null
            : DateTime.parse(j['report_date'] as String),
        nameMismatch: j['name_mismatch'] as bool? ?? false,
        duplicateOfReportId: j['duplicate_of_report_id'] as String?,
        results: [
          for (final r in (j['results'] as List? ?? const []))
            ExtractedRow.fromJson(r as Map<String, dynamic>)
        ],
        unrecognised: [
          for (final u in (j['unrecognised'] as List? ?? const [])) u as String
        ],
      );
}

class LabUpload {
  final String id;
  final String memberId;

  /// processing | ready | needs_password | failed | saved
  final String status;
  final String fileName;
  final String? errorCode;
  final String? errorMessage;
  final String? reportId;
  final int resultCount;
  final DateTime createdAt;
  final UploadExtracted? extracted;

  const LabUpload({
    required this.id,
    required this.memberId,
    required this.status,
    required this.fileName,
    required this.errorCode,
    required this.errorMessage,
    required this.reportId,
    required this.resultCount,
    required this.createdAt,
    required this.extracted,
  });

  bool get isProcessing => status == 'processing';

  factory LabUpload.fromJson(Map<String, dynamic> j) => LabUpload(
        id: j['id'] as String,
        memberId: j['member_id'] as String,
        status: j['status'] as String,
        fileName: j['file_name'] as String,
        errorCode: j['error_code'] as String?,
        errorMessage: j['error_message'] as String?,
        reportId: j['report_id'] as String?,
        resultCount: j['result_count'] as int? ?? 0,
        createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
        extracted: j['extracted'] == null
            ? null
            : UploadExtracted.fromJson(j['extracted'] as Map<String, dynamic>),
      );
}
