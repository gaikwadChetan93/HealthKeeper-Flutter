import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/vital_module_colors.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/domain_config.dart';

class VitalsOverviewContent extends ConsumerWidget {
  final int memberId;

  const VitalsOverviewContent({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vitalModules = ModuleRegistry.vitalOverviewModules;

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      itemCount: vitalModules.length,
      itemBuilder: (_, i) {
        final module = vitalModules[i];
        return _VitalSummaryCard(
          config: module,
          onTap: () => context.push(
            Routes.healthList(module.domainKey, memberId),
          ),
        );
      },
    );
  }
}

class _VitalSummaryCard extends StatelessWidget {
  final DomainConfig config;
  final VoidCallback onTap;

  const _VitalSummaryCard({
    required this.config,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = VitalModuleColors.getColors(config.domainKey);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spacingS),
      child: Card(
        elevation: AppDimens.elevationS,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.spacingL),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.backgroundColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusS),
                  ),
                  child: Icon(config.icon, color: colors.iconTint, size: 24),
                ),
                const SizedBox(width: AppDimens.spacingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.domainName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        config.shortDescription,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
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
