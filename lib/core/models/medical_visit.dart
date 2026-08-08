import 'health_record.dart';
import 'sync_status.dart';

enum Department {
  cardiology('Cardiology'),
  orthopedics('Orthopedics'),
  neurology('Neurology'),
  pediatrics('Pediatrics'),
  dermatology('Dermatology'),
  gynecology('Gynecology'),
  urology('Urology'),
  ent('ENT (Ear, Nose, Throat)'),
  ophthalmology('Ophthalmology'),
  dentistry('Dentistry'),
  psychiatry('Psychiatry'),
  generalMedicine('General Medicine'),
  emergency('Emergency'),
  other('Other');

  final String displayName;
  const Department(this.displayName);
}

enum PaymentMode {
  cash('Cash'),
  card('Card'),
  upi('UPI'),
  insurance('Insurance'),
  other('Other');

  final String displayName;
  const PaymentMode(this.displayName);
}

class MedicalVisit extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final DateTime visitDate;
  final String hospitalName;
  final String? doctorName;
  final Department? department;
  final String reasonForVisit;
  final String? diagnosisNotes;
  final DateTime? followUpDate;
  final String? attachments;
  final double? cost;
  final PaymentMode? paymentMode;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const MedicalVisit({
    this.id = 0,
    required this.familyMemberId,
    required this.visitDate,
    required this.hospitalName,
    this.doctorName,
    this.department,
    required this.reasonForVisit,
    this.diagnosisNotes,
    this.followUpDate,
    this.attachments,
    this.cost,
    this.paymentMode,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
