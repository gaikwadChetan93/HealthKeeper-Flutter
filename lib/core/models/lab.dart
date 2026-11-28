/// Lab tests and results from the API's /lab-* endpoints.

double? _d(dynamic v) => (v as num?)?.toDouble();

/// A guideline cut-off band, e.g. HbA1c 5.7–6.5 % "Borderline".
class GuidelineBand {
  final String level;
  final String label;
  final double? min;
  final double? max;

  const GuidelineBand(
      {required this.level, required this.label, this.min, this.max});

  factory GuidelineBand.fromJson(Map<String, dynamic> j) => GuidelineBand(
        level: j['level'] as String,
        label: j['label'] as String,
        min: _d(j['min']),
        max: _d(j['max']),
      );
}

class Guideline {
  final String source;
  final String? note;
  final List<GuidelineBand> bands;

  const Guideline({required this.source, required this.bands, this.note});

  static Guideline? fromJson(Map<String, dynamic>? j) => j == null
      ? null
      : Guideline(
          source: j['source'] as String,
          note: j['note'] as String?,
          bands: [
            for (final b in j['bands'] as List)
              GuidelineBand.fromJson(b as Map<String, dynamic>)
          ],
        );
}

/// Plain-language note about a test: the same for everyone, not about anyone's result.
class LabTestAbout {
  final String what;
  final String why;

  /// What a result above the range can be seen with; null when there's nothing useful to say.
  final String? high;
  final String? low;

  const LabTestAbout(
      {required this.what, required this.why, this.high, this.low});

  static LabTestAbout? fromJson(Map<String, dynamic>? j) => j == null
      ? null
      : LabTestAbout(
          what: j['what'] as String,
          why: j['why'] as String,
          high: j['high'] as String?,
          low: j['low'] as String?,
        );
}

/// A test in the catalog the app offers.
class LabTestDef {
  final String id;
  final String name;
  final String category;
  final String unit;
  final int decimals;
  final List<String> aliases;

  /// Other units a value may be typed in (the stored [unit] is always allowed).
  final List<String> altUnits;
  final Guideline? guideline;
  final LabTestAbout? about;

  /// Not in the catalog: saved under the person's own name for it, with any unit,
  /// exactly as typed. The server gives it an id from its name and unit.
  final bool isCustom;

  const LabTestDef({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.decimals,
    required this.aliases,
    required this.altUnits,
    this.guideline,
    this.about,
    this.isCustom = false,
  });

  /// Shown under this category, as the server files custom tests.
  static const customCategory = 'Added by you';

  factory LabTestDef.custom(String name, {String unit = ''}) => LabTestDef(
        id: '',
        name: name.trim().replaceAll(RegExp(r'\s+'), ' '),
        category: customCategory,
        unit: unit.trim(),
        decimals: 3,
        aliases: const [],
        altUnits: const [],
        isCustom: true,
      );

  List<String> get units => [unit, ...altUnits.where((u) => u != unit)];

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        aliases.any((a) => a.toLowerCase().contains(q));
  }

  factory LabTestDef.fromJson(Map<String, dynamic> j) => LabTestDef(
        id: j['id'] as String,
        name: j['name'] as String,
        category: j['category'] as String,
        unit: j['unit'] as String,
        decimals: (j['decimals'] as num?)?.toInt() ?? 1,
        aliases: [
          for (final a in (j['aliases'] as List? ?? const [])) a as String
        ],
        altUnits: [
          for (final u in ((j['units'] as Map?) ?? const {}).keys) u as String
        ],
        guideline: Guideline.fromJson(j['guideline'] as Map<String, dynamic>?),
        about: LabTestAbout.fromJson(j['about'] as Map<String, dynamic>?),
      );
}

class LabCatalog {
  final List<String> categories;
  final List<LabTestDef> tests;

  const LabCatalog({required this.categories, required this.tests});

  LabTestDef? byId(String id) => tests.where((t) => t.id == id).firstOrNull;

  factory LabCatalog.fromJson(Map<String, dynamic> j) => LabCatalog(
        categories: [for (final c in j['categories'] as List) c as String],
        tests: [
          for (final t in j['tests'] as List)
            LabTestDef.fromJson(t as Map<String, dynamic>)
        ],
      );
}

class LabResultItem {
  final String id;
  final String reportId;
  final String memberId;
  final String testId;
  final String name;
  final String category;
  final DateTime takenOn;
  final double value;
  final String unit;
  final int decimals;
  final double enteredValue;
  final String enteredUnit;
  final double? refLow;
  final double? refHigh;

  /// low | in_range | borderline | high, or null when there was no range to compare with.
  final String? flag;
  final String? flagLabel;

