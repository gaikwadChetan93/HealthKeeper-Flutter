import 'package:flutter/material.dart';

import '../../../core/models/lab.dart';
import '../lab_format.dart';

/// "High", "Borderline", "In range" or "No range", coloured to match.
class LabFlagChip extends StatelessWidget {
  final LabResultItem result;

  const LabFlagChip({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final color = LabFormat.color(result.flag, Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: result.flag == null ? 0.08 : 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(LabFormat.chip(result),
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
