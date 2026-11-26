import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/record_category_colors.dart';
import '../../../app/theme/vital_module_colors.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/domain_config.dart';
import '../../../core/state/active_person_provider.dart';

/// The centre nav button's modal sheet: "Add to {person}", split into
/// Health records and Vitals, matching the design's two-section picker.
///
/// Health records route into [GenericFormScreen] via [Routes.healthAdd];
/// vitals bypass the generic form and route into the numeric-keypad
/// [VitalEntryScreen] via [Routes.vitalEntry].
Future<void> showAddSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddSheet(),
  );
}

class _AddSheet extends ConsumerStatefulWidget {
  const _AddSheet();

  @override
  ConsumerState<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends ConsumerState<_AddSheet> {
  // Which category grid is showing below the tab bar — Health records or
  // Vitals. Splitting them into tabs (rather than stacking both, scrolled)
  // roughly halves how much grid a person has to scan through to find a
  // less-common module.
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final person = ref.watch(activePersonProvider);
    final memberId = ref.watch(activePersonIdOrFallbackProvider);

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.82),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.only(top: 10, bottom: 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.borderDashed,
                borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add to ${person?.name.split(' ').first ?? 'this person'}',
                    style: AppTypography.detailTitle.copyWith(fontSize: 19),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Everything you add lands in ${person?.name.split(' ').first ?? 'their'}'s space only",
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: _AddCategoryTabs(
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: _tab == 0
                    ? _AddSection(
                        modules: ModuleRegistry.quickHealthModules,
                        memberId: memberId,
                        hueOf: RecordCategoryColors.getHue,
                        routeBuilder: Routes.healthAdd,
                      )
                    : _AddSection(
                        modules: ModuleRegistry.vitalOverviewModules,
                        memberId: memberId,
                        hueOf: (key) => VitalModuleColors.getIconTint(key),
                        // Vitals bypass the generic form entirely — they use
                        // the numeric-keypad fast path instead.
                        routeBuilder: Routes.vitalEntry,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two-way switcher between the Health records and Vitals grids — same
/// filled-pill visual language as the chips used in [VitalEntryScreen],
/// sized as a pair of equal-width segments instead of a scrolling row.
class _AddCategoryTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _AddCategoryTabs({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _AddCategoryTab(
            label: 'Health records',
            count: ModuleRegistry.quickHealthModules.length,
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _AddCategoryTab(
            label: 'Vitals',
            count: ModuleRegistry.vitalOverviewModules.length,
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _AddCategoryTab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _AddCategoryTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            ),
            alignment: Alignment.center,
            child: Text(
              '$label · $count',
              style: AppTypography.button.copyWith(
                color: selected ? AppColors.onPrimary : AppColors.textMuted5,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The module grid for whichever category tab is active. The category
/// label/count used to be printed as a header here — now redundant since
/// [_AddCategoryTabs] already shows both, so this goes straight to the grid.
class _AddSection extends StatelessWidget {
  final List<DomainConfig> modules;
  final int memberId;
  final Color Function(String moduleKey) hueOf;
  final String Function(String moduleKey, int memberId) routeBuilder;

  const _AddSection({
    required this.modules,
    required this.memberId,
    required this.hueOf,
    required this.routeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 4),
      itemCount: modules.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (_, i) {
        final module = modules[i];
        return _AddOption(
          icon: module.icon,
          hue: hueOf(module.domainKey),
          label: module.domainName,
          onTap: () {
            Navigator.of(context).pop();
            context.push(routeBuilder(module.domainKey, memberId));
          },
        );
      },
    );
  }
}

class _AddOption extends StatelessWidget {
  final IconData icon;
  final Color hue;
  final String label;
  final VoidCallback onTap;

  const _AddOption({
    required this.icon,
    required this.hue,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusTile),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusTile),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppDimens.radiusTile),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.tint(hue),
                  borderRadius: BorderRadius.circular(AppDimens.radiusChip),
                ),
                child: Icon(icon, size: 24, color: hue),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.captionSmall.copyWith(
                  color: AppColors.textMuted5,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
