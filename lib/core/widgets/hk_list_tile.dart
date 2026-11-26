import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import 'hk_card.dart';

/// The redesign's standard list row: a tinted rounded-square icon, a
/// title/subtitle pair, and an optional trailing widget (chevron, chip,
/// switch). Wraps itself in an [HkCard] so every records/settings/documents
/// row looks the same without repeating the container styling.
class HkListTile extends StatelessWidget {
  final IconData icon;
  final Color hue;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const HkListTile({
    super.key,
    required this.icon,
    required this.hue,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return HkCard(
      radius: AppDimens.radiusTile,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      onTap: onTap,
      showShadow: false,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.tint(hue),
              borderRadius: BorderRadius.circular(AppDimens.radiusChip),
            ),
            child: Icon(icon, size: 19, color: hue),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.cardTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ] else if (showChevron) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textFaint),
          ],
        ],
      ),
    );
  }
}
