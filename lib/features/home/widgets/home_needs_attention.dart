import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/state/module_providers.dart';
import '../../../core/widgets/hk_card.dart';

/// "Needs attention" — for now just the nearest upcoming appointment, a
/// real (if modest) signal rather than the design's fixed sample cards.
/// Renders nothing when there isn't one, rather than always showing a
/// section with fabricated content.
class HomeNeedsAttention extends ConsumerWidget {
  final int memberId;

  const HomeNeedsAttention({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentProvider(memberId)).records.valueOrNull;
    if (appointments == null || appointments.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final upcoming = appointments.where((a) => a.appointmentDate.isAfter(now)).toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    if (upcoming.isEmpty) return const SizedBox.shrink();

    final next = upcoming.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Needs attention', style: AppTypography.sectionTitle),
            Text('1', style: AppTypography.caption),
          ],
        ),
        const SizedBox(height: 12),
        HkCard(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          onTap: () => context.push(Routes.healthList('appointment', memberId)),
          borderColor: AppColors.hueOxygen.withValues(alpha: 0.35),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.tint(AppColors.hueOxygen),
                  borderRadius: BorderRadius.circular(AppDimens.radiusChip),
                ),
                child: const Icon(Icons.event_outlined, size: 19, color: AppColors.hueOxygen),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appointment with ${next.doctorName}', style: AppTypography.cardTitle),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEE d MMM, h:mm a').format(next.appointmentDate),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.tint(AppColors.hueOxygen),
                  borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                ),
                child: Text(
                  'View',
                  style: AppTypography.captionSmall.copyWith(color: AppColors.hueOxygen),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
