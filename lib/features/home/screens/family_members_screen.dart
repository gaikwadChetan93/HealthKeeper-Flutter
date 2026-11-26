import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../core/state/api_providers.dart';
import '../../../core/widgets/animated_fab.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/person_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/standard_app_header.dart';

class FamilyMembersScreen extends ConsumerWidget {
  const FamilyMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(membersProvider);

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: 'Family Members',
            onBack: context.canPop() ? () => context.pop() : null,
          ),
          Expanded(
            child: members.when(
              loading: () => const ShimmerLoading(),
              error: (e, _) => LoadErrorView(
                  error: e, onRetry: () => ref.invalidate(membersProvider)),
              data: (list) => list.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.people_outline,
                      title: 'No Family Members Yet',
                      description:
                          'Add your first family member to start tracking health records.',
                      ctaLabel: 'Add Family Member',
                      onCta: () => context.push(Routes.addFamilyMember),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.refresh(membersProvider.future),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final m = list[i];
                          return PersonCard(
                            name: m.name,
                            subtitle: m.isSelf ? 'You' : m.relationLabel,
                            trailingText: '${m.age} yrs',
                            colorIndex: i,
                            onTap: () =>
                                context.push(Routes.healthOverview(m.id)),
                            onEdit: () =>
                                context.push(Routes.editFamilyMember(m.id)),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedFab(
        onPressed: () => context.push(Routes.addFamilyMember),
      ),
    );
  }
}
