import 'health_record.dart';
import 'sync_status.dart';

enum ExerciseType {
  walking('Walking'),
  running('Running'),
  cycling('Cycling'),
  swimming('Swimming'),
  gym('Gym/Weights'),
  yoga('Yoga'),
  sports('Sports'),
  other('Other');

  final String displayName;
  const ExerciseType(this.displayName);
}

enum DistanceUnit {
  kilometers('Kilometers', 'km'),
  miles('Miles', 'miles');

  final String displayName;
  final String abbreviation;
  const DistanceUnit(this.displayName, this.abbreviation);
}

class Exercise extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final DateTime exerciseDate;
  final ExerciseType activityType;
  final int duration; // minutes
  final double? distance;
  final DistanceUnit? distanceUnit;
  final int? calories;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const Exercise({
    this.id = 0,
    required this.familyMemberId,
    required this.exerciseDate,
    required this.activityType,
    required this.duration,
    this.distance,
    this.distanceUnit,
    this.calories,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
