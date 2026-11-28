/// A report (PDF or photo) being read by the server, from /v1/lab-uploads.

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

  /// The same lines with what was read from them, to save as custom tests.
  /// Empty from older servers, which only sent the text.
  final List<UnrecognisedRow> unrecognisedRows;

  /// "digital", "scan" or "mixed": values from scanned pages were read with
  /// OCR and are all marked to check.
  final String source;

  bool get fromScan => source != 'digital';

  const UploadExtracted({
    this.source = 'digital',
    required this.reportDate,
    required this.nameMismatch,
    required this.duplicateOfReportId,
    required this.results,
    required this.unrecognised,
    this.unrecognisedRows = const [],
  });

  factory UploadExtracted.fromJson(Map<String, dynamic> j) => UploadExtracted(
        reportDate: j['report_date'] == null
            ? null
            : DateTime.parse(j['report_date'] as String),
        nameMismatch: j['name_mismatch'] as bool? ?? false,
        source: j['source'] as String? ?? 'digital',
        duplicateOfReportId: j['duplicate_of_report_id'] as String?,
        results: [
          for (final r in (j['results'] as List? ?? const []))
            ExtractedRow.fromJson(r as Map<String, dynamic>)
        ],
        unrecognised: [
          for (final u in (j['unrecognised'] as List? ?? const [])) u as String
        ],
        unrecognisedRows: [
          for (final u in (j['unrecognised_rows'] as List? ?? const []))
            UnrecognisedRow.fromJson(u as Map<String, dynamic>)
        ],
      );
}

/// A line that reads like a result for a test that isn't in the list.
class UnrecognisedRow {
  final String printedName;
  final double value;
  final String unit;
  final double? refLow;
  final double? refHigh;
  final String? refText;

  /// Read from a scanned page with OCR: to be checked against the report.
  final bool scanned;

  const UnrecognisedRow({
    required this.printedName,
    required this.value,
    required this.unit,
    this.refLow,
    this.refHigh,
    this.refText,
    this.scanned = false,
  });

  /// As shown in the list: "Mystery Marker  12 U/mL".
  String get text =>
      '$printedName  ${value == value.roundToDouble() ? value.toInt() : value} $unit';

  factory UnrecognisedRow.fromJson(Map<String, dynamic> j) => UnrecognisedRow(
        printedName: j['printed_name'] as String,
        value: (j['value'] as num).toDouble(),
        unit: j['unit'] as String? ?? '',
        refLow: (j['ref_low'] as num?)?.toDouble(),
        refHigh: (j['ref_high'] as num?)?.toDouble(),
        refText: j['ref_text'] as String?,
        scanned: j['scanned'] as bool? ?? false,
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
