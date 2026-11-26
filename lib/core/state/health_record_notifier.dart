import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/health_record.dart';
import 'health_record_state.dart';

class HealthRecordNotifier<T extends HealthRecord>
    extends StateNotifier<HealthRecordState<T>> {
  final List<T> Function(int memberId) _mockDataLoader;
  final int memberId;

  HealthRecordNotifier({
    required List<T> Function(int memberId) mockDataLoader,
    required this.memberId,
  })  : _mockDataLoader = mockDataLoader,
        super(HealthRecordState<T>()) {
    loadRecords();
  }

  Future<void> loadRecords() async {
    state = state.copyWith(records: AsyncValue<List<T>>.loading());

    // Simulate network delay — kept at a full second so the shimmer skeleton
    // is clearly visible in the UI while there's no real backend to time
    // against; swap for the real API latency once one exists.
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      final records = _mockDataLoader(memberId);
      state = state.copyWith(records: AsyncValue.data(records));
    } catch (e, st) {
      state = state.copyWith(records: AsyncValue.error(e, st));
    }
  }

  void selectRecord(T record) {
    state = state.copyWith(currentRecord: record);
  }

  /// Inserts a genuinely new record at the top of the in-memory list.
  ///
  /// [simulateSave] intentionally just re-runs the mock loader (so it
  /// matches whatever the static seed data says) — it has no way to know
  /// the shape of a record it didn't build. Callers that construct a real
  /// typed record themselves (the vital-entry keypad does, since it knows
  /// exactly which fields it collected) should call this instead so the
  /// new reading actually shows up in the list for the rest of the session.
  void addRecord(T record) {
    final current = state.records.valueOrNull ?? const [];
    state = state.copyWith(records: AsyncValue.data([record, ...current]));
  }

  /// Removes a record from the in-memory list by id. Same rationale as
  /// [addRecord] — a real delete, not just a reload of the static mock set.
  void removeRecord(int recordId) {
    final current = state.records.valueOrNull ?? const [];
    state = state.copyWith(
      records: AsyncValue.data(current.where((r) => r.id != recordId).toList()),
    );
  }

  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }

  Future<void> simulateSave() async {
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(successMessage: 'Record saved successfully');
    await loadRecords();
  }

  Future<void> simulateDelete() async {
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(successMessage: 'Record deleted');
    await loadRecords();
  }
}
