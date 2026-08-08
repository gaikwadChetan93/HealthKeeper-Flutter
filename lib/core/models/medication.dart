import 'health_record.dart';
import 'sync_status.dart';

enum MedicationSourceType {
  prescription('Prescription'),
  otc('Over-the-Counter'),
  supplement('Supplement/Vitamin'),
  other('Other');

  final String displayName;
  const MedicationSourceType(this.displayName);
}

enum MedicationFrequency {
  onceDaily('Once daily'),
  twiceDaily('Twice daily'),
  thriceDaily('Thrice daily'),
  fourTimesDaily('Four times daily'),
  asNeeded('As needed'),
  everyOtherDay('Every other day'),
  weekly('Weekly'),
  monthly('Monthly');

  final String displayName;
  const MedicationFrequency(this.displayName);
}

enum MedicationRoute {
  oral('Oral'),
  topical('Topical'),
  injection('Injection'),
  inhalation('Inhalation'),
  sublingual('Sublingual'),
  rectal('Rectal'),
  transdermal('Transdermal'),
  other('Other');

  final String displayName;
  const MedicationRoute(this.displayName);
}

enum MedicationStatus {
  active('Active'),
  completed('Completed'),
  stopped('Stopped'),
  onHold('On Hold');

  final String displayName;
  const MedicationStatus(this.displayName);
}

class Medication extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final String medicationName;
  final MedicationSourceType sourceType;
  final String dosage;
  final MedicationFrequency frequency;
  final MedicationRoute route;
  final DateTime startDate;
  final DateTime? endDate;
  final MedicationStatus status;
  final String? attachments;
  final String? prescribedBy;
  final String? purpose;
  final String? sideEffects;
  final String? instructions;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const Medication({
    this.id = 0,
    required this.familyMemberId,
    required this.medicationName,
    required this.sourceType,
    required this.dosage,
    required this.frequency,
    required this.route,
    required this.startDate,
    this.endDate,
    required this.status,
    this.attachments,
    this.prescribedBy,
    this.purpose,
    this.sideEffects,
    this.instructions,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
