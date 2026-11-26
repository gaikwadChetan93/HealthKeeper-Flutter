import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/vital_module_colors.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/domain_config.dart';
import '../../../core/state/api_providers.dart';
import '../../../core/state/lab_providers.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/colored_avatar.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../../vitals/widgets/vitals_dashboard.dart';

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
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final labReports =
        ref.watch(labReportsProvider(widget.memberId)).valueOrNull?.length;
    final theme = Theme.of(context);

    final quickHealthModules = ModuleRegistry.quickHealthModules;

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

          // Vitals: dashboard with latest values and trends. Records: module grid.
          Expanded(
            child: _selectedTab == 1
                ? VitalsDashboard(memberId: widget.memberId)
                : GridView.builder(
                    padding: const EdgeInsets.all(AppDimens.spacingL),
                    // Card height follows the text size; with large text, two
                    // columns so names like "Appointment" fit on one line.
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: textScale > 1.15 ? 2 : 3,
                      mainAxisExtent: 76 + 42 * textScale,
                      crossAxisSpacing: AppDimens.spacingM,
                      mainAxisSpacing: AppDimens.spacingM,
                    ),
                    itemCount: quickHealthModules.length,
                    itemBuilder: (_, i) {
                      final module = quickHealthModules[i];
                      final isLabs = module.domainKey == 'lab_result';
                      return _ModuleCard(
                        config: module,
                        count:
                            isLabs ? labReports : counts[module.domainKey] ?? 0,
                        countLabel: isLabs ? 'report' : 'record',
                        onTap: () => context.push(isLabs
                            ? Routes.labs(widget.memberId)
                            : Routes.healthList(
                                module.domainKey, widget.memberId)),
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

  /// Records saved in this module; null while it is loading.
  final int? count;

  /// What is being counted: "record", or "report" for lab results.
  final String countLabel;

  const _ModuleCard(
      {required this.config,
      required this.onTap,
      this.count,
      this.countLabel = 'record'});

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
                      ? ''
                      : widget.count == 0
                          ? 'No ${widget.countLabel}s'
                          : '${widget.count} ${widget.countLabel}${widget.count == 1 ? '' : 's'}',
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
