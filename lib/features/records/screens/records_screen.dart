import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/record_category_colors.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/state/active_person_provider.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../health_records/config/module_screen_config.dart';
import '../../home/state/home_timeline.dart';
import '../../home/widgets/home_activity_timeline.dart';

/// The redesigned Records tab: a person's whole record history, either as
/// one chronological timeline or grouped by category — the design's
/// `recTabs` segmented switch.
class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  bool _showCategories = false;

  @override
  Widget build(BuildContext context) {
    final person = ref.watch(activePersonProvider);
    final memberId = ref.watch(activePersonIdOrFallbackProvider);
    final isLoading = watchHomeTimelineLoading(ref, memberId);
    final timeline = watchHomeTimeline(ref, memberId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (person?.name ?? '').toUpperCase(),
                          style: AppTypography.eyebrow.copyWith(letterSpacing: .12),
                        ),
                        const SizedBox(height: 7),
                        Text('Records', style: AppTypography.heroTitle.copyWith(fontSize: 26)),
                      ],
                    ),
                    _RoundIconButton(icon: Icons.search, onTap: () => context.push(Routes.search)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SegmentButton(
                          label: 'Timeline',
                          selected: !_showCategories,
                          onTap: () => setState(() => _showCategories = false),
                        ),
                      ),
                      Expanded(
                        child: _SegmentButton(
                          label: 'Categories',
                          selected: _showCategories,
                          onTap: () => setState(() => _showCategories = true),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 100),
                sliver: SliverToBoxAdapter(child: ShimmerLoading()),
              )
            else if (_showCategories)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 100),
                sliver: SliverList.builder(
                  itemCount: ModuleRegistry.quickHealthModules.length,
                  itemBuilder: (_, i) {
                    final module = ModuleRegistry.quickHealthModules[i];
                    final count = ref
                            .watch(ModuleScreenConfig.getConfig(module.domainKey).getProvider(memberId))
                            .records
                            .valueOrNull
                            ?.length ??
                        0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CategoryRow(
                        icon: module.icon,
                        hue: RecordCategoryColors.getHue(module.domainKey),
                        title: module.domainName,
                        count: count,
                        onTap: () => context.push(Routes.healthList(module.domainKey, memberId)),
                      ),
                    );
                  },
                ),
              )
            else if (timeline.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                  child: Column(
                    children: [
                      const Icon(Icons.folder_open, size: 40, color: AppColors.textMuted),
                      const SizedBox(height: 14),
                      Text(
                        'Nothing recorded yet',
                        style: AppTypography.cardTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Visits, prescriptions, lab results and more will show up here once you add them.',
                        style: AppTypography.bodySecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverToBoxAdapter(child: HomeActivityTimeline(entries: timeline)),
              ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusTileS - 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusTileS - 3),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.button.copyWith(
              color: selected ? AppColors.ink : AppColors.textMuted5,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final IconData icon;
  final Color hue;
  final String title;
  final int count;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.icon,
    required this.hue,
    required this.title,
    required this.count,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppDimens.radiusTile),
          ),
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
                  children: [
                    Text(title, style: AppTypography.cardTitle),
                    const SizedBox(height: 2),
                    Text(
                      count == 0 ? 'No records yet' : '$count record${count == 1 ? '' : 's'}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 38, height: 38, child: Icon(icon, size: 19, color: AppColors.textMuted5)),
      ),
    );
  }
}
