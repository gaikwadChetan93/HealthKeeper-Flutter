import 'package:flutter/material.dart';

import '../../../core/models/privacy_notice.dart';
import '../../../core/state/privacy_providers.dart';

/// The itemised privacy notice: what we keep and why, sharing, your rights, and how to
/// withdraw or complain, with links to the full policies.
class PrivacyNoticeView extends StatelessWidget {
  final PrivacyNotice notice;

  const PrivacyNoticeView({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    Widget section(String title, List<Widget> children, {bool open = false}) =>
        ExpansionTile(
          initiallyExpanded: open,
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text(title, style: theme.textTheme.titleSmall),
          children: children,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(notice.summary, style: muted),
        const SizedBox(height: 8),
        section('What we keep and why', open: true, [
          for (final i in notice.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(i.data,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(i.purpose, style: muted),
                  ]),
            ),
          Text(notice.sharing, style: muted),
        ]),
        section('Your rights', [
          for (final r in notice.rights)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('•  ', style: muted),
                Expanded(child: Text(r, style: muted)),
              ]),
            ),
        ]),
        section('Withdrawing consent and complaints', [
          Text(notice.withdraw, style: muted),
          const SizedBox(height: 8),
          Text(notice.complain, style: muted),
        ]),
        const SizedBox(height: 4),
        Text(notice.notMedicalAdvice, style: muted),
        const SizedBox(height: 8),
        Wrap(spacing: 4, children: [
          for (final (key, label) in const [
            ('privacy', 'Privacy Policy'),
            ('terms', 'Terms of Service'),
            ('health-data', 'Health Data Policy'),
          ])
            TextButton(
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4)),
              onPressed: () => openPolicy(context, notice, key),
              child: Text(label),
            ),
        ]),
      ],
    );
  }
}
