import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';

/// Runs a sign-in. If the account is waiting to be deleted, asks whether to
/// restore it and, if so, signs in again with `restore: true`.
Future<void> signInWithRestore(
  BuildContext context,
  Future<void> Function(bool restore) signIn,
) async {
  try {
    await signIn(false);
  } on ApiException catch (e) {
    if (e.code != 'account_pending_deletion' || !context.mounted) rethrow;
    final purgeAfter =
        DateTime.tryParse(e.fields['purge_after'] ?? '')?.toLocal();
    if (await _askToRestore(context, purgeAfter)) await signIn(true);
  }
}

Future<bool> _askToRestore(BuildContext context, DateTime? purgeAfter) async {
  final when = purgeAfter == null
      ? 'soon'
      : 'on ${DateFormat('d MMMM yyyy').format(purgeAfter)}';
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Restore your account?'),
      content: Text(
        'You asked to delete this account. Everything in it will be removed for good $when.\n\n'
        'Restore it to keep your family’s records and carry on using Health Keeper.',
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep it deleted')),
        FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Restore account')),
      ],
    ),
  );
  return ok == true;
}
