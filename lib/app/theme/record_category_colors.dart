import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Per-category accent colour for the 10 "quick health" record modules —
/// the record-side counterpart to [VitalModuleColors]. Same shared hue set,
/// same lookup shape, so record tiles and vital tiles read as one family of
/// colour-coded categories throughout Records, the add sheet, and search.
class RecordCategoryColors {
  RecordCategoryColors._();

  static const _hueMap = <String, Color>{
    'medical_visit': AppColors.hueOxygen,
    'appointment': AppColors.hueOxygen,
    'allergy': AppColors.hueTemperature,
    'vaccine': AppColors.hueActivity,
    'medication': AppColors.hueGlucose,
    'prescription': AppColors.hueGlucose,
    'lab_result': AppColors.hueTemperature,
    'medical_history': AppColors.hueDocument,
    'surgery': AppColors.hueBloodPressure,
    'radiology_result': AppColors.hueHeartRate,
  };

  static Color getHue(String moduleKey) => _hueMap[moduleKey] ?? AppColors.hueDocument;
}
