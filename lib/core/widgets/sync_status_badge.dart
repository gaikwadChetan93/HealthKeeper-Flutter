import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../models/sync_status.dart';

class SyncStatusBadge extends StatelessWidget {
  final SyncStatus status;

  const SyncStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      SyncStatus.synced => (Icons.cloud_done_outlined, AppColors.syncSuccess),
      SyncStatus.pending => (Icons.cloud_upload_outlined, AppColors.syncPending),
      SyncStatus.failed => (Icons.cloud_off_outlined, AppColors.syncFailed),
    };

    return Icon(icon, size: 16, color: color);
  }
}
