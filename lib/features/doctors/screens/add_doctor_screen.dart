import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/models/field_descriptor.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/colored_avatar.dart';
import '../../../core/widgets/standard_app_header.dart';

class AddDoctorScreen extends ConsumerWidget {
  final int? doctorId;
  const AddDoctorScreen({super.key, this.doctorId});

  bool get isEdit => doctorId != null;

  static const _specialities = [
    EnumOption('General Physician', 'General Physician'),
    EnumOption('Cardiologist', 'Cardiologist'),
    EnumOption('Dermatologist', 'Dermatologist'),
    EnumOption('Pediatrician', 'Pediatrician'),
    EnumOption('Orthopedic', 'Orthopedic'),
    EnumOption('Neurologist', 'Neurologist'),
    EnumOption('Gynecologist', 'Gynecologist'),
    EnumOption('Urologist', 'Urologist'),
    EnumOption('ENT Specialist', 'ENT Specialist'),
    EnumOption('Ophthalmologist', 'Ophthalmologist'),
    EnumOption('Dentist', 'Dentist'),
    EnumOption('Psychiatrist', 'Psychiatrist'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: isEdit ? 'Edit Doctor' : 'Add Doctor',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.spacingL),
              child: Column(
                children: [
                  const Center(
                    child: ColoredAvatar(name: 'Dr', size: 80, colorIndex: 3),
                  ),
                  const SizedBox(height: AppDimens.spacingXL),
                  const AppTextField(label: 'Doctor Name', required: true),
                  const SizedBox(height: AppDimens.spacingM),
                  const AppDropdownField(
                    label: 'Speciality',
                    required: true,
                    options: _specialities,
                  ),
                  const SizedBox(height: AppDimens.spacingM),
                  const AppTextField(
                    label: 'Contact Number',
                    required: true,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppDimens.spacingXXL),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEdit ? 'Doctor updated' : 'Doctor added'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        context.pop();
                      },
                      child: Text(isEdit ? 'Update' : 'Save'),
                    ),
                  ),
                  if (isEdit) ...[
                    const SizedBox(height: AppDimens.spacingL),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('Delete Doctor'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
