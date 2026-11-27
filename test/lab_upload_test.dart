import 'package:flutter_test/flutter_test.dart';
import 'package:health_keeper/core/models/lab.dart';
import 'package:health_keeper/core/models/lab_upload.dart';
import 'package:health_keeper/features/labs/lab_format.dart';
import 'package:health_keeper/features/labs/widgets/result_entry_card.dart';

const _mpv = LabTestDef(
  id: 'mpv',
  name: 'Mean platelet volume',
  category: 'Blood count',
  unit: 'fL',
  decimals: 1,
  aliases: ['MPV'],
  altUnits: [],
);

const _tsh = LabTestDef(
  id: 'tsh',
  name: 'TSH',
  category: 'Thyroid',
  unit: 'mIU/L',
  decimals: 2,
  aliases: [],
  altUnits: ['uIU/mL', 'µIU/mL'],
);

ExtractedRow _row(String testId, double value, String unit,
        {String printedUnit = '', bool review = false}) =>
    ExtractedRow.fromJson({
      'test_id': testId,
      'name': testId,
      'category': 'x',
      'printed_name': '* $testId',
      'value': value,
      'unit': unit,
      'printed_unit': printedUnit,
      'ref_low': 0.4,
      'ref_high': 4.2,
      'ref_text': '0.4 - 4.2',
      'issues': review ? ['unit "pg" not recognised'] : [],
      'needs_review': review,
    });

void main() {
  test('units match however the lab wrote them', () {
    expect(LabFormat.matchUnit(_tsh, 'uiu/ml'), 'uIU/mL');
    expect(LabFormat.matchUnit(_tsh, 'μIU/mL'), 'uIU/mL');
    expect(LabFormat.matchUnit(_tsh, 'mIU/L'), 'mIU/L');
    expect(LabFormat.matchUnit(_mpv, 'pg'), isNull);
  });

  test('an extracted row pre-fills the entry', () {
    final e = ResultEntry.fromExtracted(
        _tsh, _row('tsh', 5.1, 'uIU/ml', printedUnit: 'uIU/ml'));
    expect(e.value.text, '5.1');
    expect(e.low.text, '0.4');
    expect(e.high.text, '4.2');
    expect(e.unit, 'uIU/mL');
    expect(e.include, isTrue);
    expect(e.needsReview, isFalse);
    expect(e.printed, contains('0.4 - 4.2'));
  });

  test(
      'an unknown printed unit falls back to the test unit and asks for a check',
      () {
    final e = ResultEntry.fromExtracted(
        _mpv, _row('mpv', 8.5, 'fL', printedUnit: 'pg', review: true));
    expect(e.unit, 'fL');
    expect(e.needsReview, isTrue);
    expect(e.issues, contains('unit "pg" not recognised'));
  });

  test('upload status from the API', () {
    final up = LabUpload.fromJson({
      'id': 'u1',
      'member_id': 'm1',
      'status': 'ready',
      'file_name': 'report.pdf',
      'error_code': null,
      'error_message': null,
      'report_id': null,
      'result_count': 1,
      'created_at': '2026-11-26T04:30:00+00:00',
      'extracted': {
        'report_date': '2025-08-25',
        'name_mismatch': true,
        'duplicate_of_report_id': 'r9',
        'results': [
          {
            'test_id': 'tsh',
            'name': 'TSH',
            'category': 'Thyroid',
            'printed_name': 'TSH',
            'value': 5.1,
            'unit': 'uIU/mL',
            'printed_unit': 'uIU/mL',
            'ref_low': null,
            'ref_high': null,
            'ref_text': null,
            'issues': [],
            'needs_review': true
          },
        ],
        'unrecognised': ['Mystery Marker  12 U/mL'],
      },
    });
    expect(up.isProcessing, isFalse);
    expect(up.extracted!.reportDate, DateTime(2025, 8, 25));
    expect(up.extracted!.nameMismatch, isTrue);
    expect(up.extracted!.duplicateOfReportId, 'r9');
    expect(up.extracted!.results.single.needsReview, isTrue);
    expect(up.extracted!.unrecognised.single, contains('Mystery'));
  });
}
