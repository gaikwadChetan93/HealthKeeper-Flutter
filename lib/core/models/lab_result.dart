import 'health_record.dart';
import 'sync_status.dart';

class LabResult extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final String testName;
  final DateTime testDate;
  final String result;
  final String? normalRange;
  final String? unit;
  final String? labName;
  final String? orderedBy;
  final String? reportFile;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const LabResult({
    this.id = 0,
    required this.familyMemberId,
    required this.testName,
    required this.testDate,
    required this.result,
    this.normalRange,
    this.unit,
    this.labName,
    this.orderedBy,
    this.reportFile,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
