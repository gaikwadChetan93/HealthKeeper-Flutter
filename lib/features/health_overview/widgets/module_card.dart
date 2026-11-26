import 'package:flutter/material.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/vital_module_colors.dart';
import '../../../core/models/domain_config.dart';

class ModuleCard extends StatefulWidget {
  final DomainConfig config;
  final VoidCallback onTap;

  const ModuleCard({
    super.key,
    required this.config,
    required this.onTap,
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = VitalModuleColors.getColors(widget.config.domainKey);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Card(
          elevation: AppDimens.elevationS,
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.spacingM),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.backgroundColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusS),
                  ),
                  child: Icon(
                    widget.config.icon,
                    color: colors.iconTint,
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppDimens.spacingS),
                Text(
                  widget.config.domainName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
