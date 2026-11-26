import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/lab_upload.dart';
import '../../../core/state/lab_upload_providers.dart';

/// Reports uploaded but not yet saved: being read, ready to review, or stuck.
class PendingUploads extends ConsumerWidget {
  final String memberId;
  const PendingUploads({super.key, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items =
        ref.watch(labUploadsProvider(memberId)).valueOrNull ?? const [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(children: [for (final u in items) _UploadCard(upload: u)]);
  }
}

class _UploadCard extends StatelessWidget {
  final LabUpload upload;
  const _UploadCard({required this.upload});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (Widget lead, String status, Color color) = switch (upload.status) {
      'processing' => (
          const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4)),
          'Reading the report…',
          theme.colorScheme.primary
        ),
      'ready' => (
          const Icon(Icons.check_circle, color: AppColors.zoneNormal),
          'Complete · ${upload.resultCount} results to review',
          AppColors.zoneNormal
        ),
      'needs_password' => (
          Icon(Icons.lock_outline, color: theme.colorScheme.primary),
          'Needs the PDF password',
          theme.colorScheme.primary
        ),
      _ => (
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          'Couldn’t read this report',
          theme.colorScheme.error
        ),
    };
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ListTile(
        leading: lead,
        title:
            Text(upload.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(status,
            style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        trailing: upload.status == 'ready'
            ? const Text('Review')
            : const Icon(Icons.chevron_right),
        onTap: () => context.push(upload.status == 'ready'
            ? Routes.labUploadReview(upload.id)
            : Routes.labUpload(upload.id)),
      ),
    );
  }
}
