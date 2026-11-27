import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/models/doctor.dart';
import '../../../core/widgets/colored_avatar.dart';
import '../../../core/widgets/load_error_view.dart';

/// Opens the phone's dialler with the doctor's number.
Future<void> callDoctor(BuildContext context, Doctor d) async {
  final phone = d.phone?.replaceAll(RegExp(r'[^0-9+]'), '');
  if (phone == null || phone.isEmpty) return;
  final ok = await launchUrl(Uri(scheme: 'tel', path: phone));
  if (!ok && context.mounted) showMessage(context, 'Couldn’t open the dialler');
}

/// A doctor in the list: name, speciality and clinic, how often they appear in
/// records, and a call button.
class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final int colorIndex;
  final VoidCallback onTap;

  const DoctorCard(
      {super.key,
      required this.doctor,
      required this.onTap,
      this.colorIndex = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final d = doctor;
    final usage = d.recordCount == 0
        ? 'No records linked yet'
        : '${d.recordCount} record${d.recordCount == 1 ? '' : 's'}'
            '${d.lastRecordDate == null ? '' : ' · last ${DateFormat('d MMM yyyy').format(d.lastRecordDate!)}'}';
    return Card(
      elevation: AppDimens.elevationS,
      margin: const EdgeInsets.symmetric(
          horizontal: AppDimens.spacingL, vertical: AppDimens.spacingXS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingM),
          child: Row(children: [
            ColoredAvatar(
                name: d.name.replaceFirst(
                    RegExp(r'^dr\.?\s*', caseSensitive: false), ''),
                colorIndex: colorIndex,
                size: 48),
            const SizedBox(width: AppDimens.spacingM),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    if (d.subtitle.isNotEmpty) Text(d.subtitle, style: muted),
                    Text(usage, style: muted),
                  ]),
            ),
            if (d.phone != null)
              IconButton(
                tooltip: 'Call ${d.phone}',
                icon: Icon(Icons.phone_outlined,
                    color: theme.colorScheme.primary),
                onPressed: () => callDoctor(context, d),
              ),
          ]),
        ),
      ),
    );
  }
}
