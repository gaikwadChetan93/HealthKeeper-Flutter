import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../auth/auth_controller.dart';
import '../models/doctor.dart';
import '../models/record_item.dart';

/// The family's doctors, by name.
final doctorsProvider =
    AsyncNotifierProvider<DoctorsNotifier, List<Doctor>>(DoctorsNotifier.new);

class DoctorsNotifier extends AsyncNotifier<List<Doctor>> {
  ApiClient get _api => ref.read(apiClientProvider);

  @override
  Future<List<Doctor>> build() async {
    ref.watch(
        authProvider.select((s) => s.me?.id)); // reload for another account
    final data = await _api.get('/v1/doctors') as Map<String, dynamic>;
    return [
      for (final j in data['items'] as List)
        Doctor.fromJson(j as Map<String, dynamic>)
    ];
  }

  Future<Doctor> create(Map<String, dynamic> body) async {
    final d = Doctor.fromJson(await _api.post('/v1/doctors',
        body: body,
        idempotencyKey: ApiClient.newIdempotencyKey()) as Map<String, dynamic>);
    ref.invalidateSelf();
    return d;
  }

  Future<void> edit(Doctor d, Map<String, dynamic> changes) async {
    await _api.patch('/v1/doctors/${d.id}', body: changes, version: d.version);
    ref.invalidateSelf();
  }

  Future<void> remove(Doctor d) async {
    await _api.delete('/v1/doctors/${d.id}');
    ref.invalidateSelf();
  }
}

final doctorProvider = Provider.family<Doctor?, String>((ref, id) {
  return ref
      .watch(doctorsProvider)
      .valueOrNull
      ?.where((d) => d.id == id)
      .firstOrNull;
});

/// A record in a doctor's history, with the family member it was for.
typedef DoctorRecord = ({RecordItem record, String memberName});

final doctorRecordsProvider = FutureProvider.autoDispose
    .family<List<DoctorRecord>, String>((ref, id) async {
  final data = await ref.read(apiClientProvider).get('/v1/doctors/$id/records')
      as Map<String, dynamic>;
  return [
    for (final j in data['items'] as List)
      (
        record: RecordItem.fromJson(j as Map<String, dynamic>),
        memberName: j['member_name'] as String
      ),
  ];
});
