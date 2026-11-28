import 'package:flutter/material.dart';

import '../../../core/models/lab.dart';

/// "About this test": what it measures and why it's checked, and on request what
/// results above or below the range can be seen with. General information from the
/// catalog, the same for everyone; never about the person's own result.
class LabTestAboutCard extends StatefulWidget {
  final LabTestAbout about;

  const LabTestAboutCard({super.key, required this.about});

  @override
  State<LabTestAboutCard> createState() => _LabTestAboutCardState();
}

class _LabTestAboutCardState extends State<LabTestAboutCard> {
  bool _more = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = widget.about;
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final hasMore = a.high != null || a.low != null;

    Widget part(String label, String text) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(height: 2),
            Text(text, style: theme.textTheme.bodyMedium),
          ]),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.info_outline,
                  size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('About this test', style: theme.textTheme.titleSmall),
            ]),
            const SizedBox(height: 8),
            Text(a.what, style: theme.textTheme.bodyMedium),
            part('Why it’s checked', a.why),
            if (_more) ...[
              if (a.high != null)
                part('Above the range can be seen with', a.high!),
              if (a.low != null)
                part('Below the range can be seen with', a.low!),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                    'General information about this test, not about your result. '
                    'Many things affect a single value; talk to your doctor about what yours means.',
                    style: muted),
              ),
            ],
            if (hasMore)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => setState(() => _more = !_more),
                  child: Text(_more ? 'Show less' : 'High and low results'),
                ),
              )
            else
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
