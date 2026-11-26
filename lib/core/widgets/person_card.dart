import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import 'colored_avatar.dart';

class PersonCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? trailingText;
  final int colorIndex;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const PersonCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.trailingText,
    this.colorIndex = 0,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.spacingL,
        vertical: AppDimens.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppDimens.radiusTile),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusTile),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.spacingM),
            child: Row(
              children: [
                ColoredAvatar(name: name, colorIndex: colorIndex, size: 48),
                const SizedBox(width: AppDimens.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTypography.cardTitle.copyWith(fontSize: 14.5)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTypography.caption),
                    ],
                  ),
                ),
                if (trailingText != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppDimens.spacingS),
                    child: Text(trailingText!, style: AppTypography.caption),
                  ),
                if (onEdit != null)
                  Material(
                    color: AppColors.surfaceMuted,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onEdit,
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(Icons.edit_outlined, size: 16, color: AppColors.textMuted5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
