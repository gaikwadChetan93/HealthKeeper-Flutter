import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/field_descriptor.dart';

class FormDataState {
  final Map<String, dynamic> formData;
  final Map<String, String> formErrors;
  final bool isSubmitting;

  const FormDataState({
    this.formData = const {},
    this.formErrors = const {},
    this.isSubmitting = false,
  });

  FormDataState copyWith({
    Map<String, dynamic>? formData,
    Map<String, String>? formErrors,
    bool? isSubmitting,
  }) {
    return FormDataState(
      formData: formData ?? this.formData,
      formErrors: formErrors ?? this.formErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class FormStateNotifier extends StateNotifier<FormDataState> {
  FormStateNotifier() : super(const FormDataState());

  void updateField(String key, dynamic value) {
    final updated = Map<String, dynamic>.from(state.formData);
    updated[key] = value;

    // Clear error for this field on update
    final errors = Map<String, String>.from(state.formErrors);
    errors.remove(key);

    state = state.copyWith(formData: updated, formErrors: errors);
  }

  void prefillForm(Map<String, dynamic> data) {
    state = state.copyWith(formData: data);
  }

  bool validate(List<FieldDescriptor> fields) {
    final errors = <String, String>{};

    for (final field in fields) {
      if (field.required) {
        final value = state.formData[field.key];
        if (value == null || (value is String && value.trim().isEmpty)) {
          errors[field.key] = '${field.label} is required';
        }
      }

      // Number range validation
      if (field is NumberFieldDescriptor && state.formData[field.key] != null) {
        final numStr = state.formData[field.key].toString();
        final num = double.tryParse(numStr);
        if (num != null) {
          if (field.min != null && num < field.min!) {
            errors[field.key] = 'Minimum value is ${field.min}';
          }
          if (field.max != null && num > field.max!) {
            errors[field.key] = 'Maximum value is ${field.max}';
          }
        }
      }
    }

    state = state.copyWith(formErrors: errors);
    return errors.isEmpty;
  }

  void clearForm() {
    state = const FormDataState();
  }

  void setSubmitting(bool value) {
    state = state.copyWith(isSubmitting: value);
  }
}

final formStateProvider =
    StateNotifierProvider.autoDispose<FormStateNotifier, FormDataState>(
  (ref) => FormStateNotifier(),
);
