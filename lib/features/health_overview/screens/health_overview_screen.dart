import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/vital_module_colors.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/domain_config.dart';
import '../../../core/state/api_providers.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/colored_avatar.dart';
import '../../../core/widgets/standard_app_header.dart';

class HealthOverviewScreen extends ConsumerStatefulWidget {
  final String memberId;
  const HealthOverviewScreen({super.key, required this.memberId});

  @override
  ConsumerState<HealthOverviewScreen> createState() =>
      _HealthOverviewScreenState();
}

class _HealthOverviewScreenState extends ConsumerState<HealthOverviewScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final member = ref.watch(memberProvider(widget.memberId));
    final counts =
        ref.watch(summaryProvider(widget.memberId)).valueOrNull ?? const {};
    final theme = Theme.of(context);

    final quickHealthModules = ModuleRegistry.quickHealthModules;
    final vitalModules = ModuleRegistry.vitalOverviewModules;

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: 'Health Overview',
            onBack: () => context.pop(),
          ),

          // Member info
          if (member != null)
            Padding(
              padding: const EdgeInsets.all(AppDimens.spacingL),
              child: Row(
                children: [
                  ColoredAvatar(name: member.name, size: 44),
                  const SizedBox(width: AppDimens.spacingM),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${member.isSelf ? 'You' : member.relationLabel} • ${member.age} yrs',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Segmented tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingL),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                    value: 0,
                    label: Text('Quick Health'),
                    icon: Icon(Icons.grid_view, size: 18)),
                ButtonSegment(
                    value: 1,
                    label: Text('Vitals'),
                    icon: Icon(Icons.show_chart, size: 18)),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (v) => setState(() => _selectedTab = v.first),
              showSelectedIcon: false,
            ),
          ),

          const SizedBox(height: AppDimens.spacingM),

          // Module grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppDimens.spacingL),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.82,
                crossAxisSpacing: AppDimens.spacingM,
                mainAxisSpacing: AppDimens.spacingM,
              ),
              itemCount: _selectedTab == 0
                  ? quickHealthModules.length
                  : vitalModules.length,
              itemBuilder: (_, i) {
                final module =
                    _selectedTab == 0 ? quickHealthModules[i] : vitalModules[i];
                // Lab results come with report upload in the next step.
                final available = module.domainKey != 'lab_result';
                return _ModuleCard(
                  config: module,
                  count: available ? counts[module.domainKey] ?? 0 : null,
                  onTap: available
                      ? () => context.push(
                          Routes.healthList(module.domainKey, widget.memberId))
                      : () => showMessage(context,
                          'Lab results and report upload are coming next'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatefulWidget {
  final DomainConfig config;
  final VoidCallback onTap;

  /// Records saved in this module; null when the module isn't available yet.
  final int? count;

  const _ModuleCard({required this.config, required this.onTap, this.count});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
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
                Text(
                  widget.count == null
                      ? 'Soon'
                      : widget.count == 0
                          ? 'No records'
                          : '${widget.count} record${widget.count == 1 ? '' : 's'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
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
