import 'health_record.dart';
import 'sync_status.dart';

enum VolumeUnit {
  milliliters('Milliliters', 'ml'),
  ounces('Fluid Ounces', 'oz');

  final String displayName;
  final String abbreviation;
  const VolumeUnit(this.displayName, this.abbreviation);
}

class Hydration extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final DateTime date;
  final double waterIntake;
  final VolumeUnit unit;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const Hydration({
    this.id = 0,
    required this.familyMemberId,
    required this.date,
    required this.waterIntake,
    required this.unit,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
