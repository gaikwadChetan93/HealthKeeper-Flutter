import 'health_record.dart';
import 'sync_status.dart';

enum MedicalConditionStatus {
  active('Active'),
  resolved('Resolved'),
  inRemission('In Remission'),
  chronic('Chronic');

  final String displayName;
  const MedicalConditionStatus(this.displayName);
}

class MedicalHistory extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final String condition;
  final DateTime diagnosedDate;
  final MedicalConditionStatus status;
  final String? treatedBy;
  final String? treatment;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const MedicalHistory({
    this.id = 0,
    required this.familyMemberId,
    required this.condition,
    required this.diagnosedDate,
    required this.status,
    this.treatedBy,
    this.treatment,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
