/// A doctor the family sees, from /v1/doctors. Shared by every family member.
class Doctor {
  final String id;
  final String name;
  final String? speciality;
  final String? phone;
  final String? clinic;
  final String? notes;

  /// How many records are linked to this doctor, and the latest one's date.
  final int recordCount;
  final DateTime? lastRecordDate;
  final int version;

  const Doctor({
    required this.id,
    required this.name,
    this.speciality,
    this.phone,
    this.clinic,
    this.notes,
    this.recordCount = 0,
    this.lastRecordDate,
    required this.version,
  });

  /// "Cardiologist · City Clinic"
  String get subtitle => [speciality, clinic].whereType<String>().join(' · ');

  factory Doctor.fromJson(Map<String, dynamic> j) => Doctor(
        id: j['id'] as String,
        name: j['name'] as String,
        speciality: j['speciality'] as String?,
        phone: j['phone'] as String?,
        clinic: j['clinic'] as String?,
        notes: j['notes'] as String?,
        recordCount: j['record_count'] as int? ?? 0,
        lastRecordDate: j['last_record_date'] == null
            ? null
            : DateTime.parse(j['last_record_date'] as String).toLocal(),
        version: j['version'] as int,
      );

  static const specialities = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Diabetologist',
    'Endocrinologist',
    'ENT Specialist',
    'Gastroenterologist',
    'Gynecologist',
    'Nephrologist',
    'Neurologist',
    'Oncologist',
    'Ophthalmologist',
    'Orthopedic',
    'Pediatrician',
    'Psychiatrist',
    'Pulmonologist',
    'Urologist',
    'Dentist',
  ];
}
