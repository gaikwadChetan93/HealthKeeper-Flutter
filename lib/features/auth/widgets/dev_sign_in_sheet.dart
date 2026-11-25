import 'package:flutter/material.dart';

typedef DevSignIn = ({String email, String name});

/// Debug builds only: pick a test account on the local backend. Different
/// emails are different accounts, which helps check that data stays separate.
Future<DevSignIn?> showDevSignInSheet(BuildContext context) {
  final email = TextEditingController(text: 'tester@example.com');
  final name = TextEditingController(text: 'Test User');
  return showModalBottomSheet<DevSignIn>(
    context: context,
    isScrollControlled: true,
    builder: (c) => Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, 24 + MediaQuery.of(c).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Developer sign-in', style: Theme.of(c).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
              'Works only against a backend running locally (HK_ENV=local).'),
          const SizedBox(height: 16),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pop(
                c, (email: email.text.trim(), name: name.text.trim())),
            child: const Text('Sign in'),
          ),
        ],
      ),
    ),
  );
}
