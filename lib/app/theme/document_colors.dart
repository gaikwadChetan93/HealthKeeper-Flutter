import 'package:flutter/material.dart';

import '../../core/models/document.dart';
import 'app_colors.dart';

/// Per-category accent colour for the Documents library — same shared hue
/// set as [RecordCategoryColors] and [VitalModuleColors], so a lab-report
/// document reads with the same amber used for lab results elsewhere.
class DocumentColors {
  DocumentColors._();

  static const _hueMap = <DocumentCategory, Color>{
    DocumentCategory.labReport: AppColors.hueTemperature,
    DocumentCategory.prescription: AppColors.hueGlucose,
    DocumentCategory.radiology: AppColors.hueHeartRate,
    DocumentCategory.bill: AppColors.hueDocument,
    DocumentCategory.vaccineCertificate: AppColors.hueActivity,
    DocumentCategory.insurance: AppColors.hueOxygen,
    DocumentCategory.other: AppColors.hueDocument,
  };

  static Color getHue(DocumentCategory category) => _hueMap[category] ?? AppColors.hueDocument;
}
