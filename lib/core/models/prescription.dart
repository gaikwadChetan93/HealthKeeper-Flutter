import 'health_record.dart';
import 'medication.dart';
import 'sync_status.dart';

class Prescription extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final String medicationName;
  final String dosage;
  final MedicationFrequency frequency;
  final MedicationRoute route;
  final DateTime startDate;
  final DateTime? endDate;
  final String? prescribedBy;
  final String? purpose;
  final String? sideEffects;
  final String? instructions;
  final String? attachments;
  final MedicationStatus status;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const Prescription({
    this.id = 0,
    required this.familyMemberId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.route,
    required this.startDate,
    this.endDate,
    this.prescribedBy,
    this.purpose,
    this.sideEffects,
    this.instructions,
    this.attachments,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
