import 'sync_status.dart';

abstract class HealthRecord {
  const HealthRecord();

  int get id;
  int get familyMemberId;
  DateTime get createdAt;
  DateTime get updatedAt;
  SyncStatus get syncStatus;
  bool get isDeleted;
}
