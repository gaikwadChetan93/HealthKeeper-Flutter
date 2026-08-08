import 'health_record.dart';
import 'sync_status.dart';

class Vaccine extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final String vaccineName;
  final DateTime vaccineDate;
  final int? doseNumber;
  final String? lotNumber;
  final String? administeredBy;
  final String? location;
  final DateTime? nextDueDate;
  final String? certificate;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const Vaccine({
    this.id = 0,
    required this.familyMemberId,
    required this.vaccineName,
    required this.vaccineDate,
    this.doseNumber,
    this.lotNumber,
    this.administeredBy,
    this.location,
    this.nextDueDate,
    this.certificate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
