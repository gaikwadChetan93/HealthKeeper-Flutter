import 'package:flutter_test/flutter_test.dart';
import 'package:health_keeper/core/config/module_registry.dart';
import 'package:health_keeper/core/models/record_item.dart';
import 'package:health_keeper/core/records/record_format.dart';

RecordItem _record(String module, Map<String, dynamic> payload) => RecordItem(
      id: 'r1',
      memberId: 'm1',
      module: module,
      recordDate: DateTime(2026, 11, 1),
      payload: payload,
      version: 1,
      createdAt: DateTime(2026, 11, 1),
      updatedAt: DateTime(2026, 11, 1),
    );

void main() {
  final bp = ModuleRegistry.getModuleByKey('blood_pressure')!;
  final weight = ModuleRegistry.getModuleByKey('weight')!;
  final appointment = ModuleRegistry.getModuleByKey('appointment')!;

  test('form values become an API payload', () {
    final when = DateTime(2026, 11, 1, 8, 30);
    final payload = RecordFormat.toPayload(bp, {
      'systolic': '128',
      'diastolic': ' 84 ',
      'measurementDate': when,
      'notes': '   ',
    });
    expect(payload['systolic'], 128);
    expect(payload['diastolic'], 84);
    expect(payload['measurementDate'], when.toUtc().toIso8601String());
    // Empty fields are sent as null so an edit can clear them.
    expect(payload.containsKey('notes'), isTrue);
    expect(payload['notes'], isNull);
  });

  test('measurements are sent with the default unit', () {
    final payload = RecordFormat.toPayload(weight, {'weight': '65,5'});
    expect(payload['weight'], {'value': 65.5, 'unit': 'kg'});
  });

  test('dates and times use the formats the API stores', () {
    final payload = RecordFormat.toPayload(appointment, {
      'appointmentDate': DateTime(2026, 12, 3),
      'appointmentTime': '09:05',
    });
    expect(payload['appointmentDate'], '2026-12-03');
    expect(payload['appointmentTime'], '09:05');
  });

  test('a stored record goes back into the form for editing', () {
    final form = RecordFormat.toForm(weight, {
      'weight': {'value': 69.85, 'unit': 'kg', 'entered': {'value': 154, 'unit': 'lbs'}},
      'measurementDate': '2026-11-20T08:00:00+00:00',
    });
    expect(form['weight'], '69.85');
    expect(form['measurementDate'], DateTime.utc(2026, 11, 20, 8).toLocal());
  });

  test('list titles and details read the payload', () {
    final r = _record('blood_pressure', {'systolic': 120, 'diastolic': 80, 'armSide': 'LEFT'});
    expect(RecordFormat.title(bp, r), '120/80 mmHg');
    final w = _record('weight', {
      'weight': {'value': 69.85, 'unit': 'kg', 'entered': {'value': 154, 'unit': 'lbs'}},
    });
    expect(RecordFormat.title(weight, w), '69.85 kg (entered 154 lbs)');
  });
}
