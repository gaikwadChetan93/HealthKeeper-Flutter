import 'health_record.dart';
import 'sync_status.dart';

class Surgery extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final String surgeryName;
  final DateTime surgeryDate;
  final String? hospital;
  final String? surgeon;
  final String? reason;
  final String? complications;
  final String? documents;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const Surgery({
    this.id = 0,
    required this.familyMemberId,
    required this.surgeryName,
    required this.surgeryDate,
    this.hospital,
    this.surgeon,
    this.reason,
    this.complications,
    this.documents,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
