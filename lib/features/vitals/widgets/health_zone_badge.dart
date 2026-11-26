import 'package:flutter/material.dart';

import '../../../app/theme/app_dimens.dart';
import '../../../core/models/health_zone_definitions.dart';

class HealthZoneBadge extends StatelessWidget {
  final VitalHealthZones zones;
  final double value;

  /// Smaller, for cards.
  final bool compact;

  const HealthZoneBadge({
    super.key,
    required this.zones,
    required this.value,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final zone = zones.getZoneForValue(value);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppDimens.spacingS : AppDimens.spacingM,
        vertical: compact ? 1 : AppDimens.spacingXS,
      ),
      decoration: BoxDecoration(
        color: zone.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimens.radiusS),
        border: Border.all(color: zone.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: zone.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            zone.label,
            style: TextStyle(
              color: zone.color,
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
