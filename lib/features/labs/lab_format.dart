import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/models/lab.dart';

/// Display text and colours for lab results.
class LabFormat {
  LabFormat._();

  static String number(double v, int decimals) {
    final s = v.toStringAsFixed(decimals);
    return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
  }

  /// "1 result", "3 results".
  static String results(int n) => n == 1 ? '1 result' : '$n results';

  static String value(LabResultItem r) =>
      '${number(r.value, r.decimals + 1)} ${r.unit}'.trim();

  /// Short chip text: "High", "Borderline", "In range", "No range".
  static String chip(LabResultItem r) => switch (r.flag) {
        'high' => r.rangeSource == 'report' ? 'High' : 'Above range',
        'low' => r.rangeSource == 'report' ? 'Low' : 'Below range',
        'borderline' => 'Borderline',
        'in_range' => 'In range',
        _ => 'No range',
      };

  static Color color(String? flag, ColorScheme scheme) => switch (flag) {
        'high' || 'low' => AppColors.zoneCriticalHigh,
        'borderline' => AppColors.zoneWarning,
        'in_range' => AppColors.zoneNormal,
        _ => scheme.onSurfaceVariant,
      };

  /// Where the judgement came from, in words.
  static String rangeText(LabResultItem r) {
    if (r.rangeSource == 'report') {
      final d = r.decimals + 1;
      final range = switch ((r.refLow, r.refHigh)) {
        (final lo?, final hi?) => '${number(lo, d)}–${number(hi, d)}',
        (null, final hi?) => 'up to ${number(hi, d)}',
        (final lo?, null) => '${number(lo, d)} or more',
        _ => '',
      };
      return 'Report range $range ${r.unit}';
    }
    if (r.rangeSource == 'guideline') {
      return 'Guideline: ${r.rangeSourceText ?? ''}';
    }
    return 'No range — add the range printed on your report';
  }

  /// Same rules as the server: "µIU/mL" == "uIU/ml", "mcg" == "ug", "x10³/µL" == "10^3/ul".
  static String normUnit(String u) {
    var s = u.trim().toLowerCase();
    for (final (a, b) in const [
      ('µ', 'u'),
      ('μ', 'u'),
      ('mcg', 'ug'),
      ('×', 'x'),
      ('³', '^3'),
      ('⁶', '^6'),
      ('⁹', '^9'),
      ('cu mm', 'cumm'),
      ('cu.mm', 'cumm'),
      ('mm3', 'cumm'),
      (' ', ''),
    ]) {
      s = s.replaceAll(a, b);
    }
    if (s.startsWith('x10')) s = s.substring(1);
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
    return s;
  }

  /// The test's unit spelled as in its list, or null if [unit] isn't one of them.
  static String? matchUnit(LabTestDef test, String unit) =>
      test.units.where((u) => normUnit(u) == normUnit(unit)).firstOrNull;

  /// "(you entered 5.5 mmol/L)" when the value was typed in another unit.
  static String? entered(LabResultItem r) => r.enteredUnit == r.unit
      ? null
      : 'You entered ${number(r.enteredValue, 2)} ${r.enteredUnit}';
}
