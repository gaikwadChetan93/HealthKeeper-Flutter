import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/record_category_colors.dart';
import '../../../core/config/module_registry.dart';
import '../../../core/models/domain_config.dart';
import '../../../core/models/health_record.dart';
import '../../health_records/config/module_screen_config.dart';

/// One entry in the Home tab's "recent activity" timeline.
class TimelineEntry {
  final String moduleKey;
  final int recordId;
  final String title;
  final String? subtitle;
  final DateTime date;
  final IconData icon;
  final Color hue;

  const TimelineEntry({
    required this.moduleKey,
    required this.recordId,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.hue,
  });
}

/// Builds a chronological activity feed across all "quick health" record
/// types for [memberId], newest first.
///
/// There's no real aggregation query behind this yet — each of the 10
/// quick-health modules is queried independently (as `module_providers.dart`
/// already does everywhere else) and merged client-side. That's fine
/// against mock data; a real backend will want a proper query for this
/// instead of fanning out to 10 providers. Flagged in the Phase 3→4
/// handoff notes.
List<TimelineEntry> watchHomeTimeline(WidgetRef ref, int memberId) {
  final entries = <TimelineEntry>[];

  for (final DomainConfig config in ModuleRegistry.quickHealthModules) {
    final screenConfig = ModuleScreenConfig.getConfig(config.domainKey);
    final state = ref.watch(screenConfig.getProvider(memberId));
    final records = state.records.valueOrNull;
    if (records == null) continue;

    final hue = RecordCategoryColors.getHue(config.domainKey);
    for (final HealthRecord record in records) {
      entries.add(TimelineEntry(
        moduleKey: config.domainKey,
        recordId: record.id,
        title: screenConfig.getTitle(record),
        subtitle: screenConfig.getSubtitle(record),
        date: screenConfig.getDate(record),
        icon: config.icon,
        hue: hue,
      ));
    }
  }

  entries.sort((a, b) => b.date.compareTo(a.date));
  return entries;
}

/// True while any of [memberId]'s quick-health module providers is still on
/// its initial (simulated) load. Home and Records both derive their
/// "nothing recorded yet" / first-run states from [watchHomeTimeline] being
/// empty — without this check that state would flash for the ~500ms the
/// mock loaders take, even for a person who already has records, every time
/// the app starts or the active person changes.
bool watchHomeTimelineLoading(WidgetRef ref, int memberId) {
  for (final DomainConfig config in ModuleRegistry.quickHealthModules) {
    final screenConfig = ModuleScreenConfig.getConfig(config.domainKey);
    if (ref.watch(screenConfig.getProvider(memberId)).records.isLoading) {
      return true;
    }
  }
  return false;
}
