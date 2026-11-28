import 'package:flutter/material.dart';

/// When adding someone else: the permission you have to keep their health records.
/// Stored with the date; the relative can still ask us to show or delete their records.
class AttestationChoice extends StatelessWidget {
  final String? value;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const AttestationChoice(
      {super.key,
      required this.value,
      required this.onChanged,
      this.errorText});

  static const options = [
    ('agreed', 'They agreed to me keeping their health records'),
    ('carer', 'I’m their carer and keep their records to look after them'),
    (
      'legal_representative',
      'I’m their legal representative (for example, power of attorney)'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your permission to keep their records\u00A0*',
            style: theme.textTheme.titleSmall),
        const SizedBox(height: 2),
        Text('They must be 18 or older. Choose what applies.', style: muted),
        RadioGroup<String>(
          groupValue: value,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          child: Column(children: [
            for (final (key, label) in options)
              RadioListTile<String>(
                value: key,
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(label),
              ),
          ]),
        ),
        if (errorText != null)
          Text(errorText!,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
            'Their records are kept only for you. They can ask us to show or delete them, '
            'and if they don’t want them kept, they must be deleted.',
            style: muted),
      ],
    );
  }
}
