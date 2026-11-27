import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../auth/auth_controller.dart';
import '../models/member.dart';
import '../models/record_item.dart';
import 'doctor_providers.dart';
import 'vitals_providers.dart';

// ─── Family members ───────────────────────────────────────────

final membersProvider =
    AsyncNotifierProvider<MembersNotifier, List<Member>>(MembersNotifier.new);

class MembersNotifier extends AsyncNotifier<List<Member>> {
  ApiClient get _api => ref.read(apiClientProvider);

  @override
  Future<List<Member>> build() async {
    // Reload whenever the signed-in account changes.
    ref.watch(authProvider.select((s) => s.me?.id));
    final data = await _api.get('/v1/members') as Map<String, dynamic>;
    return [
      for (final j in data['items'] as List)
        Member.fromJson(j as Map<String, dynamic>)
    ];
  }

  Future<Member> create(Map<String, dynamic> body,
      {required String idempotencyKey}) async {
    final m = Member.fromJson(await _api.post('/v1/members',
        body: body, idempotencyKey: idempotencyKey) as Map<String, dynamic>);
    await _changed(selfChanged: m.isSelf);
    return m;
  }

  Future<void> edit(Member member, Map<String, dynamic> changes) async {
    await _api.patch('/v1/members/${member.id}',
        body: changes, version: member.version);
    await _changed();
  }

  Future<void> remove(Member member) async {
    await _api.delete('/v1/members/${member.id}');
    await _changed();
  }

  Future<void> _changed({bool selfChanged = false}) async {
    ref.invalidateSelf();
    if (selfChanged) await ref.read(authProvider.notifier).reloadMe();
    await future;
  }
}

final memberProvider = Provider.family<Member?, String>((ref, id) {
  return ref
      .watch(membersProvider)
      .valueOrNull
      ?.where((m) => m.id == id)
      .firstOrNull;
});

// ─── Records: one list per (member, module) ──────────────────

typedef RecordsKey = ({String memberId, String module, String query});

class RecordsPage {
  final List<RecordItem> items;
  final String? nextCursor;
  final bool loadingMore;

  const RecordsPage(this.items, this.nextCursor, {this.loadingMore = false});
}

final recordsProvider = AsyncNotifierProvider.autoDispose
    .family<RecordsNotifier, RecordsPage, RecordsKey>(RecordsNotifier.new);

class RecordsNotifier
    extends AutoDisposeFamilyAsyncNotifier<RecordsPage, RecordsKey> {
  @override
  Future<RecordsPage> build(RecordsKey key) => _page(null);

  Future<RecordsPage> _page(String? cursor) async {
    final data = await ref
        .read(apiClientProvider)
        .get('/v1/members/${arg.memberId}/records', query: {
      'module': arg.module,
      'q': arg.query,
      'cursor': cursor,
      'limit': '30',
    }) as Map<String, dynamic>;
    return RecordsPage(
      [
        for (final j in data['items'] as List)
          RecordItem.fromJson(j as Map<String, dynamic>)
      ],
      data['next_cursor'] as String?,
    );
  }

  /// Fetches the next page when the list is scrolled to the end.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.nextCursor == null || current.loadingMore)
      return;
    state = AsyncData(
        RecordsPage(current.items, current.nextCursor, loadingMore: true));
    try {
      final next = await _page(current.nextCursor);
      state = AsyncData(
          RecordsPage([...current.items, ...next.items], next.nextCursor));
    } catch (_) {
      state = AsyncData(RecordsPage(current.items, current.nextCursor));
    }
  }
}

final recordProvider =
    FutureProvider.autoDispose.family<RecordItem, String>((ref, id) async {
  return RecordItem.fromJson(await ref
      .read(apiClientProvider)
      .get('/v1/records/$id') as Map<String, dynamic>);
});

/// Record count per module for a member, for the overview grid.
final summaryProvider = FutureProvider.autoDispose
    .family<Map<String, int>, String>((ref, memberId) async {
  final data = await ref
      .read(apiClientProvider)
      .get('/v1/members/$memberId/summary') as Map<String, dynamic>;
  return {
    for (final m in data['modules'] as List)
      (m as Map)['module'] as String: m['count'] as int,
  };
});

/// Saving, changing and deleting records; refreshes the screens that show them.
final recordActionsProvider = Provider((ref) => RecordActions(ref));

class RecordActions {
  final Ref _ref;
  const RecordActions(this._ref);

  ApiClient get _api => _ref.read(apiClientProvider);

  Future<RecordItem> create(
      String memberId, String module, Map<String, dynamic> payload,
      {required String idempotencyKey, String? doctorId}) async {
    final r =
        RecordItem.fromJson(await _api.post('/v1/members/$memberId/records',
            body: {
              'module': module,
              'payload': payload,
              if (doctorId != null) 'doctor_id': doctorId,
            },
            idempotencyKey: idempotencyKey) as Map<String, dynamic>);
    _refresh(r);
    return r;
  }

  /// With [linkDoctor], sends [doctorId] (null unlinks the saved doctor).
  Future<RecordItem> update(RecordItem record, Map<String, dynamic> payload,
      {bool linkDoctor = false, String? doctorId}) async {
    final r = RecordItem.fromJson(await _api.patch('/v1/records/${record.id}',
        body: {'payload': payload, if (linkDoctor) 'doctor_id': doctorId},
        version: record.version) as Map<String, dynamic>);
    _refresh(r);
    return r;
  }

  Future<void> delete(RecordItem record) async {
    await _api.delete('/v1/records/${record.id}');
    _refresh(record);
  }

  void _refresh(RecordItem r) {
    _ref.invalidate(recordsProvider);
    _ref.invalidate(recordProvider(r.id));
    _ref.invalidate(summaryProvider(r.memberId));
    _ref.invalidate(vitalsSummaryProvider(r.memberId));
    _ref.invalidate(doctorsProvider); // record counts per doctor
    _ref.invalidate(doctorRecordsProvider);
    _ref.invalidate(vitalSeriesProvider);
  }
}
