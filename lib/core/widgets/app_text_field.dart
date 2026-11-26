import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// A single "field row" in the redesigned record form: a small uppercase
/// label with the value beneath it, no visible box — the surrounding
/// [HkCard] plus a bottom divider (drawn by the parent list) supplies the
/// boxed look, matching the design's field-list card.
class AppTextField extends StatelessWidget {
  final String label;
  final String? value;
  final String? errorText;
  final String? placeholder;
  final bool required;
  final bool multiline;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
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
        labelText: required ? '${label.toUpperCase()} *' : label.toUpperCase(),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: AppTypography.fieldLabel,
        floatingLabelStyle: AppTypography.fieldLabel,
        hintText: placeholder,
        hintStyle: AppTypography.cardTitle.copyWith(color: AppColors.textFaint, fontWeight: FontWeight.w400),
        errorText: errorText,
        errorStyle: AppTypography.captionSmall.copyWith(color: AppColors.error),
        suffixIcon: suffixIcon,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.only(top: 5, bottom: 2),
      ),
      keyboardType: multiline ? TextInputType.multiline : keyboardType,
      maxLines: multiline ? 3 : 1,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
    );
  }
}
