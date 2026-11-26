import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/health_records/config/module_screen_config.dart';
import '../models/health_record.dart';
import 'module_providers.dart';

/// Looks up a single record by id across every family member's copy of a
/// module's provider.
///
/// The `/health/:moduleKey/detail/:recordId` route doesn't carry a
/// memberId (existing call sites — [GenericListScreen], the home
/// timeline — only know the module and record id), so there's no direct
/// way to go straight to the right family-parameterised provider. With a
/// small mock family this linear scan is cheap and, unlike guessing,
/// never shows the wrong person's record.
HealthRecord? findRecordById(WidgetRef ref, String moduleKey, int recordId) {
  final config = ModuleScreenConfig.getConfig(moduleKey);
  final members = ref.watch(familyMembersProvider);
  for (final member in members) {
    final state = ref.watch(config.getProvider(member.id));
    final records = state.records.valueOrNull;
    if (records == null) continue;
    for (final record in records) {
      if (record.id == recordId) return record;
    }
  }
  return null;
}
