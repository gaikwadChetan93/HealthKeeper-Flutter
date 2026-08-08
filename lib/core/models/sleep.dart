import 'health_record.dart';
import 'sync_status.dart';

enum SleepQuality {
  poor('Poor'),
  fair('Fair'),
  good('Good'),
  excellent('Excellent');

  final String displayName;
  const SleepQuality(this.displayName);
}

class SleepRecord extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final DateTime sleepDate;
  final double hoursSlept;
  final SleepQuality? quality;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const SleepRecord({
    this.id = 0,
    required this.familyMemberId,
    required this.sleepDate,
    required this.hoursSlept,
    this.quality,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
