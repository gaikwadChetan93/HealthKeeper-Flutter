import 'health_record.dart';
import 'sync_status.dart';

enum ArmSide {
  left('Left'),
  right('Right');

  final String displayName;
  const ArmSide(this.displayName);
}

class BloodPressure extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final int systolic;
  final int diastolic;
  final DateTime measurementDate;
  final ArmSide? armSide;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const BloodPressure({
    this.id = 0,
    required this.familyMemberId,
    required this.systolic,
    required this.diastolic,
    required this.measurementDate,
    this.armSide,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
