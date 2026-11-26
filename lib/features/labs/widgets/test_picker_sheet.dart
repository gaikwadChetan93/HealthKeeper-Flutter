import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/lab.dart';
import '../../../core/state/lab_providers.dart';
import 'suggest_test_dialog.dart';

/// Search the test list by name or by what labs print (e.g. "SGPT", "FBS").
Future<LabTestDef?> showTestPicker(BuildContext context,
    {Set<String> exclude = const {}}) {
  return showModalBottomSheet<LabTestDef>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(
        heightFactor: 0.9, child: _TestPicker(exclude: exclude)),
  );
}

class _TestPicker extends ConsumerStatefulWidget {
  final Set<String> exclude;
  const _TestPicker({required this.exclude});

  @override
  ConsumerState<_TestPicker> createState() => _TestPickerState();
}

class _TestPickerState extends ConsumerState<_TestPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalog = ref.watch(labCatalogProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(
                hintText: 'Search tests, e.g. HbA1c, SGPT, TSH',
                prefixIcon: Icon(Icons.search)),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: catalog.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (c) {
              final tests = c.tests
                  .where((t) =>
                      !widget.exclude.contains(t.id) && t.matches(_query))
                  .toList();
              final rows = <Widget>[];
              for (final cat in c.categories) {
                final inCat = tests.where((t) => t.category == cat).toList();
                if (inCat.isEmpty) continue;
                rows.add(Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(cat,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: theme.colorScheme.primary)),
                ));
                for (final t in inCat) {
                  rows.add(ListTile(
                    dense: true,
                    title: Text(t.name),
                    subtitle: t.aliases.isEmpty
                        ? null
                        : Text(t.aliases.take(3).join(' · '), maxLines: 1),
                    trailing: Text(t.unit, style: theme.textTheme.labelSmall),
                    onTap: () => Navigator.pop(context, t),
                  ));
                }
              }
              rows.add(ListTile(
                leading: const Icon(Icons.add_comment_outlined),
                title: const Text('Can’t find your test?'),
                subtitle: const Text('Suggest it and we’ll add it'),
                onTap: () =>
                    showSuggestTestDialog(context, ref, initialName: _query),
              ));
              return ListView(children: rows);
            },
          ),
        ),
      ],
    );
  }
}
