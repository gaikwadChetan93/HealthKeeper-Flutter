import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/state/active_person_provider.dart';
import '../../../core/state/module_providers.dart';
import '../../../core/widgets/hk_person_avatar.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../state/home_timeline.dart';
import '../widgets/add_sheet.dart';
import '../widgets/home_activity_timeline.dart';
import '../widgets/home_fresh_state.dart';
import '../widgets/home_needs_attention.dart';
import '../widgets/home_snapshot_strip.dart';

/// The redesigned Home tab: person hero, vitals snapshot, needs-attention,
/// month-grouped activity timeline and a privacy footer — or, for a person
/// with nothing recorded yet, the first-run setup card.
class HomeTabScreen extends ConsumerWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(familyMembersProvider);
    final person = ref.watch(activePersonProvider);

    if (person == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Add a family member to get started')),
      );
    }

    final personIndex = members.indexOf(person);
    final timeline = watchHomeTimeline(ref, person.id);
    final bpState = ref.watch(bloodPressureProvider(person.id)).records;
    final weightState = ref.watch(weightProvider(person.id)).records;
    final hrState = ref.watch(heartRateProvider(person.id)).records;
    final hasBp = bpState.valueOrNull?.isNotEmpty ?? false;
    final hasWeight = weightState.valueOrNull?.isNotEmpty ?? false;
    final hasHr = hrState.valueOrNull?.isNotEmpty ?? false;
    final isLoading = watchHomeTimelineLoading(ref, person.id) ||
        bpState.isLoading ||
        weightState.isLoading ||
        hrState.isLoading;
    final isFresh = !isLoading && timeline.isEmpty && !hasBp && !hasWeight && !hasHr;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                      onTap: () => context.push(Routes.personPicker),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HkPersonAvatar(
                              initials: _initials(person.name),
                              hue: AppColors.getAvatarColor(personIndex),
                              size: 32,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('MANAGING', style: AppTypography.eyebrow),
                                const SizedBox(height: 2),
                                Text(person.name.split(' ').first, style: AppTypography.cardTitle),
                              ],
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.unfold_more, size: 18, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RoundIconButton(icon: Icons.search, onTap: () => context.push(Routes.search)),
                  const SizedBox(width: 8),
                  _RoundIconButton(icon: Icons.settings_outlined, onTap: () => context.push(Routes.settings)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                children: isLoading
                    ? [
                        Text(person.name, style: AppTypography.heroTitle.copyWith(fontSize: 29)),
                        const SizedBox(height: 6),
                        Text('${person.relation} · ${person.age} yrs', style: AppTypography.caption),
                        const SizedBox(height: 18),
                        const ShimmerLoading(itemCount: 4),
                      ]
                    : isFresh
                    ? [
                        HomeFreshState(
                          firstName: person.name.split(' ').first,
                          memberId: person.id,
                          onAddVital: () => showAddSheet(context, ref),
                        ),
                      ]
                    : [
                        Text(person.name, style: AppTypography.heroTitle.copyWith(fontSize: 29)),
                        const SizedBox(height: 6),
                        Text('${person.relation} · ${person.age} yrs', style: AppTypography.caption),
                        const SizedBox(height: 18),
                        HomeSnapshotStrip(memberId: person.id),
                        const SizedBox(height: 22),
                        HomeNeedsAttention(memberId: person.id),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${person.name.split(' ').first}'s recent activity", style: AppTypography.sectionTitle),
                            GestureDetector(
                              onTap: () => context.push(Routes.records),
                              child: Text(
                                'All records',
                                style: AppTypography.button.copyWith(color: AppColors.primary, fontSize: 11.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (timeline.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('Nothing recorded yet.', style: AppTypography.caption),
                          )
                        else
                          HomeActivityTimeline(entries: timeline),
                        const SizedBox(height: 6),
                        _PrivacyFooter(onTap: () => context.push(Routes.privacyAndData)),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _PrivacyFooter extends StatelessWidget {
  final VoidCallback onTap;
  const _PrivacyFooter({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusTile),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          border: Border.all(color: AppColors.primarySoftBorder),
          borderRadius: BorderRadius.circular(AppDimens.radiusTile),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user_outlined, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Kept on this phone only', style: AppTypography.cardTitle),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
          ],
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
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 19, color: AppColors.textMuted5),
        ),
      ),
    );
  }
}
