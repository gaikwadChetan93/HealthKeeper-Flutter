import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/models/field_descriptor.dart';
import '../../../core/state/form_state_notifier.dart';
import '../../../core/records/doctor_fields.dart';
import '../../doctors/widgets/doctor_picker_field.dart';
import 'field_renderer.dart';

/// Renders a module's fields; consecutive half-width fields share a row.
class RecordFormFields extends ConsumerWidget {
  final List<FieldDescriptor> fields;

  /// Which module the fields belong to; its doctor field suggests saved doctors.
  final String moduleKey;

  const RecordFormFields(
      {super.key, required this.fields, required this.moduleKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(formStateProvider);
    final notifier = ref.read(formStateProvider.notifier);

    Widget field(FieldDescriptor f) => f.key == doctorFields[moduleKey]
        ? DoctorPickerField(
            key: ValueKey('${f.key}-${state.prefillGeneration}'),
            descriptor: f,
            name: state.formData[f.key] as String?,
            doctorId: state.formData[doctorIdKey] as String?,
            error: state.formErrors[f.key],
            onChanged: (name, doctorId) {
              notifier.updateField(f.key, name);
              notifier.updateField(doctorIdKey, doctorId);
            },
            onPicked: (d) {
              // Fill the clinic from the doctor's details if it's still empty.
              final data = ref.read(formStateProvider).formData;
              final clinicField = clinicFields[moduleKey];
              final current = (data[clinicField] as String?)?.trim() ?? '';
              if (clinicField != null && d.clinic != null && current.isEmpty) {
                notifier.prefillForm({...data, clinicField: d.clinic});
              }
            },
          )
        : FieldRenderer(
            // Keyed by the prefilled value so an edit form shows the loaded record.
            key: ValueKey('${f.key}-${state.prefillGeneration}'),
            descriptor: f,
            value: state.formData[f.key],
            error: state.formErrors[f.key],
            onChanged: (v) => notifier.updateField(f.key, v),
          );

    final rows = <Widget>[];
    var i = 0;
    while (i < fields.length) {
      final f = fields[i];
      final pair = f.layoutWidth == LayoutWidth.half &&
          i + 1 < fields.length &&
          fields[i + 1].layoutWidth == LayoutWidth.half;
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.spacingM),
        child: pair
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: field(f)),
                  const SizedBox(width: AppDimens.spacingM),
                  Expanded(child: field(fields[i + 1])),
                ],
              )
            : field(f),
      ));
      i += pair ? 2 : 1;
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}
