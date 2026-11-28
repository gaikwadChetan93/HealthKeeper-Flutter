import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/lab_upload.dart';
import '../../../core/state/lab_upload_providers.dart';
import '../../../core/widgets/load_error_view.dart';

/// Password-protected PDFs: the password opens the file once and is not stored.
class UploadPasswordForm extends ConsumerStatefulWidget {
  final LabUpload upload;
  const UploadPasswordForm({super.key, required this.upload});

  @override
  ConsumerState<UploadPasswordForm> createState() => _UploadPasswordFormState();
}

class _UploadPasswordFormState extends ConsumerState<UploadPasswordForm> {
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_password.text.isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(labUploadActionsProvider)
          .unlock(widget.upload, _password.text);
    } catch (e) {
      if (mounted) showMessage(context, '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wrong = widget.upload.errorCode == 'wrong_password';
    return Center(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.lock_outline,
                size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('This PDF is password protected',
                style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(widget.upload.errorMessage ?? '', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(
              controller: _password,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: 'PDF password',
                  errorText: wrong ? 'That didn’t work' : null),
              onSubmitted: (_) => _open(),
            ),
            const SizedBox(height: 8),
            Text('Used once to open the file, never stored.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _open,
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Open'),
            ),
          ]),
    );
  }
}
