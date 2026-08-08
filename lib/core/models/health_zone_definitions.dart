import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

enum HealthZoneStatus {
  criticalLow,
  warningLow,
  normal,
  warningHigh,
  criticalHigh,
}

class HealthZone {
  final HealthZoneStatus status;
  final double min;
  final double max;
  final Color color;
  final String label;

  const HealthZone({
    required this.status,
    required this.min,
    required this.max,
    required this.color,
    required this.label,
  });

  bool contains(double value) => value >= min && value <= max;
}

class VitalHealthZones {
  final String vitalName;
  final String unit;
  final List<HealthZone> zones;
  final String description;

  const VitalHealthZones({
    required this.vitalName,
    required this.unit,
    required this.zones,
    this.description = '',
  });

  HealthZone getZoneForValue(double value) {
    for (final zone in zones) {
      if (zone.contains(value)) return zone;
    }
    return zones.last;
  }
}

class HealthZoneDefinitions {
  HealthZoneDefinitions._();

  static const bloodPressureSystolic = VitalHealthZones(
    vitalName: 'Systolic Blood Pressure',
    unit: 'mmHg',
    zones: [
      HealthZone(
        status: HealthZoneStatus.criticalLow,
        min: 0,
        max: 89,
        color: AppColors.zoneCriticalLow,
        label: 'Low',
      ),
      HealthZone(
        status: HealthZoneStatus.normal,
        min: 90,
        max: 119,
        color: AppColors.zoneNormal,
        label: 'Normal',
      ),
      HealthZone(
        status: HealthZoneStatus.warningHigh,
        min: 120,
        max: 139,
        color: AppColors.zoneWarning,
        label: 'Elevated',
      ),
      HealthZone(
        status: HealthZoneStatus.criticalHigh,
        min: 140,
        max: 300,
        color: AppColors.zoneCriticalHigh,
        label: 'High',
      ),
    ],
  );

  static const bloodPressureDiastolic = VitalHealthZones(
    vitalName: 'Diastolic Blood Pressure',
    unit: 'mmHg',
    zones: [
      HealthZone(
        status: HealthZoneStatus.criticalLow,
        min: 0,
        max: 59,
        color: AppColors.zoneCriticalLow,
        label: 'Low',
      ),
      HealthZone(
        status: HealthZoneStatus.normal,
        min: 60,
        max: 79,
        color: AppColors.zoneNormal,
        label: 'Normal',
      ),
      HealthZone(
        status: HealthZoneStatus.warningHigh,
        min: 80,
        max: 89,
        color: AppColors.zoneWarning,
        label: 'Elevated',
      ),
      HealthZone(
        status: HealthZoneStatus.criticalHigh,
        min: 90,
        max: 200,
        color: AppColors.zoneCriticalHigh,
        label: 'High',
      ),
    ],
  );

  static const bloodGlucose = VitalHealthZones(
    vitalName: 'Blood Glucose',
    unit: 'mg/dL',
    zones: [
      HealthZone(
        status: HealthZoneStatus.criticalLow,
        min: 0,
        max: 69,
        color: AppColors.zoneCriticalLow,
        label: 'Low',
      ),
      HealthZone(
        status: HealthZoneStatus.normal,
        min: 70,
        max: 99,
        color: AppColors.zoneNormal,
        label: 'Normal',
      ),
      HealthZone(
        status: HealthZoneStatus.warningHigh,
        min: 100,
        max: 125,
        color: AppColors.zoneWarning,
        label: 'Pre-diabetic',
      ),
      HealthZone(
        status: HealthZoneStatus.criticalHigh,
        min: 126,
        max: 500,
        color: AppColors.zoneCriticalHigh,
        label: 'High',
      ),
    ],
  );

  static const heartRate = VitalHealthZones(
    vitalName: 'Heart Rate',
    unit: 'bpm',
    zones: [
      HealthZone(
        status: HealthZoneStatus.criticalLow,
        min: 0,
        max: 49,
        color: AppColors.zoneCriticalLow,
        label: 'Low',
      ),
      HealthZone(
        status: HealthZoneStatus.normal,
        min: 50,
        max: 100,
        color: AppColors.zoneNormal,
        label: 'Normal',
      ),
      HealthZone(
        status: HealthZoneStatus.warningHigh,
        min: 101,
        max: 120,
        color: AppColors.zoneWarning,
        label: 'Elevated',
      ),
      HealthZone(
        status: HealthZoneStatus.criticalHigh,
        min: 121,
        max: 300,
        color: AppColors.zoneCriticalHigh,
        label: 'High',
      ),
    ],
  );

  static const oxygenSaturation = VitalHealthZones(
    vitalName: 'Oxygen Saturation',
    unit: '%',
    zones: [
      HealthZone(
        status: HealthZoneStatus.criticalLow,
        min: 0,
        max: 89,
        color: AppColors.zoneCriticalLow,
        label: 'Critical',
      ),
      HealthZone(
        status: HealthZoneStatus.warningLow,
        min: 90,
        max: 94,
        color: AppColors.zoneWarning,
        label: 'Low',
      ),
      HealthZone(
        status: HealthZoneStatus.normal,
        min: 95,
        max: 100,
        color: AppColors.zoneNormal,
        label: 'Normal',
      ),
    ],
  );
}
