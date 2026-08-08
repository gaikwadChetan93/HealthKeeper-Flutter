import 'health_record.dart';
import 'sync_status.dart';

enum TemperatureUnit {
  celsius('Celsius', '°C'),
  fahrenheit('Fahrenheit', '°F');

  final String displayName;
  final String abbreviation;
  const TemperatureUnit(this.displayName, this.abbreviation);
}

enum MeasurementLocation {
  oral('Oral'),
  ear('Ear (tympanic)'),
  forehead('Forehead'),
  armpit('Armpit (axillary)'),
  rectal('Rectal');

  final String displayName;
  const MeasurementLocation(this.displayName);
}

class Temperature extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final double temperature;
  final TemperatureUnit unit;
  final DateTime measurementDate;
  final MeasurementLocation? location;
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const Temperature({
    this.id = 0,
    required this.familyMemberId,
    required this.temperature,
    required this.unit,
    required this.measurementDate,
    this.location,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });
}
