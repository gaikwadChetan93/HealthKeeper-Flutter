import 'package:flutter/material.dart';

import '../../../core/models/lab.dart';

/// A test that isn't in the list: the person names it (and its unit) themselves.
/// Its value is saved exactly as typed and flagged only against the report's range.
Future<LabTestDef?> showCustomTestDialog(BuildContext context,
    {String initialName = '', String initialUnit = ''}) {
  return showDialog<LabTestDef>(
    context: context,
    builder: (_) =>
        _CustomTestDialog(initialName: initialName, initialUnit: initialUnit),
  );
}

class _CustomTestDialog extends StatefulWidget {
  final String initialName;
  final String initialUnit;

  const _CustomTestDialog(
      {required this.initialName, required this.initialUnit});

  @override
  State<_CustomTestDialog> createState() => _CustomTestDialogState();
}

class _CustomTestDialogState extends State<_CustomTestDialog> {
  // Owned here so they live until the dialog has finished closing.
  late final _name = TextEditingController(text: widget.initialName.trim());
  late final _unit = TextEditingController(text: widget.initialUnit.trim());
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    super.dispose();
  }

  void _add() {
    if (_name.text.trim().length < 2) {
      setState(() => _error = 'Enter the test name');
      return;
    }
    Navigator.pop(context, LabTestDef.custom(_name.text, unit: _unit.text));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add your own test'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Use the name as printed on your report. The value is saved as you type it. '
                'Results with the same name and unit are shown as one trend.'),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration:
                  InputDecoration(labelText: 'Test name', errorText: _error),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _unit,
              decoration: const InputDecoration(
                  labelText: 'Unit (optional)', hintText: 'e.g. U/mL'),
              onSubmitted: (_) => _add(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(onPressed: _add, child: const Text('Add')),
      ],
    );
  }
}
