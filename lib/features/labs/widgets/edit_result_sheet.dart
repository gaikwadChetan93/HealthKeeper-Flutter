import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/models/lab.dart';
import '../../../core/state/lab_providers.dart';
import '../../../core/widgets/load_error_view.dart';
import '../lab_format.dart';
import 'result_entry_card.dart';

/// Correct a value or its report range, or delete the result.
Future<void> showEditResultSheet(BuildContext context, LabResultItem r) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _EditResult(result: r),
  );
}

class _EditResult extends ConsumerStatefulWidget {
  final LabResultItem result;
  const _EditResult({required this.result});

  @override
  ConsumerState<_EditResult> createState() => _EditResultState();
}

class _EditResultState extends ConsumerState<_EditResult> {
  late final _value =
      TextEditingController(text: LabFormat.number(widget.result.value, 4));
  late final _low = TextEditingController(
      text: widget.result.refLow == null
          ? ''
          : LabFormat.number(widget.result.refLow!, 4));
  late final _high = TextEditingController(
      text: widget.result.refHigh == null
          ? ''
          : LabFormat.number(widget.result.refHigh!, 4));
  String? _error;
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      setState(() => _error = e.fields.values.firstOrNull ?? e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final actions = ref.read(labActionsProvider);
    const number = TextInputType.numberWithOptions(decimal: true);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(r.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
              controller: _value,
              keyboardType: number,
              decoration: InputDecoration(labelText: 'Result (${r.unit})')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: TextField(
                    controller: _low,
                    keyboardType: number,
                    decoration:
                        const InputDecoration(labelText: 'Report range from'))),
            const SizedBox(width: 12),
            Expanded(
                child: TextField(
                    controller: _high,
                    keyboardType: number,
                    decoration: const InputDecoration(labelText: 'to'))),
          ]),
          if (_error != null)
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error))),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy
                ? null
                : () {
                    final v = ResultEntry.parse(_value.text);
                    if (v == null) {
                      return setState(() => _error = 'Enter a number');
                    }
                    _run(() => actions.updateResult(r,
                        value: v,
                        unit: r.unit,
                        refLow: ResultEntry.parse(_low.text),
                        refHigh: ResultEntry.parse(_high.text)));
                  },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: _busy
                ? null
                : () => _run(() async {
                      await actions.deleteResult(r);
                      if (context.mounted) {
                        showMessage(context, 'Result deleted');
                      }
                    }),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete this result'),
          ),
        ],
      ),
    );
  }
}
