import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/state/lab_providers.dart';
import '../../../core/widgets/app_date_picker_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../widgets/result_entry_card.dart';
import '../widgets/test_picker_sheet.dart';

/// Type in a lab report: date, lab, and the tests on it.
class AddLabReportScreen extends ConsumerStatefulWidget {
  final String memberId;

  const AddLabReportScreen({super.key, required this.memberId});

  @override
  ConsumerState<AddLabReportScreen> createState() => _AddLabReportScreenState();
}

class _AddLabReportScreenState extends ConsumerState<AddLabReportScreen> {
  final _idempotencyKey = ApiClient.newIdempotencyKey();
  final _entries = <ResultEntry>[];
  DateTime? _date = DateTime.now();
  String _lab = '';
  String? _dateError;
  bool _saving = false;

  @override
  void dispose() {
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  Future<void> _addTest() async {
    final test = await showTestPicker(context,
        exclude: {for (final e in _entries) e.test.id});
    if (test != null) setState(() => _entries.add(ResultEntry(test)));
  }

  bool _validate() {
    var ok = _date != null;
    _dateError = _date == null ? 'Choose the report date' : null;
    for (final e in _entries) {
      e.errors = {};
      final v = ResultEntry.parse(e.value.text);
      final lo =
          e.low.text.trim().isEmpty ? null : ResultEntry.parse(e.low.text);
      final hi =
          e.high.text.trim().isEmpty ? null : ResultEntry.parse(e.high.text);
      if (v == null) e.errors['value'] = 'Enter a number';
      if (e.low.text.trim().isNotEmpty && lo == null) {
        e.errors['ref_low'] = 'Number';
      }
      if (e.high.text.trim().isNotEmpty && hi == null) {
        e.errors['ref_high'] = 'Number';
      }
      if (lo != null && hi != null && lo > hi) {
        e.errors['ref_high'] = 'Lower than “From”';
      }
      ok &= e.errors.isEmpty;
    }
    setState(() {});
    return ok;
  }

  Future<void> _save() async {
    if (_entries.isEmpty) return showMessage(context, 'Add at least one test');
    if (!_validate()) return;
    setState(() => _saving = true);
    try {
      final report = await ref.read(labActionsProvider).createReport(
        widget.memberId,
        date: _date!,
        labName: _lab,
        idempotencyKey: _idempotencyKey,
        results: [
          for (final e in _entries)
            LabResultDraft(
              testId: e.test.id,
              value: ResultEntry.parse(e.value.text)!,
              unit: e.unit,
              refLow: ResultEntry.parse(e.low.text),
              refHigh: ResultEntry.parse(e.high.text),
            ),
        ],
      );
      if (!mounted) return;
      showMessage(context, 'Saved ${report.resultCount} results');
      context.pushReplacement(Routes.labReport(report.id));
    } on ApiException catch (e) {
      // Errors come back as "results.2.value"; show each under its test.
      setState(() {
        for (final f in e.fields.entries) {
          final parts = f.key.split('.');
          if (parts.length == 3 && parts[0] == 'results') {
            final i = int.tryParse(parts[1]);
            if (i != null && i < _entries.length) {
              _entries[i].errors[parts[2]] = f.value;
            }
          }
          if (f.key == 'report_date') _dateError = f.value;
        }
      });
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StandardAppHeader(
              title: 'Add Lab Results', onBack: () => context.pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppDimens.spacingL),
              children: [
                AppDatePickerField(
                  label: 'Report date',
                  required: true,
                  value: _date,
                  allowFuture: false,
                  errorText: _dateError,
                  onChanged: (d) => setState(() => _date = d),
                ),
                const SizedBox(height: AppDimens.spacingM),
                AppTextField(
                    label: 'Lab name',
                    placeholder: 'e.g. City Diagnostics',
                    onChanged: (v) => _lab = v),
                const SizedBox(height: AppDimens.spacingL),
                for (final e in _entries)
                  ResultEntryCard(
                    key: ObjectKey(e),
                    entry: e,
                    onChanged: () => setState(() => e.errors = {}),
                    onRemove: () => setState(() {
                      _entries.remove(e);
                      e.dispose();
                    }),
                  ),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _addTest,
                  icon: const Icon(Icons.add),
                  label: Text(
                      _entries.isEmpty ? 'Add a test' : 'Add another test'),
                ),
                const SizedBox(height: AppDimens.spacingXL),
                FilledButton(
                  onPressed: _saving || _entries.isEmpty ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          'Save ${_entries.isEmpty ? '' : '${_entries.length} '}result${_entries.length == 1 ? '' : 's'}'),
                ),
                const SizedBox(height: AppDimens.spacingXXL),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
