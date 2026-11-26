import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_typography.dart';

/// The redesign's full-width CTA button: solid brand green with a soft
/// under-glow shadow, or (when [secondary] is true) a white bordered variant
/// used for the paired action next to a primary CTA (e.g. "Skip", "Not now").
class HkPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool destructive;
  final bool loading;
  final bool expand;
  final IconData? icon;

  const HkPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.destructive = false,
    this.loading = false,
    this.expand = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;

    final Color bg;
    final Color fg;
    final Border? border;
    final List<BoxShadow>? shadow;

    if (destructive) {
      bg = AppColors.surface;
      fg = AppColors.error;
      border = Border.all(color: AppColors.errorBorder);
      shadow = null;
    } else if (secondary) {
      bg = AppColors.surface;
      fg = AppColors.textMuted5;
      border = Border.all(color: AppColors.border);
      shadow = null;
    } else {
      bg = AppColors.primary;
      fg = AppColors.onPrimary;
      border = null;
      shadow = AppShadows.primaryGlow;
    }

    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
        ],
        Text(label, style: AppTypography.button.copyWith(color: fg)),
      ],
    );

    return Opacity(
      opacity: disabled && onPressed == null ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
          child: Container(
            width: expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppDimens.radiusTileS),
              border: border,
              boxShadow: shadow,
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
