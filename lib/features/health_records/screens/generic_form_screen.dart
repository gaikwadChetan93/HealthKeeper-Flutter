import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/domain_config.dart';
import '../../../core/models/record_item.dart';
import '../../../core/records/record_format.dart';
import '../../../core/state/api_providers.dart';
import '../../../core/state/form_state_notifier.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../widgets/record_form_fields.dart';

/// Adds a record, or edits one when [recordId] is given.
class GenericFormScreen extends ConsumerWidget {
  final String moduleKey;
  final String memberId;
  final String? recordId;

  const GenericFormScreen(
      {super.key,
      required this.moduleKey,
      required this.memberId,
      this.recordId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ModuleRegistry.getModuleByKey(moduleKey);
    if (config == null) {
      return Scaffold(body: Center(child: Text('Unknown module: $moduleKey')));
    }
    final title = recordId != null
        ? 'Edit ${config.domainName}'
        : 'Add ${config.domainName}';
    final Widget body;
    if (recordId == null) {
      body = _RecordForm(config: config, memberId: memberId);
    } else {
      // The form is built only once the record has loaded, so fields start filled in.
      body = ref.watch(recordProvider(recordId!)).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => LoadErrorView(
                error: e,
                onRetry: () => ref.invalidate(recordProvider(recordId!))),
            data: (r) => _RecordForm(
                key: ValueKey('${r.id}-${r.version}'),
                config: config,
                memberId: memberId,
                existing: r),
          );
    }
    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(title: title, onBack: () => context.pop()),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _RecordForm extends ConsumerStatefulWidget {
  final DomainConfig config;
  final String memberId;
  final RecordItem? existing;

  const _RecordForm(
      {super.key, required this.config, required this.memberId, this.existing});

  @override
  ConsumerState<_RecordForm> createState() => _RecordFormState();
}

class _RecordFormState extends ConsumerState<_RecordForm> {
  final _idempotencyKey = ApiClient.newIdempotencyKey();
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    Future.microtask(() {
      final form = ref.read(formStateProvider.notifier);
      form.clearForm();
      if (existing != null)
        form.prefillForm(RecordFormat.toForm(widget.config, existing.payload));
    });
  }

  Future<void> _save() async {
    final notifier = ref.read(formStateProvider.notifier);
    if (!notifier.validate(widget.config.fields)) return;
    final payload = RecordFormat.toPayload(
        widget.config, ref.read(formStateProvider).formData);
    notifier.setSubmitting(true);
    final actions = ref.read(recordActionsProvider);
    try {
      if (widget.existing == null) {
        await actions.create(widget.memberId, widget.config.domainKey, payload,
            idempotencyKey: _idempotencyKey);
      } else {
        await actions.update(widget.existing!, payload);
      }
      if (!mounted) return;
      showMessage(
          context, widget.existing == null ? 'Record saved' : 'Record updated');
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      notifier.setErrors(e.formFieldErrors);
      final advancedKeys =
          widget.config.fields.where((f) => f.isAdvanced).map((f) => f.key);
      if (e.formFieldErrors.keys.any(advancedKeys.contains))
        setState(() => _showAdvanced = true);
      showMessage(
          context,
          e.isConflict
              ? 'This record was changed on another device. Go back and open it again.'
              : e.message);
    } finally {
      if (mounted) notifier.setSubmitting(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(formStateProvider);
    final fields = widget.config.fields;
    final advanced = fields.where((f) => f.isAdvanced).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RecordFormFields(fields: fields.where((f) => !f.isAdvanced).toList()),
          if (advanced.isNotEmpty) ...[
            const SizedBox(height: AppDimens.spacingL),
            InkWell(
              onTap: () => setState(() => _showAdvanced = !_showAdvanced),
              child: Row(
                children: [
                  Icon(_showAdvanced ? Icons.expand_less : Icons.expand_more,
                      size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: AppDimens.spacingS),
                  Text(
                    _showAdvanced ? 'Show Less' : 'Show More',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            if (_showAdvanced) ...[
              const SizedBox(height: AppDimens.spacingL),
              RecordFormFields(fields: advanced),
            ],
          ],
          const SizedBox(height: AppDimens.spacingXXL),
          FilledButton(
            onPressed: formState.isSubmitting ? null : _save,
            child: formState.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(widget.existing != null ? 'Update' : 'Save'),
          ),
          const SizedBox(height: AppDimens.spacingXXL),
        ],
      ),
    );
  }
}