  /// report | guideline | none
  final String rangeSource;
  final String? rangeSourceText;
  final int version;

  /// A test the person named themselves (not in the catalog).
  final bool isCustom;

  const LabResultItem({
    required this.id,
    required this.reportId,
    required this.memberId,
    required this.testId,
    required this.name,
    required this.category,
    required this.takenOn,
    required this.value,
    required this.unit,
    required this.decimals,
    required this.enteredValue,
    required this.enteredUnit,
    required this.refLow,
    required this.refHigh,
    required this.flag,
    required this.flagLabel,
    required this.rangeSource,
    required this.rangeSourceText,
    required this.version,
    this.isCustom = false,
  });

  bool get isFlagged => flag == 'low' || flag == 'high' || flag == 'borderline';

  factory LabResultItem.fromJson(Map<String, dynamic> j) => LabResultItem(
        id: j['id'] as String,
        reportId: j['report_id'] as String,
        memberId: j['member_id'] as String,
        testId: j['test_id'] as String,
        name: j['name'] as String,
        category: j['category'] as String,
        takenOn: DateTime.parse(j['taken_on'] as String),
        value: _d(j['value'])!,
        unit: j['unit'] as String,
        decimals: (j['decimals'] as num?)?.toInt() ?? 1,
        enteredValue: _d((j['entered'] as Map)['value'])!,
        enteredUnit: (j['entered'] as Map)['unit'] as String,
        refLow: _d(j['ref_low']),
        refHigh: _d(j['ref_high']),
        flag: j['flag'] as String?,
        flagLabel: j['flag_label'] as String?,
        rangeSource: j['range_source'] as String,
        rangeSourceText: j['range_source_text'] as String?,
        version: j['version'] as int,
        isCustom: j['custom'] as bool? ?? false,
      );
}

class LabReport {
  final String id;
  final String memberId;
  final DateTime reportDate;
  final String? labName;
  final String? notes;
  final int resultCount;
  final int flaggedCount;
  final int version;
  final List<LabResultItem> results;

  const LabReport({
    required this.id,
    required this.memberId,
    required this.reportDate,
    required this.labName,
    required this.notes,
    required this.resultCount,
    required this.flaggedCount,
    required this.version,
    required this.results,
  });

  factory LabReport.fromJson(Map<String, dynamic> j, {String? memberId}) =>
      LabReport(
        id: j['id'] as String,
        memberId: (j['member_id'] as String?) ?? memberId ?? '',
        reportDate: DateTime.parse(j['report_date'] as String),
        labName: j['lab_name'] as String?,
        notes: j['notes'] as String?,
        resultCount: j['result_count'] as int,
        flaggedCount: j['flagged_count'] as int,
        version: j['version'] as int,
        results: [
          for (final r in (j['results'] as List? ?? const []))
            LabResultItem.fromJson(r as Map<String, dynamic>),
        ],
      );
}

/// One test on the member's "By test" list.
class LabTestSummary {
  final String testId;
  final String name;
  final String category;
  final int count;
  final LabResultItem latest;
  final double? previousValue;

  const LabTestSummary({
    required this.testId,
    required this.name,
    required this.category,
    required this.count,
    required this.latest,
    required this.previousValue,
  });

  factory LabTestSummary.fromJson(Map<String, dynamic> j) => LabTestSummary(
        testId: j['test_id'] as String,
        name: j['name'] as String,
        category: j['category'] as String,
        count: j['count'] as int,
        latest: LabResultItem.fromJson(j['latest'] as Map<String, dynamic>),
        previousValue: _d((j['previous'] as Map?)?['value']),
      );
}

/// All results of one test, oldest first.
class LabSeries {
  final String testId;
  final String name;
  final String unit;
  final int decimals;
  final Guideline? guideline;
  final LabTestAbout? about;
  final List<LabResultItem> points;

  const LabSeries({
    required this.testId,
    required this.name,
    required this.unit,
    required this.decimals,
    required this.guideline,
    this.about,
    required this.points,
  });

  factory LabSeries.fromJson(Map<String, dynamic> j) {
    final t = j['test'] as Map<String, dynamic>;
    return LabSeries(
      testId: t['id'] as String,
      name: t['name'] as String,
      unit: t['unit'] as String,
      decimals: (t['decimals'] as num?)?.toInt() ?? 1,
      guideline: Guideline.fromJson(t['guideline'] as Map<String, dynamic>?),
      about: LabTestAbout.fromJson(t['about'] as Map<String, dynamic>?),
      points: [
        for (final p in j['points'] as List)
          LabResultItem.fromJson(p as Map<String, dynamic>)
      ],
    );
  }
}
