import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../state/home_timeline.dart';

/// The month-grouped activity feed on Home, built from [TimelineEntry]s
/// already fetched by the caller (kept as plain data in, plain widget out
/// so this file doesn't also need to know about Riverpod).
class HomeActivityTimeline extends StatelessWidget {
  final List<TimelineEntry> entries;

  const HomeActivityTimeline({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<TimelineEntry>>{};
    for (final e in entries) {
      final key = DateFormat('MMMM yyyy').format(e.date);
      groups.putIfAbsent(key, () => []).add(e);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 12),
            child: Text(
              group.key.toUpperCase(),
              style: AppTypography.eyebrow.copyWith(letterSpacing: .1),
            ),
          ),
          for (var i = 0; i < group.value.length; i++)
            _TimelineRow(
              entry: group.value[i],
              showLine: i < group.value.length - 1,
            ),
        ],
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final TimelineEntry entry;
  final bool showLine;

  const _TimelineRow({required this.entry, required this.showLine});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(Routes.healthDetail(entry.moduleKey, entry.recordId)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 34,
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.tint(entry.hue),
                      borderRadius: BorderRadius.circular(AppDimens.radiusChip - 1),
                    ),
                    child: Icon(entry.icon, size: 16, color: entry.hue),
                  ),
                  if (showLine)
                    Expanded(
                      child: Container(width: 1, color: AppColors.border, margin: const EdgeInsets.symmetric(vertical: 4)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: AppTypography.cardTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(DateFormat('d MMM').format(entry.date), style: AppTypography.captionSmall),
                      ],
                    ),
                    if (entry.subtitle != null && entry.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        entry.subtitle!,
                        style: AppTypography.bodySecondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
