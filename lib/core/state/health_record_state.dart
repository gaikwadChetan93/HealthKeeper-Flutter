import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/health_record.dart';

class HealthRecordState<T extends HealthRecord> {
  final AsyncValue<List<T>> records;
  final T? currentRecord;
  final String? successMessage;

  // Deliberately NOT const, and NOT a bare `= const AsyncValue.loading()`
  // default parameter value: in a generic class, a const default value
  // without an explicit type argument gets resolved ONCE at compile time
  // (Dart infers it as `AsyncValue<List<Never>>` here, since default
  // parameter values are baked into the constructor's signature rather
  // than re-evaluated per type instantiation) and that single canonicalized
  // constant is then wrongly reused for every concrete `T`. That's what
  // caused every module's `copyWith` to throw a runtime type error the
  // moment real data flowed through. Computing the default in the
  // initializer list instead, with the type spelled out explicitly, runs
  // fresh per instantiation with the correct `T`.
  HealthRecordState({
    AsyncValue<List<T>>? records,
    this.currentRecord,
    this.successMessage,
  }) : records = records ?? AsyncValue<List<T>>.loading();

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
