import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

class AppDatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String? errorText;
  final bool required;
  final bool allowFuture;
  final bool allowPast;
  final bool includeTime;
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
    this.onChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = allowPast ? DateTime(1900) : now;
    final lastDate = allowFuture ? DateTime(2100) : now;

    final date = await showDatePicker(
      context: context,
      initialDate: value ?? now,
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
          date.year, date.month, date.day, time.hour, time.minute,
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
      style: AppTypography.cardTitle.copyWith(fontSize: 15, height: 1.4),
      decoration: InputDecoration(
        labelText: required ? '${label.toUpperCase()} *' : label.toUpperCase(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: AppTypography.fieldLabel,
        floatingLabelStyle: AppTypography.fieldLabel,
        hintText: 'Select ${includeTime ? "date & time" : "date"}',
        hintStyle: AppTypography.cardTitle.copyWith(color: AppColors.textFaint, fontWeight: FontWeight.w400),
        errorText: errorText,
        errorStyle: AppTypography.captionSmall.copyWith(color: AppColors.error),
        suffixIcon: const Icon(Icons.event, size: 18, color: AppColors.primary),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.only(top: 5, bottom: 2),
      ),
      controller: TextEditingController(
        text: value != null ? format.format(value!) : '',
      ),
      onTap: () => _pickDate(context),
    );
  }
}
