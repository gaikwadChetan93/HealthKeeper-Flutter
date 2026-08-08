enum SyncStatus {
  synced('Synced'),
  pending('Pending'),
  failed('Failed');

  final String displayName;
  const SyncStatus(this.displayName);
}
