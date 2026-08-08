import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/health_record.dart';

class HealthRecordState<T extends HealthRecord> {
  final AsyncValue<List<T>> records;
  final T? currentRecord;
  final String? successMessage;

  const HealthRecordState({
    this.records = const AsyncValue.loading(),
    this.currentRecord,
    this.successMessage,
  });

  HealthRecordState<T> copyWith({
    AsyncValue<List<T>>? records,
    T? currentRecord,
    String? successMessage,
  }) {
    return HealthRecordState(
      records: records ?? this.records,
      currentRecord: currentRecord ?? this.currentRecord,
      successMessage: successMessage,
    );
  }
}
