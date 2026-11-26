import '../../../core/models/chart_models.dart';
import '../../../core/models/health_zone_definitions.dart';

class VitalChartConfig {
  final String title;
  final String unit;
  final String trendLabel;
  final ChartType chartType;
  final int decimalPlaces;
  final String emptyStateMessage;
  final VitalHealthZones? healthZones;
  final VitalHealthZones? secondaryHealthZones;
  final bool isDualChart;

  /// Zones for a metric: the first metric uses [healthZones], the second
  /// (diastolic) [secondaryHealthZones].
  VitalHealthZones? zonesFor(int metricIndex) =>
      metricIndex == 0 ? healthZones : secondaryHealthZones;

  const VitalChartConfig({
    required this.title,
    required this.unit,
    required this.trendLabel,
    this.chartType = ChartType.line,
    this.decimalPlaces = 0,
    this.emptyStateMessage = 'No data recorded yet',
    this.healthZones,
    this.secondaryHealthZones,
    this.isDualChart = false,
  });

  static const bloodPressure = VitalChartConfig(
    title: 'Blood Pressure',
    unit: 'mmHg',
    trendLabel: 'BP Trend',
    healthZones: HealthZoneDefinitions.bloodPressureSystolic,
    secondaryHealthZones: HealthZoneDefinitions.bloodPressureDiastolic,
    isDualChart: true,
    emptyStateMessage: 'Start tracking your blood pressure to see trends',
  );

  static const bloodGlucose = VitalChartConfig(
    title: 'Blood Glucose',
    unit: 'mg/dL',
    trendLabel: 'Glucose Trend',
    decimalPlaces: 1,
    healthZones: HealthZoneDefinitions.bloodGlucose,
    emptyStateMessage: 'Start tracking your blood glucose to see trends',
  );

  static const heartRate = VitalChartConfig(
    title: 'Heart Rate',
    unit: 'bpm',
    trendLabel: 'Heart Rate Trend',
    healthZones: HealthZoneDefinitions.heartRate,
    emptyStateMessage: 'Start tracking your heart rate to see trends',
  );

  static const oxygenSaturation = VitalChartConfig(
    title: 'Oxygen Saturation',
    unit: '%',
    trendLabel: 'SpO2 Trend',
    decimalPlaces: 1,
    healthZones: HealthZoneDefinitions.oxygenSaturation,
    emptyStateMessage: 'Start tracking your SpO2 to see trends',
  );

  static const weight = VitalChartConfig(
    title: 'Weight',
    unit: 'kg',
    trendLabel: 'Weight Trend',
    decimalPlaces: 1,
    emptyStateMessage: 'Start tracking your weight to see trends',
  );

  static const height = VitalChartConfig(
    title: 'Height',
    unit: 'cm',
    trendLabel: 'Height Trend',
    decimalPlaces: 1,
    emptyStateMessage: 'Start tracking your height to see trends',
  );

  static const temperature = VitalChartConfig(
    title: 'Temperature',
    unit: '°F',
    trendLabel: 'Temperature Trend',
    decimalPlaces: 1,
    emptyStateMessage: 'Start tracking your temperature to see trends',
  );

  static const sleep = VitalChartConfig(
    title: 'Sleep',
    unit: 'hrs',
    trendLabel: 'Sleep Trend',
    chartType: ChartType.bar,
    decimalPlaces: 1,
    emptyStateMessage: 'Start tracking your sleep to see trends',
  );

  static const exercise = VitalChartConfig(
    title: 'Exercise',
    unit: 'min',
    trendLabel: 'Exercise per day',
    chartType: ChartType.bar,
    emptyStateMessage: 'Start tracking your exercise to see trends',
  );

  static const hydration = VitalChartConfig(
    title: 'Hydration',
    unit: 'ml',
    trendLabel: 'Water per day',
    chartType: ChartType.bar,
    emptyStateMessage: 'Start tracking how much water you drink to see trends',
  );

  static VitalChartConfig? getConfig(String vitalKey) {
    return switch (vitalKey) {
      'blood_pressure' => bloodPressure,
      'blood_glucose' => bloodGlucose,
      'heart_rate' => heartRate,
      'oxygen_saturation' => oxygenSaturation,
      'weight' => weight,
      'height' => height,
      'temperature' => temperature,
      'sleep' => sleep,
      'exercise' => exercise,
      'hydration' => hydration,
      _ => null,
    };
  }
}
