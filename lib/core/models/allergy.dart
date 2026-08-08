import 'health_record.dart';
import 'sync_status.dart';

enum AllergyType {
  food('Food Allergy'),
  drug('Drug/Medication'),
  environmental('Environmental'),
  insect('Insect Sting'),
  other('Other');

  final String displayName;
  const AllergyType(this.displayName);
}

enum AllergySeverity {
  mild('Mild'),
  moderate('Moderate'),
  severe('Severe/Life-threatening');

  final String displayName;
  const AllergySeverity(this.displayName);
}

class Allergy extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final String allergen;
  final AllergyType reactionType;
  final AllergySeverity severity;
  final DateTime diagnosedDate;
  final String? symptoms;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const Allergy({
    this.id = 0,
    required this.familyMemberId,
    required this.allergen,
    required this.reactionType,
    required this.severity,
    required this.diagnosedDate,
    this.symptoms,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
