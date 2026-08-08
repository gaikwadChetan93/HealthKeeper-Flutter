import 'health_record.dart';
import 'sync_status.dart';

enum ActivityContext {
  resting('Resting'),
  lightActivity('Light activity'),
  moderateExercise('Moderate exercise'),
  intenseExercise('Intense exercise');

  final String displayName;
  const ActivityContext(this.displayName);
}

class HeartRate extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final int bpm;
  final DateTime measurementDate;
  final ActivityContext? activityContext;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const HeartRate({
    this.id = 0,
    required this.familyMemberId,
    required this.bpm,
    required this.measurementDate,
    this.activityContext,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
