import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Shared header for every pushed (non-tab-root) screen — a round back
/// button, the screen title, and optional trailing actions on the app's
/// bone background, matching the redesign's floating-header screens
/// (record detail, vital entry, the generic form) rather than the old
/// solid gradient app bar.
class StandardAppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const StandardAppHeader({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 8),
      child: Row(
        children: [
          if (onBack != null) ...[
            _RoundIconButton(icon: Icons.arrow_back, onTap: onBack!),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTypography.detailTitle.copyWith(fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actions != null)
            IconTheme.merge(
              data: const IconThemeData(color: AppColors.textMuted5),
              child: Row(mainAxisSize: MainAxisSize.min, children: actions!),
            ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 36, height: 36, child: Icon(icon, size: 19, color: AppColors.textMuted5)),
      ),
    );
  }
}
