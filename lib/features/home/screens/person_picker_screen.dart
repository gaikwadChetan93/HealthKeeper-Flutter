import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/state/active_person_provider.dart';
import '../../../core/state/module_providers.dart';
import '../../../core/widgets/hk_card.dart';
import '../../../core/widgets/hk_chip.dart';
import '../../../core/widgets/hk_person_avatar.dart';

/// Full-screen "whose health?" switcher. Reachable from the Home tab's
/// person header. Picking a card sets [activePersonProvider] for the whole
/// app (not just the current screen) and returns; "Manage family" hands off
/// to the full family list.
class PersonPickerScreen extends ConsumerWidget {
  const PersonPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(familyMembersProvider);
    final activeId = ref.watch(activePersonIdOrFallbackProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SWITCH PERSON', style: AppTypography.eyebrow),
                        const SizedBox(height: 6),
                        Text('Whose health?', style: AppTypography.detailTitle),
                      ],
                    ),
                  ),
                  _CloseButton(onTap: () => context.pop()),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 22),
                itemCount: members.length,
                separatorBuilder: (_, __) => const SizedBox(height: 11),
                itemBuilder: (_, i) {
                  final m = members[i];
                  final active = m.id == activeId;
                  final hue = AppColors.getAvatarColor(i);
                  return HkCard(
                    radius: AppDimens.radiusCardL,
                    borderColor: active ? AppColors.primary : AppColors.border,
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      ref.read(activePersonIdProvider.notifier).setActivePerson(m.id);
                      context.pop();
                    },
                    child: Row(
                      children: [
                        HkPersonAvatar(
                          initials: _initials(m.name),
                          hue: hue,
                          size: 50,
                          active: active,
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      m.name,
                                      style: AppTypography.sectionTitle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (active) ...[
                                    const SizedBox(width: 7),
                                    const _ActiveBadge(),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${m.relation} · ${m.age} yrs',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
              child: HkChip(
                label: 'Manage family',
                icon: Icons.group_outlined,
                dashed: true,
                onTap: () => context.push(Routes.family),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        'ACTIVE',
        style: AppTypography.captionSmall.copyWith(color: AppColors.primary, letterSpacing: .08),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.close, size: 19, color: AppColors.textMuted5),
        ),
      ),
    );
  }
}
