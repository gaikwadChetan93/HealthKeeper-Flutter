import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';

/// Pill-shaped chip used for filters, tags, categories and quick-pick
/// options throughout the redesign. Supports a selected state (solid brand
/// fill) and an unselected outline state, an optional leading icon, and a
/// dashed "add new" variant.
class HkChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final bool selected;
  final bool dashed;
  final VoidCallback? onTap;

  const HkChip({
    super.key,
    required this.label,
    this.icon,
    this.iconColor,
    this.selected = false,
    this.dashed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.primary : AppColors.surface;
    final fg = selected ? AppColors.onPrimary : AppColors.textMuted5;
    final border = selected ? AppColors.primary : AppColors.border;

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: dashed
            ? null
            : Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: iconColor ?? fg),
            const SizedBox(width: 6),
          ],
          Text(label, style: AppTypography.chip.copyWith(color: fg)),
        ],
      ),
    );

    final bordered = dashed
        ? CustomPaint(
            painter: const _DashedBorderPainter(
              radius: AppDimens.radiusPill,
              color: AppColors.borderDashed,
            ),
            child: chip,
          )
        : chip;

    if (onTap == null) return bordered;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: bordered,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double radius;
  final Color color;

  const _DashedBorderPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
