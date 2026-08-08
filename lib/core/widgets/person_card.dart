import 'package:flutter/material.dart';

import '../../app/theme/app_dimens.dart';
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
    final theme = Theme.of(context);

    return Card(
      elevation: AppDimens.elevationS,
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.spacingL,
        vertical: AppDimens.spacingXS,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
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
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingText != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppDimens.spacingS),
                  child: Text(
                    trailingText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
