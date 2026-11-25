import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String? errorText;
  final bool required;
  final bool allowFuture;
  final bool allowPast;
  final bool includeTime;

  /// Where the picker opens when nothing is chosen yet (default: today).
  final DateTime? initialPickerDate;

  /// Open on year selection, e.g. for a date of birth.
  final bool startWithYear;
  final ValueChanged<DateTime?>? onChanged;

  const AppDatePickerField({
    super.key,
    required this.label,
    this.value,
    this.errorText,
    this.required = false,
    this.allowFuture = true,
    this.allowPast = true,
    this.includeTime = false,
    this.initialPickerDate,
    this.startWithYear = false,
    this.onChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = allowPast ? DateTime(1900) : now;
    final lastDate = allowFuture ? DateTime(2100) : now;

    final date = await showDatePicker(
      context: context,
      initialDate: value ?? initialPickerDate ?? now,
      initialDatePickerMode: startWithYear && value == null
          ? DatePickerMode.year
          : DatePickerMode.day,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date == null || !context.mounted) return;

    if (includeTime) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(value ?? now),
      );
      if (time != null) {
        onChanged?.call(DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ));
      }
    } else {
      onChanged?.call(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = includeTime
        ? DateFormat('dd MMM yyyy, hh:mm a')
        : DateFormat('dd MMM yyyy');

    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: 'Select ${includeTime ? "date & time" : "date"}',
        errorText: errorText,
        suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
      ),
      controller: TextEditingController(
        text: value != null ? format.format(value!) : '',
      ),
      onTap: () => _pickDate(context),
    );
  }
}
