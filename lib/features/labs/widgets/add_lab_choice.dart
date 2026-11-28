import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_constants.dart';
import '../../../core/state/lab_upload_providers.dart';
import '../../../core/widgets/load_error_view.dart';

/// "Upload a report" (a PDF or a photo) or "Type in results".
Future<void> showAddLabChoice(
    BuildContext context, WidgetRef ref, String memberId) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (c) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.upload_file),
          title: const Text('Upload a report'),
          subtitle: const Text(
              'A PDF or a photo. We read the values for you to check'),
          onTap: () {
            Navigator.pop(c);
            uploadLabReport(context, ref, memberId);
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit_note),
          title: const Text('Type in results'),
          subtitle: const Text('From a paper report'),
          onTap: () {
            Navigator.pop(c);
            context.push(Routes.labAdd(memberId));
          },
        ),
      ]),
    ),
  );
}

/// Picks a PDF or an image (a photo or scan of the report), sends it, and opens the status screen while the server reads it.
Future<void> uploadLabReport(
    BuildContext context, WidgetRef ref, String memberId) async {
  final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp']);
  if (file == null || !context.mounted) return;
  final bytes = await file.readAsBytes();
  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(children: [
          SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4)),
          SizedBox(width: 18),
          Expanded(child: Text('Uploading report…')),
        ]),
      ),
    ),
  );
  try {
    final up = await ref
        .read(labUploadActionsProvider)
        .upload(memberId, bytes, file.name);
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    context.push(Routes.labUpload(up.id));
  } catch (e) {
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    showMessage(context, '$e');
  }
}
