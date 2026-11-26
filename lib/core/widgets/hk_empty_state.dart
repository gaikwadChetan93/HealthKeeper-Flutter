import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import 'hk_card.dart';
import 'hk_primary_button.dart';

/// First-run / zero-state card: icon in a soft square, a warm one-line
/// promise, a short explanation, a primary CTA and an optional secondary
/// text link (e.g. "or scan a document to fill it in").
class HkEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const HkEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.ctaLabel,
    this.onCta,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return HkCard(
      large: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppDimens.radiusChip + 8),
            ),
            child: Icon(icon, size: 26, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.cardTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 9),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(fontSize: 12),
          ),
          if (ctaLabel != null) ...[
            const SizedBox(height: 18),
            HkPrimaryButton(label: ctaLabel!, onPressed: onCta),
          ],
          if (secondaryLabel != null) ...[
            const SizedBox(height: 9),
            GestureDetector(
              onTap: onSecondary,
              child: Text(
                secondaryLabel!,
                style: AppTypography.button.copyWith(color: AppColors.primary, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
