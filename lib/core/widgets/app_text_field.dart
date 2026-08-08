import 'package:flutter/material.dart';

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
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: placeholder,
        errorText: errorText,
        suffixIcon: suffixIcon,
      ),
      keyboardType: multiline ? TextInputType.multiline : keyboardType,
      maxLines: multiline ? 3 : 1,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
    );
  }
}
