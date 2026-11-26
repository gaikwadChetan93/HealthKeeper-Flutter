import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/models/doctor.dart';
import '../../../core/state/doctor_providers.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/standard_app_header.dart';

/// Add or edit a doctor.
class AddDoctorScreen extends ConsumerStatefulWidget {
  final String? doctorId;

  const AddDoctorScreen({super.key, this.doctorId});

  @override
  ConsumerState<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends ConsumerState<AddDoctorScreen> {
  late final Doctor? _editing = widget.doctorId == null
      ? null
      : ref.read(doctorProvider(widget.doctorId!));
  late String _name = _editing?.name ?? '';
  late String _speciality = _editing?.speciality ?? '';
  late String _phone = _editing?.phone ?? '';
  late String _clinic = _editing?.clinic ?? '';
  late String _notes = _editing?.notes ?? '';
  Map<String, String> _errors = {};
  bool _saving = false;

  bool get isEdit => widget.doctorId != null;

  Future<void> _save() async {
    if (_name.trim().isEmpty)
      return setState(() => _errors = {'name': 'Name is required'});
    final body = {
      'name': _name.trim(),
      'speciality': _speciality.trim().isEmpty ? null : _speciality.trim(),
      'phone': _phone.trim().isEmpty ? null : _phone.trim(),
      'clinic': _clinic.trim().isEmpty ? null : _clinic.trim(),
      'notes': _notes.trim().isEmpty ? null : _notes.trim(),
    };
    setState(() => _saving = true);
    final doctors = ref.read(doctorsProvider.notifier);
    try {
      if (_editing != null) {
        await doctors.edit(_editing, body);
      } else {
        await doctors.create(body);
      }
      if (!mounted) return;
      showMessage(context, isEdit ? 'Doctor updated' : 'Doctor added');
      context.pop();
    } on ApiException catch (e) {
      setState(() => _errors = e.fields);
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Remove ${_editing!.name}?'),
        content: const Text(
            'Records keep the doctor’s name, but won’t be linked to this doctor any more.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(c).colorScheme.error),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(doctorsProvider.notifier).remove(_editing!);
    if (mounted) context.go(Routes.doctors);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        StandardAppHeader(
            title: isEdit ? 'Edit Doctor' : 'Add Doctor',
            onBack: () => context.pop()),
        Expanded(
          child: ListView(
              padding: const EdgeInsets.all(AppDimens.spacingL),
              children: [
                AppTextField(
                  label: 'Name',
                  required: true,
                  value: _name,
                  placeholder: 'e.g. Dr. Anita Desai',
                  errorText: _errors['name'],
                  onChanged: (v) => setState(() {
                    _name = v;
                    _errors = {..._errors}..remove('name');
                  }),
                ),
                const SizedBox(height: AppDimens.spacingM),
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: _speciality),
                  optionsBuilder: (v) => Doctor.specialities.where((s) =>
                      s.toLowerCase().contains(v.text.trim().toLowerCase())),
                  onSelected: (s) => _speciality = s,
                  fieldViewBuilder: (_, controller, focus, __) => TextField(
                    controller: controller,
                    focusNode: focus,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        labelText: 'Speciality', hintText: 'e.g. Cardiologist'),
                    onChanged: (v) => _speciality = v,
                  ),
                ),
                const SizedBox(height: AppDimens.spacingM),
                AppTextField(
                  label: 'Phone',
                  value: _phone,
                  keyboardType: TextInputType.phone,
                  errorText: _errors['phone'],
                  onChanged: (v) => _phone = v,
                ),
                const SizedBox(height: AppDimens.spacingM),
                AppTextField(
                    label: 'Clinic / Hospital',
                    value: _clinic,
                    onChanged: (v) => _clinic = v),
                const SizedBox(height: AppDimens.spacingM),
                AppTextField(
                    label: 'Notes',
                    value: _notes,
                    multiline: true,
                    onChanged: (v) => _notes = v),
                const SizedBox(height: AppDimens.spacingXXL),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isEdit ? 'Update' : 'Save'),
                ),
                if (_editing != null) ...[
                  const SizedBox(height: AppDimens.spacingL),
                  OutlinedButton(
                    onPressed: _saving ? null : _delete,
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error),
                    child: const Text('Remove Doctor'),
                  ),
                ],
              ]),
        ),
      ]),
    );
  }
}
