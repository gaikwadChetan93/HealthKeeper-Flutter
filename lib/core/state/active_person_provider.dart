import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/family_member.dart';
import 'module_providers.dart';

/// The redesign's one structural change: which family member the app is
/// "currently managing" is app-level state, not a route parameter.
///
/// Every screen that used to require a `memberId` in its route can instead
/// read [activePersonProvider] and fall back to it when no id was supplied.
/// Existing family-parameterised providers (in `module_providers.dart`) are
/// untouched — screens keep calling them with an explicit id; this layer
/// just supplies that id by default so most call sites can drop the
/// parameter entirely.
const _prefsKey = 'active_person_id';

class ActivePersonIdNotifier extends StateNotifier<int?> {
  final Ref _ref;

  ActivePersonIdNotifier(this._ref) : super(null) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getInt(_prefsKey);
    final members = _ref.read(familyMembersProvider);

    final valid = storedId != null && members.any((m) => m.id == storedId);
    if (valid) {
      state = storedId;
    } else if (members.isNotEmpty) {
      state = members.first.id;
    }
  }

  /// Switch the active person and persist the choice.
  Future<void> setActivePerson(int memberId) async {
    state = memberId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, memberId);
  }
}

/// The raw active person id, or `null` until the persisted preference has
/// finished loading (falls back to the first family member once it has).
final activePersonIdProvider =
    StateNotifierProvider<ActivePersonIdNotifier, int?>(
  (ref) => ActivePersonIdNotifier(ref),
);

/// The active [FamilyMember] itself. Falls back to the first family member
/// while the persisted preference is still loading, and to `null` only when
/// there are no family members at all.
final activePersonProvider = Provider<FamilyMember?>((ref) {
  final members = ref.watch(familyMembersProvider);
  if (members.isEmpty) return null;

  final activeId = ref.watch(activePersonIdProvider);
  return members.where((m) => m.id == activeId).firstOrNull ?? members.first;
});

/// Convenience accessor for the common case of just needing the id, e.g. to
/// pass into an existing family-parameterised provider family.
final activePersonIdOrFallbackProvider = Provider<int>((ref) {
  final FamilyMember? person = ref.watch(activePersonProvider);
  final int id = person?.id ?? 0;
  return id;
});
