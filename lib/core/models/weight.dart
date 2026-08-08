import 'health_record.dart';
import 'sync_status.dart';

enum WeightUnit {
  kilograms('Kilograms', 'kg'),
  pounds('Pounds', 'lbs');

  final String displayName;
  final String abbreviation;
  const WeightUnit(this.displayName, this.abbreviation);
}

class Weight extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final double weight;
  final WeightUnit unit;
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

  const Weight({
    this.id = 0,
    required this.familyMemberId,
    required this.weight,
    required this.unit,
    required this.measurementDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
