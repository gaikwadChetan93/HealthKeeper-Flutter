import 'package:flutter_test/flutter_test.dart';
import 'package:health_keeper/core/models/lab.dart';
import 'package:health_keeper/features/labs/lab_format.dart';

LabResultItem _r(
        {String? flag,
        String source = 'none',
        double? lo,
        double? hi,
        String enteredUnit = 'mg/dL'}) =>
    LabResultItem.fromJson({
      'id': 'r1',
      'report_id': 'p1',
      'member_id': 'm1',
      'test_id': 'glucose_fasting',
      'name': 'Fasting blood glucose',
      'category': 'Diabetes',
      'taken_on': '2026-10-15',
      'value': 99.088,
      'unit': 'mg/dL',
      'decimals': 0,
      'entered': {'value': 5.5, 'unit': enteredUnit},
      'ref_low': lo,
      'ref_high': hi,
      'flag': flag,
      'flag_label': null,
      'range_source': source,
      'range_source_text': source == 'guideline' ? 'ADA' : null,
      'version': 1,
    });

void main() {
  test('values and ranges read naturally', () {
    expect(LabFormat.value(_r()), '99.1 mg/dL');
    expect(LabFormat.number(6.10, 2), '6.1');
    expect(LabFormat.rangeText(_r(source: 'report', lo: 70, hi: 100)),
        'Report range 70–100 mg/dL');
    expect(LabFormat.rangeText(_r(source: 'report', hi: 200)),
        'Report range up to 200 mg/dL');
    expect(LabFormat.rangeText(_r(source: 'guideline')), 'Guideline: ADA');
    expect(LabFormat.rangeText(_r()), startsWith('No range'));
  });

  test('chips say where the judgement came from', () {
    expect(LabFormat.chip(_r(flag: 'high', source: 'report')), 'High');
    expect(
        LabFormat.chip(_r(flag: 'high', source: 'guideline')), 'Above range');
    expect(LabFormat.chip(_r(flag: 'borderline', source: 'guideline')),
        'Borderline');
    expect(LabFormat.chip(_r()), 'No range');
    expect(_r(flag: 'in_range').isFlagged, isFalse);
    expect(_r(flag: 'low', source: 'report').isFlagged, isTrue);
  });

  test('a value typed in another unit is shown', () {
    expect(
        LabFormat.entered(_r(enteredUnit: 'mmol/L')), 'You entered 5.5 mmol/L');
    expect(LabFormat.entered(_r()), isNull);
  });

  test('catalog search matches names labs print', () {
    final alt = LabTestDef.fromJson({
      'id': 'alt',
      'name': 'ALT (SGPT)',
      'category': 'Liver',
      'unit': 'U/L',
      'decimals': 0,
      'aliases': ['SGPT', 'Alanine aminotransferase'],
      'units': {
        'IU/L': [1, 0]
      },
    });
    expect(alt.matches('sgpt'), isTrue);
    expect(alt.matches('alanine'), isTrue);
    expect(alt.matches('tsh'), isFalse);
    expect(alt.units, ['U/L', 'IU/L']);
  });
}
