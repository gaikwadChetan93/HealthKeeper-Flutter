import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/domain_config.dart';
import '../../../core/records/record_format.dart';
import '../../../core/state/doctor_providers.dart';
import '../../../core/widgets/generic_record_card.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../widgets/doctor_card.dart';

/// One doctor: contact details, and every visit, appointment and prescription
/// with them across the family (filter by family member).
class DoctorDetailScreen extends ConsumerStatefulWidget {
  final String doctorId;

  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  ConsumerState<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends ConsumerState<DoctorDetailScreen> {
  String? _member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doctor = ref.watch(doctorProvider(widget.doctorId));
    final history = ref.watch(doctorRecordsProvider(widget.doctorId));
    final muted = theme.textTheme.bodyMedium
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Scaffold(
      body: Column(children: [
        StandardAppHeader(
          title: 'Doctor',
          onBack: () => context.pop(),
          actions: [
            if (doctor != null)
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => context.push(Routes.editDoctor(doctor.id)),
              ),
          ],
        ),
        if (doctor == null)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child:
                ListView(padding: const EdgeInsets.only(bottom: 32), children: [
              Padding(
                padding: const EdgeInsets.all(AppDimens.spacingL),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.name,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      if (doctor.subtitle.isNotEmpty)
                        Text(doctor.subtitle, style: muted),
                      if (doctor.notes != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(doctor.notes!,
                              style: theme.textTheme.bodyMedium),
                        ),
                      if (doctor.phone != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: FilledButton.icon(
                            onPressed: () => callDoctor(context, doctor),
                            icon: const Icon(Icons.phone),
                            label: Text('Call ${doctor.phone}'),
                          ),
                        ),
                    ]),
              ),
              ...history.when(
                loading: () => [
                  const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()))
                ],
                error: (e, _) => [
                  LoadErrorView(
                      error: e,
                      onRetry: () => ref.invalidate(doctorRecordsProvider))
                ],
                data: (items) => _history(context, items, doctor.name),
              ),
            ]),
          ),
      ]),
    );
  }

  /// "Ravi Sharma · City Heart Clinic · 10:10", leaving out the doctor's own name.
  String _detail(DomainConfig config, DoctorRecord i, String doctorName) {
    final title = RecordFormat.title(config, i.record);
    return [
      i.memberName,
      if (title != doctorName && title != config.domainName) title,
      RecordFormat.subtitle(config, i.record),
    ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
  }

  List<Widget> _history(
      BuildContext context, List<DoctorRecord> items, String doctorName) {
    final theme = Theme.of(context);
    final members = {for (final i in items) i.memberName}.toList()..sort();
    final shown = _member == null
        ? items
        : items.where((i) => i.memberName == _member).toList();
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text('History',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
      ),
      if (items.isEmpty)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Nothing linked yet. When you add a visit, appointment or prescription, pick this doctor in the '
            'doctor field and it will show here.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      if (members.length > 1)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(spacing: 8, children: [
            ChoiceChip(
                label: const Text('Everyone'),
                selected: _member == null,
                showCheckmark: false,
                onSelected: (_) => setState(() => _member = null)),
            for (final m in members)
              ChoiceChip(
                  label: Text(m),
                  selected: _member == m,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _member = m)),
          ]),
        ),
      for (final i in shown)
        if (ModuleRegistry.getModuleByKey(i.record.module) case final config?)
          GenericRecordCard(
            title: config.domainName,
            subtitle: _detail(config, i, doctorName),
            date: i.record.recordDate,
            icon: config.icon,
            moduleKey: i.record.module,
            onTap: () =>
                context.push(Routes.healthDetail(i.record.module, i.record.id)),
          ),
    ];
  }
}
