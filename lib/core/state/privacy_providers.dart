import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_config.dart';
import '../auth/auth_controller.dart';
import '../models/privacy_notice.dart';

/// The privacy notice; the same for everyone, so it's read without signing in.
final privacyNoticeProvider =
    FutureProvider.autoDispose<PrivacyNotice>((ref) async {
  final data =
      await ref.read(apiClientProvider).get('/v1/public/privacy-notice');
  return PrivacyNotice.fromJson(data as Map<String, dynamic>);
});

/// What this person has agreed to: purpose -> granted.
final consentsProvider =
    FutureProvider.autoDispose<Map<String, bool>>((ref) async {
  final data = await ref.read(authProvider.notifier).consents();
  return {
    for (final c in data['consents'] as List)
      (c as Map)['purpose'] as String: c['granted'] as bool,
  };
});

/// Consent purposes, as the API names them.
abstract final class ConsentPurpose {
  static const healthData = 'health_data_processing';
  static const terms = 'terms_of_service';
  static const privacy = 'privacy_policy';
  static const analytics = 'product_analytics';
}

/// Opens a policy page ("privacy", "terms", "health-data") in the browser.
Future<void> openPolicy(
    BuildContext context, PrivacyNotice notice, String key) async {
  final link = notice.links[key];
  if (link == null) return;
  final url =
      Uri.parse(link.startsWith('http') ? link : '${ApiConfig.baseUrl}$link');
  final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Couldn’t open $url')));
  }
}
