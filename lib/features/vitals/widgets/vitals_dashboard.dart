import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/state/vitals_providers.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import 'vital_summary_card.dart';

/// The Vitals tab of a member's overview: one card per vital, newest readings first.
class VitalsDashboard extends ConsumerWidget {
  final String memberId;

  const VitalsDashboard({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(vitalsSummaryProvider(memberId));
    return summary.when(
      skipLoadingOnReload: true,
      loading: () => const ShimmerLoading(),
      error: (e, _) => LoadErrorView(
          error: e,
          onRetry: () => ref.invalidate(vitalsSummaryProvider(memberId))),
      data: (cards) {
        // Vitals with readings first, most recent at the top; then the rest in their usual order.
        final withData = cards.where((c) => c.hasReadings).toList()
          ..sort((a, b) => b.latestDate!.compareTo(a.latestDate!));
        final empty = cards.where((c) => !c.hasReadings).toList();
        return RefreshIndicator(
          onRefresh: () => ref.refresh(vitalsSummaryProvider(memberId).future),
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppDimens.spacingXXL),
            children: [
              if (withData.isNotEmpty)
                const _SectionTitle('Your vitals · last 30 days'),
              for (final c in withData)
                VitalSummaryCard(
                  summary: c,
                  onTap: () =>
                      context.push(Routes.vitalChart(c.module, memberId)),
                ),
              if (empty.isNotEmpty)
                _SectionTitle(
                    withData.isEmpty ? 'Start tracking' : 'Not tracked yet'),
              for (final c in empty)
                VitalSummaryCard(
                  summary: c,
                  onTap: () =>
                      context.push(Routes.healthAdd(c.module, memberId)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.spacingL, AppDimens.spacingM,
          AppDimens.spacingL, AppDimens.spacingS),
      child: Text(text,
          style: theme.textTheme.titleSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    );
  }
}
