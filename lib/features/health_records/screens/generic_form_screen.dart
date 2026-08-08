import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/field_descriptor.dart';
import '../../../core/state/form_state_notifier.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../widgets/field_renderer.dart';

class GenericFormScreen extends ConsumerStatefulWidget {
  final String moduleKey;
  final int memberId;
  final int? recordId;

  const GenericFormScreen({
    super.key,
    required this.moduleKey,
    required this.memberId,
    this.recordId,
  });

  @override
  ConsumerState<GenericFormScreen> createState() => _GenericFormScreenState();
}

class _GenericFormScreenState extends ConsumerState<GenericFormScreen> {
  bool _showAdvanced = false;
  bool get isEditMode => widget.recordId != null;

  @override
  Widget build(BuildContext context) {
    final config = ModuleRegistry.getModuleByKey(widget.moduleKey);
    if (config == null) {
      return Scaffold(body: Center(child: Text('Unknown module: ${widget.moduleKey}')));
    }

    final formState = ref.watch(formStateProvider);
    final formNotifier = ref.read(formStateProvider.notifier);

    final coreFields = config.fields.where((f) => !f.isAdvanced).toList();
    final advancedFields = config.fields.where((f) => f.isAdvanced).toList();

    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
            title: isEditMode ? 'Edit ${config.domainName}' : 'Add ${config.domainName}',
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Core fields
                  ..._buildFieldRows(coreFields, formState, formNotifier),

                  // Advanced fields toggle
                  if (advancedFields.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.spacingL),
                    InkWell(
                      onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                      child: Row(
                        children: [
                          Icon(
                            _showAdvanced ? Icons.expand_less : Icons.expand_more,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppDimens.spacingS),
                          Text(
                            _showAdvanced ? 'Show Less' : 'Show More',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showAdvanced) ...[
                      const SizedBox(height: AppDimens.spacingL),
                      ..._buildFieldRows(advancedFields, formState, formNotifier),
                    ],
                  ],

                  const SizedBox(height: AppDimens.spacingXXL),

                  // Save button
                  FilledButton(
                    onPressed: formState.isSubmitting
                        ? null
                        : () => _onSave(config.fields, formNotifier),
                    child: formState.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEditMode ? 'Update' : 'Save'),
                  ),
                  const SizedBox(height: AppDimens.spacingXXL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFieldRows(
    List<FieldDescriptor> fields,
    FormDataState formState,
    FormStateNotifier formNotifier,
  ) {
    final widgets = <Widget>[];
    var i = 0;

    while (i < fields.length) {
      final field = fields[i];

      // Check if this and next field are both HALF width
      if (field.layoutWidth == LayoutWidth.half &&
          i + 1 < fields.length &&
          fields[i + 1].layoutWidth == LayoutWidth.half) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.spacingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FieldRenderer(
                    descriptor: field,
                    value: formState.formData[field.key],
                    error: formState.formErrors[field.key],
                    onChanged: (v) => formNotifier.updateField(field.key, v),
                  ),
                ),
                const SizedBox(width: AppDimens.spacingM),
                Expanded(
                  child: FieldRenderer(
                    descriptor: fields[i + 1],
                    value: formState.formData[fields[i + 1].key],
                    error: formState.formErrors[fields[i + 1].key],
                    onChanged: (v) => formNotifier.updateField(fields[i + 1].key, v),
                  ),
                ),
              ],
            ),
          ),
        );
        i += 2;
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.spacingM),
            child: FieldRenderer(
              descriptor: field,
              value: formState.formData[field.key],
              error: formState.formErrors[field.key],
              onChanged: (v) => formNotifier.updateField(field.key, v),
            ),
          ),
        );
        i++;
      }
    }
    return widgets;
  }

  Future<void> _onSave(
    List<FieldDescriptor> fields,
    FormStateNotifier notifier,
  ) async {
    if (!notifier.validate(fields)) return;

    notifier.setSubmitting(true);
    await Future.delayed(const Duration(milliseconds: 500));
    notifier.setSubmitting(false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditMode ? 'Record updated' : 'Record saved'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }
}
