import 'package:flutter/material.dart';

import '../../app/theme/app_dimens.dart';

/// Shown when something couldn't be loaded, with a way to try again.
class LoadErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const LoadErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: AppDimens.spacingM),
            Text('$error',
                textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppDimens.spacingL),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );
}
