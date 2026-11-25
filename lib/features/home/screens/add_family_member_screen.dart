import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/models/field_descriptor.dart';
import '../../../core/models/member.dart';
import '../../../core/state/api_providers.dart';
import '../../../core/widgets/app_date_picker_field.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/colored_avatar.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../widgets/member_dialogs.dart';

/// Adds or edits a family member. With [creatingSelf] it is the one-time
/// "create your profile" step after the first sign-in.
class AddFamilyMemberScreen extends ConsumerStatefulWidget {
  final String? memberId;
  final bool creatingSelf;

  const AddFamilyMemberScreen(
      {super.key, this.memberId, this.creatingSelf = false});

  @override
  ConsumerState<AddFamilyMemberScreen> createState() =>
      _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends ConsumerState<AddFamilyMemberScreen> {
  final _idempotencyKey = ApiClient.newIdempotencyKey();
  String _name = '';
  DateTime? _dob;
  String? _sex;
  String? _relation;
  bool _attested = false;
  bool _saving = false;
  Map<String, String> _errors = {};
  Member? _editing;

  bool get isEdit => widget.memberId != null;
  bool get _isSelf => widget.creatingSelf || _relation == 'self';

  @override
  void initState() {
    super.initState();
    if (widget.creatingSelf) _relation = 'self';
    if (isEdit) {
      _editing = ref.read(memberProvider(widget.memberId!));
      final m = _editing;
      if (m != null) {
        _name = m.name;
        _dob = m.dateOfBirth;
        _sex = m.sex;
        _relation = m.relation;
      }
    }
  }

  List<EnumOption> get _relationOptions =>
      widget.creatingSelf || _editing?.isSelf == true
          ? Member.relations.where((r) => r.value == 'self').toList()
          : Member.relations.where((r) => r.value != 'self').toList();

  /// Changes a field and clears its error message.
  void _update(String key, VoidCallback change) {
    setState(() {
      change();
      _errors = {..._errors}..remove(key);
    });
  }

  Future<void> _save() async {
    final errors = <String, String>{
      if (_name.trim().isEmpty) 'name': 'Name is required',
      if (_dob == null) 'date_of_birth': 'Date of birth is required',
      if (_relation == null) 'relation': 'Relation is required',
      if (!isEdit && !_isSelf && !_attested) 'attested': 'Please confirm',
    };
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;

    final body = <String, dynamic>{
      'name': _name.trim(),
      'date_of_birth': _dob!.toIso8601String().substring(0, 10),
      'sex': _sex,
      'relation': _relation,
    };
    setState(() => _saving = true);
    final members = ref.read(membersProvider.notifier);
    try {
      if (isEdit) {
        await members.edit(_editing!, body);
      } else {
        await members.create({...body, 'attested': !_isSelf && _attested},
            idempotencyKey: _idempotencyKey);
      }
      if (!mounted) return;
      if (widget.creatingSelf) return; // the router moves on to the family list
      showMessage(context, isEdit ? 'Member updated' : 'Member added');
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errors = e.fields);
      if (e.code == 'plan_limit') {
        showMemberLimitDialog(context, e.message);
      } else {
        showMessage(context, e.message);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (!await confirmDeleteMember(context, _editing!.name) || !mounted) return;
    try {
      await ref.read(membersProvider.notifier).remove(_editing!);
      if (mounted) context.go(Routes.home);
    } on ApiException catch (e) {
      if (mounted) showMessage(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.creatingSelf
        ? 'Your Profile'
        : (isEdit ? 'Edit Member' : 'Add Member');
    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
              title: title,
              onBack: widget.creatingSelf ? null : () => context.pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.creatingSelf)
                    const Padding(
                      padding: EdgeInsets.only(bottom: AppDimens.spacingL),
                      child: Text(
                          'Start with your own details. You can add family members next.'),
                    ),
                  Center(
                      child: ColoredAvatar(
                          name: _name.isEmpty ? '?' : _name, size: 80)),
                  const SizedBox(height: AppDimens.spacingXL),
                  ..._fields(),
                  const SizedBox(height: AppDimens.spacingXXL),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(isEdit
                            ? 'Update'
                            : (widget.creatingSelf ? 'Continue' : 'Save')),
                  ),
                  if (isEdit && _editing?.isSelf == false) ...[
                    const SizedBox(height: AppDimens.spacingL),
                    OutlinedButton(
                      onPressed: _saving ? null : _delete,
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error),
                      child: const Text('Delete Member'),
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

  List<Widget> _fields() => [
        AppTextField(
          label: 'Full Name',
          required: true,
          value: _name,
          errorText: _errors['name'],
          onChanged: (v) => _update('name', () => _name = v),
        ),
        const SizedBox(height: AppDimens.spacingM),
        AppDatePickerField(
          label: 'Date of Birth',
          required: true,
          value: _dob,
          allowFuture: false,
          startWithYear: true,
          initialPickerDate: DateTime(DateTime.now().year - 30),
          errorText: _errors['date_of_birth'],
          onChanged: (v) => _update('date_of_birth', () => _dob = v),
        ),
        const SizedBox(height: AppDimens.spacingM),
        AppDropdownField(
          label: 'Sex',
          value: _sex,
          options: Member.sexes,
          onChanged: (v) => setState(() => _sex = v),
        ),
        const SizedBox(height: AppDimens.spacingM),
        AppDropdownField(
          label: 'Relation',
          required: true,
          value: _relation,
          errorText: _errors['relation'],
          options: _relationOptions,
          onChanged: (v) => _update('relation', () => _relation = v),
        ),
        if (!isEdit && !_isSelf) ...[
          const SizedBox(height: AppDimens.spacingM),
          CheckboxListTile(
            value: _attested,
            onChanged: (v) => _update('attested', () => _attested = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text(
                'They are 18 or older and agreed to me keeping their health records.'),
            subtitle: _errors['attested'] != null
                ? Text(_errors['attested']!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error))
                : null,
          ),
        ],
      ];
}
