import 'health_record.dart';
import 'sync_status.dart';

class RadiologyResult extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final String scanType;
  final String bodyPart;
  final DateTime scanDate;
  final String? radiologyCenter;
  final String? orderedBy;
  final String? findings;
  final String? radiologistName;
  final String? reportFiles;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const RadiologyResult({
    this.id = 0,
    required this.familyMemberId,
    required this.scanType,
    required this.bodyPart,
    required this.scanDate,
    this.radiologyCenter,
    this.orderedBy,
    this.findings,
    this.radiologistName,
    this.reportFiles,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
