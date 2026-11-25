import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/models/field_descriptor.dart';
import '../../../core/state/form_state_notifier.dart';
import 'field_renderer.dart';

/// Renders a module's fields; consecutive half-width fields share a row.
class RecordFormFields extends ConsumerWidget {
  final List<FieldDescriptor> fields;

  const RecordFormFields({super.key, required this.fields});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(formStateProvider);
    final notifier = ref.read(formStateProvider.notifier);

    Widget field(FieldDescriptor f) => FieldRenderer(
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
