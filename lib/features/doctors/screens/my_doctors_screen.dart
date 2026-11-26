import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../core/state/doctor_providers.dart';
import '../../../core/widgets/animated_fab.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../widgets/doctor_card.dart';

/// The family's doctors. Shared by every family member.
class MyDoctorsScreen extends ConsumerWidget {
  const MyDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctors = ref.watch(doctorsProvider);
    return Scaffold(
      body: Column(children: [
        const StandardAppHeader(title: 'My Doctors'),
        Expanded(
          child: doctors.when(
            skipLoadingOnReload: true,
            loading: () => const ShimmerLoading(),
            error: (e, _) => LoadErrorView(
                error: e, onRetry: () => ref.invalidate(doctorsProvider)),
            data: (list) => list.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.medical_services_outlined,
                    title: 'No Doctors Added Yet',
                    description:
                        'Add your family’s doctors to call them quickly and see every visit, '
                        'prescription and appointment with them.',
                    ctaLabel: 'Add Doctor',
                    onCta: () => context.push(Routes.addDoctor),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref.refresh(doctorsProvider.future),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 96),
                      itemCount: list.length,
                      itemBuilder: (_, i) => DoctorCard(
                        doctor: list[i],
                        colorIndex: i,
                        onTap: () =>
                            context.push(Routes.doctorDetail(list[i].id)),
                      ),
                    ),
                  ),
          ),
        ),
      ]),
      floatingActionButton:
          AnimatedFab(onPressed: () => context.push(Routes.addDoctor)),
    );
  }
}
