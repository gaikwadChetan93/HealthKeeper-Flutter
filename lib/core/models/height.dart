import 'health_record.dart';
import 'sync_status.dart';

enum HeightUnit {
  centimeters('Centimeters', 'cm'),
  feetInches('Feet & Inches', 'ft-in');

  final String displayName;
  final String abbreviation;
  const HeightUnit(this.displayName, this.abbreviation);
}

class Height extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final double height;
  final HeightUnit unit;
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

  const Height({
    this.id = 0,
    required this.familyMemberId,
    required this.height,
    required this.unit,
    required this.measurementDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
