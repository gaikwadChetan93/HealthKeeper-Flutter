import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/lab_upload.dart';
import '../../../core/state/lab_upload_providers.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../widgets/upload_password_form.dart';

/// Shows a report being read: processing, then complete (or what went wrong).
class UploadStatusScreen extends ConsumerWidget {
  final String uploadId;

  const UploadStatusScreen({super.key, required this.uploadId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upload = ref.watch(labUploadProvider(uploadId));
    return Scaffold(
      body: Column(children: [
        StandardAppHeader(title: 'Lab Report', onBack: () => context.pop()),
        Expanded(
          child: upload.when(
            skipLoadingOnRefresh: true,
            loading: () => const _Processing(),
            error: (e, _) => LoadErrorView(
                error: e,
                onRetry: () => ref.invalidate(labUploadProvider(uploadId))),
            data: (up) => Padding(
              padding: const EdgeInsets.all(24),
              child: switch (up.status) {
                'processing' => const _Processing(),
                'ready' => _Complete(upload: up),
                'needs_password' => UploadPasswordForm(upload: up),
                'saved' => _Saved(upload: up),
                _ => _Failed(upload: up),
              },
            ),
          ),
        ),
      ]),
    );
  }
}

class _Processing extends StatelessWidget {
  const _Processing();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(strokeWidth: 4)),
        const SizedBox(height: 24),
        Text('Reading your report…', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Finding each test, its value and the range printed by the lab. This usually takes a few seconds.\n\n'
          'You can leave this screen — the report stays in Lab Results until you save it.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ]),
    );
  }
}

class _Complete extends StatelessWidget {
  final LabUpload upload;
  const _Complete({required this.upload});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ex = upload.extracted!;
    final review = ex.results.where((r) => r.needsReview).length;
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle, size: 64, color: AppColors.zoneNormal),
        const SizedBox(height: 16),
        Text('Complete',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          ex.results.isEmpty
              ? 'We couldn’t find test results we recognise in this report. You can add them yourself.'
              : 'Found ${ex.results.length} results${review > 0 ? ', $review to double-check' : ''}. '
                  'Check the values, correct anything that’s wrong, then save.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () =>
              context.pushReplacement(Routes.labUploadReview(upload.id)),
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Review results'),
        ),
      ]),
    );
  }
}

class _Saved extends StatelessWidget {
  final LabUpload upload;
  const _Saved({required this.upload});

  @override
  Widget build(BuildContext context) => Center(
        child: FilledButton(
          onPressed: () =>
              context.pushReplacement(Routes.labReport(upload.reportId!)),
          child: const Text('This report is saved — open it'),
        ),
      );
}

class _Failed extends ConsumerWidget {
  final LabUpload upload;
  const _Failed({required this.upload});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text('Couldn’t read this report', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(upload.errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () =>
              context.pushReplacement(Routes.labAdd(upload.memberId)),
          child: const Text('Type in results instead'),
        ),
        TextButton(
          onPressed: () async {
            await ref.read(labUploadActionsProvider).discard(upload);
            if (context.mounted) context.pop();
          },
          child: const Text('Remove this upload'),
        ),
      ]),
    );
  }
}
