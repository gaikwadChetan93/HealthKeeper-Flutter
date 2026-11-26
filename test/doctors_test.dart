import 'package:flutter_test/flutter_test.dart';
import 'package:health_keeper/core/models/doctor.dart';
import 'package:health_keeper/core/models/record_item.dart';
import 'package:health_keeper/core/records/doctor_fields.dart';

void main() {
  test('doctor from the API', () {
    final d = Doctor.fromJson({
      'id': 'd1',
      'name': 'Dr. Anita Desai',
      'speciality': 'Cardiologist',
      'phone': '+91 98765 43210',
      'clinic': 'City Clinic',
      'notes': null,
      'record_count': 3,
      'last_record_date': '2026-10-05T10:00:00+00:00',
      'version': 2,
    });
    expect(d.subtitle, 'Cardiologist · City Clinic');
    expect(d.recordCount, 3);
    expect(d.lastRecordDate, DateTime.utc(2026, 10, 5, 10).toLocal());
    expect(
        Doctor.fromJson({'id': 'd2', 'name': 'Dr. B', 'version': 1}).subtitle,
        '');
  });

  test('records carry the linked doctor', () {
    final r = RecordItem.fromJson({
      'id': 'r1',
      'member_id': 'm1',
      'module': 'medical_visit',
      'record_date': '2026-10-01T10:00:00+00:00',
      'payload': {'doctorName': 'Dr. Anita Desai'},
      'doctor_id': 'd1',
      'version': 1,
      'created_at': '2026-10-01T10:00:00+00:00',
      'updated_at': '2026-10-01T10:00:00+00:00',
    });
    expect(r.doctorId, 'd1');
    expect(doctorFields['medical_visit'], 'doctorName');
    expect(doctorFields['weight'], isNull);
  });
}
