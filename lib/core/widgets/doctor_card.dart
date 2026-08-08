import 'package:flutter/material.dart';

import '../../app/theme/app_dimens.dart';
import 'colored_avatar.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String speciality;
  final String contactNumber;
  final int colorIndex;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onCall;

  const DoctorCard({
    super.key,
    required this.name,
    required this.speciality,
    required this.contactNumber,
    this.colorIndex = 0,
    this.onTap,
    this.onEdit,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: AppDimens.elevationS,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingM),
          child: Column(
            children: [
              ColoredAvatar(name: name, colorIndex: colorIndex, size: 48),
              const SizedBox(height: AppDimens.spacingS),
              Text(
                name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                speciality,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                contactNumber,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimens.spacingS),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: onEdit,
                      visualDensity: VisualDensity.compact,
                    ),
                  if (onCall != null)
                    IconButton(
                      icon: Icon(
                        Icons.phone_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: onCall,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
