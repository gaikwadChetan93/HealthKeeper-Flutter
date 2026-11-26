import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/vital_module_colors.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/domain_config.dart';
import '../../../core/state/active_person_provider.dart';
import '../../../core/state/module_providers.dart';
import '../../../core/widgets/colored_avatar.dart';
import '../../../core/widgets/standard_app_header.dart';

class HealthOverviewScreen extends ConsumerStatefulWidget {
  /// Deep-link target. When omitted, falls back to [activePersonProvider] —
  /// this is the first screen migrated to the redesign's "active person is
  /// app state, not a route parameter" model.
  final int? memberId;

  /// 0 = Quick Health, 1 = Vitals. Lets the Records/Vitals tabs reuse this
  /// screen with a different starting segment until each gets its own
  /// restyled screen in a later phase.
  final int initialTab;

  const HealthOverviewScreen({super.key, this.memberId, this.initialTab = 0});

  @override
  ConsumerState<HealthOverviewScreen> createState() =>
      _HealthOverviewScreenState();
}

class _HealthOverviewScreenState extends ConsumerState<HealthOverviewScreen> {
  late int _selectedTab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(familyMembersProvider);
    final int activeFallbackId = ref.watch(activePersonIdOrFallbackProvider);
    final int resolvedId = widget.memberId ?? activeFallbackId;
    final member = members.where((m) => m.id == resolvedId).firstOrNull;
    final theme = Theme.of(context);

    final quickHealthModules = ModuleRegistry.quickHealthModules;
    final vitalModules = ModuleRegistry.vitalOverviewModules;

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: 'Health Overview',
            // Only show a back arrow when this was reached via an explicit
            // deep link (e.g. /health-overview/:memberId) — as the
            // Records/Vitals tab root there's nothing to pop back to.
            onBack: widget.memberId != null ? () => context.pop() : null,
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
                        '${member.relation} • ${member.age} yrs',
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
                ButtonSegment(value: 0, label: Text('Quick Health'), icon: Icon(Icons.grid_view, size: 18)),
                ButtonSegment(value: 1, label: Text('Vitals'), icon: Icon(Icons.show_chart, size: 18)),
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
                childAspectRatio: 0.95,
                crossAxisSpacing: AppDimens.spacingM,
                mainAxisSpacing: AppDimens.spacingM,
              ),
              itemCount: _selectedTab == 0 ? quickHealthModules.length : vitalModules.length,
              itemBuilder: (_, i) {
                final module = _selectedTab == 0
                    ? quickHealthModules[i]
                    : vitalModules[i];
                return _ModuleCard(
                  config: module,
                  onTap: () => context.push(
                    Routes.healthList(module.domainKey, resolvedId),
                  ),
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

  const _ModuleCard({required this.config, required this.onTap});

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
