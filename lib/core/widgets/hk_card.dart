import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_shadows.dart';

/// The redesign's base card: white surface, hairline border, soft ambient
/// shadow, large rounded corners. Used anywhere the design shows a floating
/// white panel on the bone background — stat strips, list tiles, empty
/// states, charts.
class HkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final bool showShadow;
  final bool large;

  const HkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.spacingL),
    double? radius,
    this.onTap,
    this.color,
    this.borderColor,
    this.showShadow = true,
    this.large = false,
  }) : radius = radius ?? (large ? AppDimens.radiusCardL : AppDimens.radiusCardM);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: showShadow ? (large ? AppShadows.cardLarge : AppShadows.card) : null,
      ),
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(radius),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(radius),
                child: Padding(padding: padding, child: child),
              ),
            ),
    );
    return content;
  }
}
