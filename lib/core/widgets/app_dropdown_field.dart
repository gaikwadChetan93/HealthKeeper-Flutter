import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../models/field_descriptor.dart';

class AppDropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final String? errorText;
  final bool required;
  final List<EnumOption> options;
  final ValueChanged<String?>? onChanged;

  const AppDropdownField({
    super.key,
    required this.label,
    this.value,
    this.errorText,
    this.required = false,
    required this.options,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      style: AppTypography.cardTitle.copyWith(fontSize: 15, height: 1.4),
      icon: const Icon(Icons.expand_more, size: 18, color: AppColors.textFaint),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        errorText: errorText,
        errorStyle: AppTypography.captionSmall.copyWith(color: AppColors.error),
      ),
      items: options
          .map((opt) => DropdownMenuItem(
                value: opt.value,
                child: Text(opt.displayName),
              ))
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }
}
