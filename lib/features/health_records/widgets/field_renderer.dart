import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/models/field_descriptor.dart';
import '../../../core/widgets/app_date_picker_field.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_text_field.dart';

class FieldRenderer extends StatelessWidget {
  final FieldDescriptor descriptor;
  final dynamic value;
  final String? error;
  final ValueChanged<dynamic> onChanged;

  const FieldRenderer({
    super.key,
    required this.descriptor,
    this.value,
    this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return switch (descriptor) {
      TextFieldDescriptor d => AppTextField(
          label: d.label,
          value: value as String?,
          errorText: error,
          placeholder: d.placeholder,
          required: d.required,
          multiline: d.multiline,
          onChanged: (v) => onChanged(v),
        ),
      NumberFieldDescriptor d => AppTextField(
          label: d.label,
          value: value?.toString(),
          errorText: error,
          required: d.required,
          keyboardType: TextInputType.numberWithOptions(decimal: d.decimal),
          suffixText: d.unit,
          onChanged: (v) => onChanged(v),
        ),
      DateFieldDescriptor d => AppDatePickerField(
          label: d.label,
          value: value as DateTime?,
          errorText: error,
          required: d.required,
          allowFuture: d.allowFuture,
          allowPast: d.allowPast,
          onChanged: (v) => onChanged(v),
        ),
      DateTimeFieldDescriptor d => AppDatePickerField(
          label: d.label,
          value: value as DateTime?,
          errorText: error,
          required: d.required,
          allowFuture: d.allowFuture,
          allowPast: d.allowPast,
          includeTime: true,
          onChanged: (v) => onChanged(v),
        ),
      TimeFieldDescriptor d => AppTextField(
          // Read-only and filled by the picker, so rebuild when the value changes.
          key: ValueKey(value),
          label: d.label,
          value: value as String?,
          errorText: error,
          required: d.required,
          readOnly: true,
          suffixIcon: const Icon(Icons.access_time, size: 20),
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _parseTime(value as String?) ?? TimeOfDay.now(),
            );
            if (time != null && context.mounted) {
              onChanged('${time.hour.toString().padLeft(2, '0')}:'
                  '${time.minute.toString().padLeft(2, '0')}');
            }
          },
          onChanged: (v) => onChanged(v),
        ),
      EnumFieldDescriptor d => AppDropdownField(
          label: d.label,
          value: value as String?,
          errorText: error,
          required: d.required,
          options: d.options,
          onChanged: (v) => onChanged(v),
        ),
      BooleanFieldDescriptor d => Row(
          children: [
            Expanded(child: Text(d.label, style: AppTypography.cardTitle)),
            Switch(
              value: value as bool? ?? false,
              onChanged: (v) => onChanged(v),
              activeThumbColor: AppColors.onPrimary,
              activeTrackColor: AppColors.primary,
            ),
          ],
        ),
      FileFieldDescriptor d => _FilePlaceholder(label: d.label),
      MeasurementFieldDescriptor d => AppTextField(
          label: d.label,
          value: value?.toString(),
          errorText: error,
          required: d.required,
          keyboardType: TextInputType.numberWithOptions(decimal: d.decimal),
          suffixText: d.unitType.defaultUnit,
          onChanged: (v) => onChanged(v),
        ),
    };
  }
}

TimeOfDay? _parseTime(String? hhmm) {
  final parts = hhmm?.split(':');
  if (parts == null || parts.length != 2) return null;
  final h = int.tryParse(parts[0]), m = int.tryParse(parts[1]);
  return h == null || m == null ? null : TimeOfDay(hour: h, minute: m);
}

class _FilePlaceholder extends StatelessWidget {
  final String label;
  const _FilePlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attachments arrive in a later update'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppDimens.radiusChip),
      child: Row(
        children: [
          const Icon(Icons.attach_file, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: AppTypography.eyebrow.copyWith(letterSpacing: .05)),
                const SizedBox(height: 3),
                Text('Tap to attach files', style: AppTypography.caption.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
