import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/models/lab.dart';
import '../../../core/models/lab_upload.dart';
import '../../../core/state/api_providers.dart';
import '../../../core/state/lab_providers.dart';
import '../../../core/state/lab_upload_providers.dart';
import '../../../core/widgets/app_date_picker_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/load_error_view.dart';
import 'result_entry_card.dart';
import 'review_notices.dart';
import 'test_picker_sheet.dart';
import '../lab_format.dart';

/// The editable list of what was read, with date and lab; saves the reviewed values.
class ReviewForm extends ConsumerStatefulWidget {
  final LabUpload upload;
  final LabCatalog catalog;

  const ReviewForm({super.key, required this.upload, required this.catalog});

  @override
  ConsumerState<ReviewForm> createState() => ReviewFormState();
}

class ReviewFormState extends ConsumerState<ReviewForm> {
  late final List<ResultEntry> _entries;
  late DateTime? _date = widget.upload.extracted!.reportDate;
  String _lab = '';
  bool _saving = false;

  /// Unrecognised lines not yet added as custom tests.
  late final List<UnrecognisedRow> _unadded = [
    ...widget.upload.extracted!.unrecognisedRows
  ];

  @override
  void initState() {
    super.initState();
    final all = [
      for (final row in widget.upload.extracted!.results)
        if (widget.catalog.byId(row.testId) case final test?)
          ResultEntry.fromExtracted(test, row),
    ];
    // The ones to double-check first; the rest keep the report's panel order.
    _entries = [
      ...all.where((e) => e.needsReview),
      ...all.where((e) => !e.needsReview)
    ];
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  List<ResultEntry> get _included => _entries.where((e) => e.include).toList();

  bool _validate() {
    var ok = true;
    for (final e in _included) {
      e.errors = {};
      final lo = ResultEntry.parse(e.low.text),
          hi = ResultEntry.parse(e.high.text);
      if (ResultEntry.parse(e.value.text) == null)
        e.errors['value'] = 'Enter a number';
      if (lo != null && hi != null && lo > hi)
        e.errors['ref_high'] = 'Lower than “From”';
      ok &= e.errors.isEmpty;
    }
    setState(() {});
    return ok && _date != null;
  }

  Future<void> _save() async {
    if (_included.isEmpty)
      return showMessage(context, 'Tick at least one result to save');
    if (!_validate())
      return showMessage(context, 'Check the highlighted values');
    setState(() => _saving = true);
    final included = _included;
    try {
      final report = await ref.read(labUploadActionsProvider).confirm(
        widget.upload,
        date: _date!,
        labName: _lab,
        results: [
          for (final e in included)
            LabResultDraft.of(
              e.test,
              value: ResultEntry.parse(e.value.text)!,
              unit: e.unit,
              refLow: ResultEntry.parse(e.low.text),
              refHigh: ResultEntry.parse(e.high.text),
            ),
        ],
      );
      if (!mounted) return;
      showMessage(context, 'Saved ${LabFormat.results(report.resultCount)}');
      context.pushReplacement(Routes.labReport(report.id));
    } on ApiException catch (e) {
      setState(() {
        for (final f in e.fields.entries) {
          final parts = f.key.split('.');
          final i = parts.length == 3 ? int.tryParse(parts[1]) : null;
          if (i != null && i < included.length)
            included[i].errors[parts[2]] = f.value;
        }
      });
      if (mounted) showMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addUnrecognised(UnrecognisedRow row) => setState(() {
        _unadded.remove(row);
        // With the other results to check, at the top.
        _entries.insert(0, ResultEntry.fromUnrecognised(row));
      });

  Future<void> _addTest() async {
    final test = await showTestPicker(context,
        exclude: {for (final e in _entries) e.test.id});
    if (test != null) setState(() => _entries.add(ResultEntry(test)));
  }

  Widget _section(String title, String note) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: theme.textTheme.titleSmall
                ?.copyWith(color: theme.colorScheme.primary)),
        Text(note,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.upload.extracted!;
    final member = ref.watch(memberProvider(widget.upload.memberId));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ReviewNotices(
            extracted: ex,
            memberName: member?.name,
            fileName: widget.upload.fileName),
        AppDatePickerField(
          label: 'Report date',
          required: true,
          value: _date,
          allowFuture: false,
          errorText:
              _date == null ? 'Couldn’t read the date — choose it' : null,
          onChanged: (d) => setState(() => _date = d),
        ),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Lab name',
            placeholder: 'e.g. City Diagnostics',
            onChanged: (v) => _lab = v),
        const SizedBox(height: 16),
        for (final (i, e) in _entries.indexed) ...[
          if (i == 0 && e.needsReview)
            _section(
                'Check these (${_entries.where((x) => x.needsReview).length})',
                'We weren’t sure about the name, unit or range.'),
          if (!e.needsReview &&
              (i == 0 || _entries[i - 1].needsReview) &&
              e.printed != null)
            _section(
                'Looks fine (${_entries.where((x) => !x.needsReview && x.printed != null).length})',
                'Still worth a quick look against the report.'),
          ResultEntryCard(
            key: ObjectKey(e),
            entry: e,
            onChanged: () => setState(() => e.errors = {}),
            onRemove: () => setState(() => _entries.remove(e)),
            onInclude:
                e.printed == null ? null : (v) => setState(() => e.include = v),
          ),
        ],
        OutlinedButton.icon(
          onPressed: _saving ? null : _addTest,
          icon: const Icon(Icons.add),
          label: const Text('Add a test that was missed'),
        ),
        UnrecognisedList(
            lines: ex.unrecognisedRows.isEmpty ? ex.unrecognised : const [],
            rows: _unadded,
            onAdd: _addUnrecognised),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
                  'Save ${_included.length} result${_included.length == 1 ? '' : 's'}'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
