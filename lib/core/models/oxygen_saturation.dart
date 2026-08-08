import 'health_record.dart';
import 'sync_status.dart';

class OxygenSaturation extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final double spO2;
  final DateTime measurementDate;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const OxygenSaturation({
    this.id = 0,
    required this.familyMemberId,
    required this.spO2,
    required this.measurementDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
