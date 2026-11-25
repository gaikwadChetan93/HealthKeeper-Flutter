import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';

/// Shown when the plan's family-member limit is reached (API code plan_limit).
void showMemberLimitDialog(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Family member limit reached'),
      content: Text('$message. Upgrade to add more family members.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(c), child: const Text('Not now')),
        FilledButton(
          onPressed: () {
            Navigator.pop(c);
            context.push(Routes.paywall);
          },
          child: const Text('See plans'),
        ),
      ],
    ),
  );
}

/// Asks before deleting a family member and their records.
Future<bool> confirmDeleteMember(BuildContext context, String name) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text('Delete $name?'),
      content: const Text(
          'Their health records will be deleted too. This can’t be undone after 30 days.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(c).colorScheme.error),
          onPressed: () => Navigator.pop(c, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return ok == true;
}
