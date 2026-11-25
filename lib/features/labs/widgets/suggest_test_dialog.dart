import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/lab_providers.dart';
import '../../../core/widgets/load_error_view.dart';

/// "Can't find your test?" — sent for review, then added to the list for everyone.
Future<void> showSuggestTestDialog(BuildContext context, WidgetRef ref,
    {String initialName = ''}) async {
  final name = TextEditingController(text: initialName);
  final unit = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Suggest a test'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              'Tell us the test name as printed on your report. We review suggestions and add them to the list.'),
          const SizedBox(height: 12),
          TextField(
              controller: name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Test name')),
          const SizedBox(height: 8),
          TextField(
              controller: unit,
              decoration: const InputDecoration(labelText: 'Unit (optional)')),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(c, true), child: const Text('Send')),
      ],
    ),
  );
  if (ok != true || name.text.trim().length < 2 || !context.mounted) return;
  try {
    await ref.read(labActionsProvider).suggestTest(name.text, unit: unit.text);
    if (context.mounted) {
      showMessage(context, 'Thanks — we’ll review “${name.text.trim()}”');
    }
  } catch (e) {
    if (context.mounted) showMessage(context, '$e');
  }
}
