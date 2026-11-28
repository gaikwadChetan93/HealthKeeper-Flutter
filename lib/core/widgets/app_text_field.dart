import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// A form text field in the app's outlined style (from the theme), so every
/// form shows where to type.
class AppTextField extends StatelessWidget {
  final String label;
  final String? value;
  final String? errorText;
  final String? placeholder;
  final bool required;
  final bool multiline;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  /// Shown after the typed value, e.g. a unit ("mmHg").
  final String? suffixText;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.value,
    this.errorText,
    this.placeholder,
    this.required = false,
    this.multiline = false,
    this.keyboardType,
    this.suffixIcon,
    this.suffixText,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      style: AppTypography.cardTitle.copyWith(fontSize: 15, height: 1.4),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: placeholder,
        hintStyle: AppTypography.cardTitle.copyWith(color: AppColors.textFaint, fontWeight: FontWeight.w400),
        errorText: errorText,
        errorStyle: AppTypography.captionSmall.copyWith(color: AppColors.error),
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        alignLabelWithHint: multiline,
      ),
      keyboardType: multiline ? TextInputType.multiline : keyboardType,
      maxLines: multiline ? 3 : 1,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
    );
  }
}
