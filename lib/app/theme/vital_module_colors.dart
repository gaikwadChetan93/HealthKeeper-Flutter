import 'package:flutter/material.dart';

import 'app_colors.dart';

class VitalColors {
  final Color backgroundColor;
  final Color iconTint;

  const VitalColors({
    required this.backgroundColor,
    required this.iconTint,
  });
}

/// Per-vital accent colours, retuned to the redesign's muted hue set.
///
/// Structure is unchanged from before the redesign — same lookup map, same
/// two accessors — only the hex values moved from the old bright Material
/// palette to the design's 10 muted hues (each hue also colours that vital's
/// entry in [AppColors], so charts/badges/icons stay consistent).
class VitalModuleColors {
  VitalModuleColors._();

  static const _colorMap = <String, VitalColors>{
    'blood_pressure': VitalColors(
      backgroundColor: Color(0xFFF3E3DF),
      iconTint: AppColors.hueBloodPressure,
    ),
    'heart_rate': VitalColors(
      backgroundColor: Color(0xFFF2E1E5),
      iconTint: AppColors.hueHeartRate,
    ),
    'blood_glucose': VitalColors(
      backgroundColor: Color(0xFFEAE3F0),
      iconTint: AppColors.hueGlucose,
    ),
    'oxygen_saturation': VitalColors(
      backgroundColor: Color(0xFFE1E9EE),
      iconTint: AppColors.hueOxygen,
    ),
    'weight': VitalColors(
      backgroundColor: Color(0xFFE1EBE5),
      iconTint: AppColors.hueWeight,
    ),
    'height': VitalColors(
      backgroundColor: Color(0xFFE1EBE5),
      iconTint: AppColors.hueWeight,
    ),
    'temperature': VitalColors(
      backgroundColor: Color(0xFFF1E6D8),
      iconTint: AppColors.hueTemperature,
    ),
    'sleep': VitalColors(
      backgroundColor: Color(0xFFE3E4EF),
      iconTint: AppColors.hueSleep,
    ),
    'hydration': VitalColors(
      backgroundColor: Color(0xFFDFEAEA),
      iconTint: AppColors.hueHydration,
    ),
    'exercise': VitalColors(
      backgroundColor: Color(0xFFE5EADC),
      iconTint: AppColors.hueActivity,
    ),
  };

  static const _defaultColors = VitalColors(
    backgroundColor: AppColors.surfaceMuted,
    iconTint: AppColors.textMuted,
  );

  static Color getBackgroundColor(String moduleKey) =>
      _colorMap[moduleKey]?.backgroundColor ?? _defaultColors.backgroundColor;

  static Color getIconTint(String moduleKey) =>
      _colorMap[moduleKey]?.iconTint ?? _defaultColors.iconTint;

  static VitalColors getColors(String moduleKey) =>
      _colorMap[moduleKey] ?? _defaultColors;
}
