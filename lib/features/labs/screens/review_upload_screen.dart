import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/lab_upload.dart';
import '../../../core/state/lab_providers.dart';
import '../../../core/state/lab_upload_providers.dart';
import '../../../core/widgets/load_error_view.dart';
import '../../../core/widgets/standard_app_header.dart';
import '../widgets/review_form.dart';

/// Check what was read from an uploaded report, correct it, and save.
class ReviewUploadScreen extends ConsumerWidget {
  final String uploadId;

  const ReviewUploadScreen({super.key, required this.uploadId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upload = ref.watch(labUploadProvider(uploadId));
    final catalog = ref.watch(labCatalogProvider);
    final Widget body;
    if (upload.hasError || catalog.hasError) {
      body = LoadErrorView(
        error: upload.error ?? catalog.error!,
        onRetry: () => ref
          ..invalidate(labUploadProvider(uploadId))
          ..invalidate(labCatalogProvider),
      );
    } else if (!upload.hasValue || !catalog.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else if (upload.value!.status != 'ready') {
      body = Center(
          child: Text(
              'This report is ${upload.value!.status.replaceAll('_', ' ')}.'));
    } else {
      body = ReviewForm(upload: upload.value!, catalog: catalog.value!);
    }
    return Scaffold(
      body: Column(children: [
        StandardAppHeader(
          title: 'Review Results',
          onBack: () => context.pop(),
          actions: [
            if (upload.valueOrNull?.status == 'ready')
              IconButton(
                tooltip: 'Discard this upload',
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () => _discard(context, ref, upload.value!),
              ),
          ],
        ),
        Expanded(child: body),
      ]),
    );
  }

  Future<void> _discard(
      BuildContext context, WidgetRef ref, LabUpload up) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Discard this upload?'),
        content: const Text(
            'The PDF and what was read from it will be deleted. Nothing is saved.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Discard')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(labUploadActionsProvider).discard(up);
    if (context.mounted) context.pop();
  }
}
