import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import 'hk_card.dart';

/// Skeleton loading rows matching the design's "Loading" state: an icon
/// placeholder plus two text bars, wrapped in a shimmer sheen. Replaces
/// bare spinners wherever a list is loading its first page of data.
class HkSkeleton extends StatelessWidget {
  final int rows;

  const HkSkeleton({super.key, this.rows = 3});

  @override
  Widget build(BuildContext context) {
    return HkCard(
      showShadow: false,
      child: Shimmer.fromColors(
        baseColor: AppColors.divider,
        highlightColor: AppColors.surface,
        period: const Duration(milliseconds: 1500),
        child: Column(
          children: List.generate(rows, (i) => _skeletonRow(i < rows - 1)),
        ),
      ),
    );
  }

  Widget _skeletonRow(bool withSpacing) {
    return Padding(
      padding: EdgeInsets.only(bottom: withSpacing ? 11 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(AppDimens.radiusChip),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.62,
                  child: Container(
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                FractionallySizedBox(
                  widthFactor: 0.38,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.dividerFaint,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
