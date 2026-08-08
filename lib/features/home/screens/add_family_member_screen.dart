import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/state/module_providers.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/colored_avatar.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../../../core/models/field_descriptor.dart';

class AddFamilyMemberScreen extends ConsumerStatefulWidget {
  final int? memberId;
  const AddFamilyMemberScreen({super.key, this.memberId});

  @override
  ConsumerState<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends ConsumerState<AddFamilyMemberScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _relation;
  bool get isEdit => widget.memberId != null;

  static const _relations = [
    EnumOption('Self', 'Self'),
    EnumOption('Husband', 'Husband'),
    EnumOption('Wife', 'Wife'),
    EnumOption('Daughter', 'Daughter'),
    EnumOption('Son', 'Son'),
    EnumOption('Father', 'Father'),
    EnumOption('Mother', 'Mother'),
    EnumOption('Sibling', 'Sibling'),
    EnumOption('Friend', 'Friend'),
    EnumOption('Other', 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final members = ref.read(familyMembersProvider);
      final member = members.where((m) => m.id == widget.memberId).firstOrNull;
      if (member != null) {
        _nameController.text = member.name;
        _ageController.text = member.age.toString();
        _relation = member.relation;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: isEdit ? 'Edit Member' : 'Add Member',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.spacingL),
              child: Column(
                children: [
                  // Avatar preview
                  Center(
                    child: ColoredAvatar(
                      name: _nameController.text.isEmpty ? '?' : _nameController.text,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacingXL),
                  AppTextField(
                    label: 'Full Name',
                    required: true,
                    onChanged: (v) => setState(() {}),
                  ),
                  const SizedBox(height: AppDimens.spacingM),
                  const AppTextField(
                    label: 'Age',
                    required: true,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppDimens.spacingM),
                  AppDropdownField(
                    label: 'Relation',
                    required: true,
                    value: _relation,
                    options: _relations,
                    onChanged: (v) => setState(() => _relation = v),
                  ),
                  const SizedBox(height: AppDimens.spacingXXL),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEdit ? 'Member updated' : 'Member added'),
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
                        child: const Text('Delete Member'),
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
