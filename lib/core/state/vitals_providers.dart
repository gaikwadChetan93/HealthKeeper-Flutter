import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import '../auth/auth_controller.dart';
import '../models/chart_models.dart';
import '../models/vital_series.dart';

/// The phone's time zone (e.g. "Asia/Kolkata"), so "a day" on a chart is the person's day.
final deviceTimeZoneProvider = FutureProvider<String>((ref) async {
  try {
    return (await FlutterTimezone.getLocalTimezone()).identifier;
  } catch (_) {
    return 'UTC';
  }
});

/// The vitals dashboard for a member: one card per vital, over the last 30 days.
final vitalsSummaryProvider = FutureProvider.autoDispose
    .family<List<VitalSummary>, String>((ref, memberId) async {
  final tz = await ref.watch(deviceTimeZoneProvider.future);
  final data = await ref.read(apiClientProvider).get(
      '/v1/members/$memberId/vitals/summary',
      query: {'days': '30', 'tz': tz}) as Map<String, dynamic>;
  return [
    for (final c in data['vitals'] as List)
      VitalSummary.fromJson(c as Map<String, dynamic>)
  ];
});

typedef VitalSeriesKey = ({String memberId, String module, TimeRange range});

/// One vital's trend over the chosen range. The server groups readings by day,
/// week or month when there are many.
final vitalSeriesProvider = FutureProvider.autoDispose
    .family<VitalSeries, VitalSeriesKey>((ref, key) async {
  final tz = await ref.watch(deviceTimeZoneProvider.future);
  final days = key.range.days;
  final today = DateTime.now();
  final from = days == null
      ? null
      : DateTime(today.year, today.month, today.day - (days - 1));
  final data = await ref.read(apiClientProvider).get(
    '/v1/members/${key.memberId}/vitals/${key.module}/series',
    query: {'tz': tz, 'from': from?.toIso8601String().substring(0, 10)},
  ) as Map<String, dynamic>;
  return VitalSeries.fromJson(data);
});
