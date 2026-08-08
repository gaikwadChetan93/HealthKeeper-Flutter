import 'package:flutter/material.dart';

class VitalColors {
  final Color backgroundColor;
  final Color iconTint;

  const VitalColors({
    required this.backgroundColor,
    required this.iconTint,
  });
}

class VitalModuleColors {
  VitalModuleColors._();

  static const _colorMap = <String, VitalColors>{
    'blood_pressure': VitalColors(
      backgroundColor: Color(0xFFFEE0C4),
      iconTint: Color(0xFFF97035),
    ),
    'heart_rate': VitalColors(
      backgroundColor: Color(0xFFFFDFE5),
      iconTint: Color(0xFFFF6B8A),
    ),
    'temperature': VitalColors(
      backgroundColor: Color(0xFFE3F2FD),
      iconTint: Color(0xFF42A5F5),
    ),
    'oxygen_saturation': VitalColors(
      backgroundColor: Color(0xFFFFF9E6),
      iconTint: Color(0xFFFFB300),
    ),
    'weight': VitalColors(
      backgroundColor: Color(0xFFE8F5E9),
      iconTint: Color(0xFF66BB6A),
    ),
    'blood_glucose': VitalColors(
      backgroundColor: Color(0xFFF3E5F5),
      iconTint: Color(0xFFAB47BC),
    ),
    'sleep': VitalColors(
      backgroundColor: Color(0xFFFFE5F0),
      iconTint: Color(0xFFFF4081),
    ),
    'exercise': VitalColors(
      backgroundColor: Color(0xFFE0F7FA),
      iconTint: Color(0xFF26C6DA),
    ),
    'hydration': VitalColors(
      backgroundColor: Color(0xFFE8F5E9),
      iconTint: Color(0xFF66BB6A),
    ),
    'height': VitalColors(
      backgroundColor: Color(0xFFFFE5F0),
      iconTint: Color(0xFFFF4081),
    ),
  };

  static const _defaultColors = VitalColors(
    backgroundColor: Color(0xFFF5F5F5),
    iconTint: Color(0xFF757575),
  );

  static Color getBackgroundColor(String moduleKey) =>
      _colorMap[moduleKey]?.backgroundColor ?? _defaultColors.backgroundColor;

  static Color getIconTint(String moduleKey) =>
      _colorMap[moduleKey]?.iconTint ?? _defaultColors.iconTint;

  static VitalColors getColors(String moduleKey) =>
      _colorMap[moduleKey] ?? _defaultColors;
}
