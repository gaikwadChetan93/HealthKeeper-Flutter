import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/field_descriptor.dart';

class FormDataState {
  final Map<String, dynamic> formData;
  final Map<String, String> formErrors;
  final bool isSubmitting;

  /// Goes up each time the form is filled from a saved record, so fields
  /// that keep their own text (initialValue) are rebuilt with it.
  final int prefillGeneration;

  const FormDataState({
    this.formData = const {},
    this.formErrors = const {},
    this.isSubmitting = false,
    this.prefillGeneration = 0,
  });

  FormDataState copyWith({
    Map<String, dynamic>? formData,
    Map<String, String>? formErrors,
    bool? isSubmitting,
    int? prefillGeneration,
  }) {
    return FormDataState(
      formData: formData ?? this.formData,
      formErrors: formErrors ?? this.formErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      prefillGeneration: prefillGeneration ?? this.prefillGeneration,
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
    state = state.copyWith(
        formData: data, prefillGeneration: state.prefillGeneration + 1);
  }

  /// Errors the server found, keyed by field.
  void setErrors(Map<String, String> errors) {
    state = state.copyWith(formErrors: errors);
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
    state = FormDataState(prefillGeneration: state.prefillGeneration + 1);
  }

  void setSubmitting(bool value) {
    state = state.copyWith(isSubmitting: value);
  }
}

final formStateProvider =
    StateNotifierProvider.autoDispose<FormStateNotifier, FormDataState>(
  (ref) => FormStateNotifier(),
);
