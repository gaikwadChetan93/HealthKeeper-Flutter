import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/state/module_providers.dart';
import '../../../core/widgets/animated_fab.dart';
import '../../../core/widgets/doctor_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/standard_app_header.dart';

class MyDoctorsScreen extends ConsumerWidget {
  const MyDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctors = ref.watch(doctorsProvider);

    return Scaffold(
      body: Column(
        children: [
          const StandardAppHeader(title: 'My Doctors'),
          Expanded(
            child: doctors.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.medical_services_outlined,
                    title: 'No Doctors Added Yet',
                    description: 'Add your first doctor to keep track.',
                    ctaLabel: 'Add Doctor',
                    onCta: () => context.push(Routes.addDoctor),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(AppDimens.spacingL),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: AppDimens.spacingM,
                      mainAxisSpacing: AppDimens.spacingM,
                    ),
                    itemCount: doctors.length,
                    itemBuilder: (_, i) {
                      final d = doctors[i];
                      return DoctorCard(
                        name: d.name,
                        speciality: d.speciality,
                        contactNumber: d.contactNumber,
                        colorIndex: i,
                        onEdit: () => context.push(Routes.editDoctor(d.id)),
                        onCall: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling ${d.contactNumber}...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: AnimatedFab(
        onPressed: () => context.push(Routes.addDoctor),
      ),
    );
  }
}
