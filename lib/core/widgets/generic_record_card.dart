import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_dimens.dart';
import '../../app/theme/vital_module_colors.dart';
import '../models/sync_status.dart';
import 'sync_status_badge.dart';

class GenericRecordCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final DateTime date;
  final IconData icon;
  final String moduleKey;
  final SyncStatus syncStatus;
  final String? categoryTag;
  final int? attachmentCount;
  final VoidCallback? onTap;

  const GenericRecordCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.date,
    required this.icon,
    required this.moduleKey,
    this.syncStatus = SyncStatus.synced,
    this.categoryTag,
    this.attachmentCount,
    this.onTap,
  });

  @override
  State<GenericRecordCard> createState() => _GenericRecordCardState();
}

class _GenericRecordCardState extends State<GenericRecordCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = VitalModuleColors.getColors(widget.moduleKey);
    final dateFormat = DateFormat('dd MMM yyyy');

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Card(
          elevation: AppDimens.elevationS,
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimens.spacingL,
            vertical: AppDimens.spacingXS,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.spacingM),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.backgroundColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusS),
                  ),
                  child: Icon(widget.icon, color: colors.iconTint, size: 22),
                ),
                const SizedBox(width: AppDimens.spacingM),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SyncStatusBadge(status: widget.syncStatus),
                        ],
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            dateFormat.format(widget.date),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (widget.categoryTag != null) ...[
                            const SizedBox(width: AppDimens.spacingS),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.backgroundColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.categoryTag!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.iconTint,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                          if (widget.attachmentCount != null &&
                              widget.attachmentCount! > 0) ...[
                            const SizedBox(width: AppDimens.spacingS),
                            Icon(
                              Icons.attach_file,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            Text(
                              '${widget.attachmentCount}',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppDimens.spacingS),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
