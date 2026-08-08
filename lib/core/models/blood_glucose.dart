import 'health_record.dart';
import 'sync_status.dart';

enum GlucoseUnit {
  mgDl('mg/dL', 'mg/dL'),
  mmolL('mmol/L', 'mmol/L');

  final String displayName;
  final String abbreviation;
  const GlucoseUnit(this.displayName, this.abbreviation);
}

enum MealContext {
  fasting('Fasting'),
  beforeMeal('Before meal'),
  afterMeal('After meal (2 hours)'),
  bedtime('Bedtime'),
  random('Random');

  final String displayName;
  const MealContext(this.displayName);
}

class BloodGlucose extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final double glucose;
  final GlucoseUnit unit;
  final DateTime measurementDate;
  final MealContext? mealContext;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const BloodGlucose({
    this.id = 0,
    required this.familyMemberId,
    required this.glucose,
    required this.unit,
    required this.measurementDate,
    this.mealContext,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
