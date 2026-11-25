import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/models/lab.dart';
import '../lab_format.dart';
import 'lab_flag_chip.dart';

/// One result: test name, value, flag, and where its range came from.
class LabResultTile extends StatelessWidget {
  final LabResultItem result;
  final VoidCallback? onTap;

  /// Shows the date instead of the range line (for lists across reports).
  final bool showDate;
  final String? trailingNote;

  /// Shows a pencil to correct the value or range.
  final VoidCallback? onEdit;

  const LabResultTile(
      {super.key,
      required this.result,
      this.onTap,
      this.showDate = false,
      this.trailingNote,
      this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelSmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spacingL, vertical: AppDimens.spacingM),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.name,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    showDate
                        ? DateFormat('d MMM yyyy').format(result.takenOn)
                        : LabFormat.rangeText(result),
                    style: muted,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (trailingNote != null) Text(trailingNote!, style: muted),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.spacingS),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(LabFormat.value(result),
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            LabFormat.color(result.flag, theme.colorScheme))),
                const SizedBox(height: 4),
                LabFlagChip(result: result),
              ],
            ),
            if (onEdit != null)
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
              )
            else if (onTap != null)
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
