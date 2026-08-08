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
        super(const HealthRecordState()) {
    loadRecords();
  }

  Future<void> loadRecords() async {
    state = state.copyWith(records: const AsyncValue.loading());

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

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
