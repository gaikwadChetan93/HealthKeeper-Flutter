import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/allergy.dart';
import '../../../core/models/appointment.dart';
import '../../../core/models/blood_glucose.dart';
import '../../../core/models/blood_pressure.dart';
import '../../../core/models/exercise.dart';
import '../../../core/models/health_record.dart';
import '../../../core/models/heart_rate.dart';
import '../../../core/models/height.dart';
import '../../../core/models/hydration.dart';
import '../../../core/models/lab_result.dart';
import '../../../core/models/medical_history.dart';
import '../../../core/models/medical_visit.dart';
import '../../../core/models/medication.dart';
import '../../../core/models/oxygen_saturation.dart';
import '../../../core/models/prescription.dart';
import '../../../core/models/radiology_result.dart';
import '../../../core/models/sleep.dart';
import '../../../core/models/surgery.dart';
import '../../../core/models/temperature.dart';
import '../../../core/models/vaccine.dart';
import '../../../core/models/weight.dart';
import '../../../core/state/health_record_state.dart';
import '../../../core/state/module_providers.dart';

final _dateFmt = DateFormat('d MMM yyyy');

String? _n(String? s) => (s == null || s.isEmpty) ? null : s;

class ScreenConfig {
  final String Function(HealthRecord) getTitle;
  final String? Function(HealthRecord) getSubtitle;
  final DateTime Function(HealthRecord) getDate;
  final ProviderListenable<HealthRecordState> Function(int memberId) getProvider;

  /// Persists a save against this module's own family-parameterised
  /// [HealthRecordNotifier] — the "thin layer" the redesign plan calls for
  /// so [GenericFormScreen] and the vital-entry keypad can both trigger a
  /// real save without every call site knowing which of the 20 concrete
  /// notifier types it's talking to.
  final Future<void> Function(WidgetRef ref, int memberId) simulateSave;

  /// Same idea for delete, used by the record detail screen.
  final Future<void> Function(WidgetRef ref, int memberId) simulateDelete;

  /// Re-runs the mock loader against this module's own notifier — used
  /// by the generic list screen's error-state "Try again" button. Exists
  /// for the same reason as [simulateSave]/[simulateDelete]: [getProvider]
  /// is deliberately type-erased to `ProviderListenable<HealthRecordState>`
  /// so `ScreenConfig` itself doesn't need to be generic, which means call
  /// sites can't reach `.notifier` on it directly.
  final Future<void> Function(WidgetRef ref, int memberId) reload;

  /// Label/value rows for the restyled record detail screen — a curated
  /// subset of the concrete model's fields (title/subtitle/date already
  /// cover the headline info, so this fills in the rest), skipping any
  /// field that's empty for this particular record.
  final List<MapEntry<String, String>> Function(HealthRecord) getDetailRows;

  const ScreenConfig({
    required this.getTitle,
    required this.getSubtitle,
    required this.getDate,
    required this.getProvider,
    required this.simulateSave,
    required this.simulateDelete,
    required this.reload,
    required this.getDetailRows,
  });
}

class ModuleScreenConfig {
  ModuleScreenConfig._();

  static final _configs = <String, ScreenConfig>{
    'blood_pressure': ScreenConfig(
      getTitle: (r) => '${(r as BloodPressure).systolic}/${r.diastolic} mmHg',
      getSubtitle: (r) => (r as BloodPressure).armSide?.displayName,
      getDate: (r) => (r as BloodPressure).measurementDate,
      getProvider: (id) => bloodPressureProvider(id),
      simulateSave: (ref, id) => ref.read(bloodPressureProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(bloodPressureProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(bloodPressureProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as BloodPressure;
        return [
          MapEntry('Measured', _dateFmt.format(v.measurementDate)),
          if (v.armSide != null) MapEntry('Arm', v.armSide!.displayName),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'blood_glucose': ScreenConfig(
      getTitle: (r) => '${(r as BloodGlucose).glucose} ${r.unit.abbreviation}',
      getSubtitle: (r) => (r as BloodGlucose).mealContext?.displayName,
      getDate: (r) => (r as BloodGlucose).measurementDate,
      getProvider: (id) => bloodGlucoseProvider(id),
      simulateSave: (ref, id) => ref.read(bloodGlucoseProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(bloodGlucoseProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(bloodGlucoseProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as BloodGlucose;
        return [
          MapEntry('Measured', _dateFmt.format(v.measurementDate)),
          if (v.mealContext != null) MapEntry('Context', v.mealContext!.displayName),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'heart_rate': ScreenConfig(
      getTitle: (r) => '${(r as HeartRate).bpm} bpm',
      getSubtitle: (r) => (r as HeartRate).activityContext?.displayName,
      getDate: (r) => (r as HeartRate).measurementDate,
      getProvider: (id) => heartRateProvider(id),
      simulateSave: (ref, id) => ref.read(heartRateProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(heartRateProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(heartRateProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as HeartRate;
        return [
          MapEntry('Measured', _dateFmt.format(v.measurementDate)),
          if (v.activityContext != null) MapEntry('Context', v.activityContext!.displayName),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'oxygen_saturation': ScreenConfig(
      getTitle: (r) => '${(r as OxygenSaturation).spO2}%',
      getSubtitle: (r) => (r as OxygenSaturation).notes,
      getDate: (r) => (r as OxygenSaturation).measurementDate,
      getProvider: (id) => oxygenSaturationProvider(id),
      simulateSave: (ref, id) => ref.read(oxygenSaturationProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(oxygenSaturationProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(oxygenSaturationProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as OxygenSaturation;
        return [
          MapEntry('Measured', _dateFmt.format(v.measurementDate)),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'temperature': ScreenConfig(
      getTitle: (r) => '${(r as Temperature).temperature} ${r.unit.abbreviation}',
      getSubtitle: (r) => (r as Temperature).location?.displayName,
      getDate: (r) => (r as Temperature).measurementDate,
      getProvider: (id) => temperatureProvider(id),
      simulateSave: (ref, id) => ref.read(temperatureProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(temperatureProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(temperatureProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as Temperature;
        return [
          MapEntry('Measured', _dateFmt.format(v.measurementDate)),
          if (v.location != null) MapEntry('Location', v.location!.displayName),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'weight': ScreenConfig(
      getTitle: (r) => '${(r as Weight).weight} ${r.unit.abbreviation}',
      getSubtitle: (r) => (r as Weight).notes,
      getDate: (r) => (r as Weight).measurementDate,
      getProvider: (id) => weightProvider(id),
      simulateSave: (ref, id) => ref.read(weightProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(weightProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(weightProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as Weight;
        return [
          MapEntry('Measured', _dateFmt.format(v.measurementDate)),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'height': ScreenConfig(
      getTitle: (r) => '${(r as Height).height} ${r.unit.abbreviation}',
      getSubtitle: (r) => (r as Height).notes,
      getDate: (r) => (r as Height).measurementDate,
      getProvider: (id) => heightProvider(id),
      simulateSave: (ref, id) => ref.read(heightProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(heightProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(heightProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as Height;
        return [
          MapEntry('Measured', _dateFmt.format(v.measurementDate)),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'sleep': ScreenConfig(
      getTitle: (r) => '${(r as SleepRecord).hoursSlept} hrs',
      getSubtitle: (r) => (r as SleepRecord).quality?.displayName,
      getDate: (r) => (r as SleepRecord).sleepDate,
      getProvider: (id) => sleepProvider(id),
      simulateSave: (ref, id) => ref.read(sleepProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(sleepProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(sleepProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as SleepRecord;
        return [
          MapEntry('Date', _dateFmt.format(v.sleepDate)),
          if (v.quality != null) MapEntry('Quality', v.quality!.displayName),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'exercise': ScreenConfig(
      getTitle: (r) => (r as Exercise).activityType.displayName,
      getSubtitle: (r) => '${(r as Exercise).duration} min${r.calories != null ? " • ${r.calories} kcal" : ""}',
      getDate: (r) => (r as Exercise).exerciseDate,
      getProvider: (id) => exerciseProvider(id),
      simulateSave: (ref, id) => ref.read(exerciseProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(exerciseProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(exerciseProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as Exercise;
        return [
          MapEntry('Date', _dateFmt.format(v.exerciseDate)),
          MapEntry('Duration', '${v.duration} min'),
          if (v.distance != null) MapEntry('Distance', '${v.distance} ${v.distanceUnit?.abbreviation ?? ''}'),
          if (v.calories != null) MapEntry('Calories', '${v.calories} kcal'),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'hydration': ScreenConfig(
      getTitle: (r) => '${(r as Hydration).waterIntake} ${r.unit.abbreviation}',
      getSubtitle: (r) => (r as Hydration).notes,
      getDate: (r) => (r as Hydration).date,
      getProvider: (id) => hydrationProvider(id),
      simulateSave: (ref, id) => ref.read(hydrationProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(hydrationProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(hydrationProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as Hydration;
        return [
          MapEntry('Date', _dateFmt.format(v.date)),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'medical_visit': ScreenConfig(
      getTitle: (r) => (r as MedicalVisit).hospitalName,
      getSubtitle: (r) => (r as MedicalVisit).reasonForVisit,
      getDate: (r) => (r as MedicalVisit).visitDate,
      getProvider: (id) => medicalVisitProvider(id),
      simulateSave: (ref, id) => ref.read(medicalVisitProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(medicalVisitProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(medicalVisitProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as MedicalVisit;
        return [
          MapEntry('Visited', _dateFmt.format(v.visitDate)),
          if (_n(v.doctorName) != null) MapEntry('Doctor', v.doctorName!),
          if (v.department != null) MapEntry('Department', v.department!.displayName),
          MapEntry('Reason', v.reasonForVisit),
          if (_n(v.diagnosisNotes) != null) MapEntry('Diagnosis', v.diagnosisNotes!),
          if (v.followUpDate != null) MapEntry('Follow-up', _dateFmt.format(v.followUpDate!)),
          if (v.cost != null) MapEntry('Cost', v.cost!.toStringAsFixed(0)),
          if (v.paymentMode != null) MapEntry('Payment', v.paymentMode!.displayName),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'appointment': ScreenConfig(
      getTitle: (r) => (r as Appointment).doctorName,
      getSubtitle: (r) => (r as Appointment).purpose,
      getDate: (r) => (r as Appointment).appointmentDate,
      getProvider: (id) => appointmentProvider(id),
      simulateSave: (ref, id) => ref.read(appointmentProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(appointmentProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(appointmentProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as Appointment;
        return [
          MapEntry('When', '${_dateFmt.format(v.appointmentDate)} · ${v.appointmentTime}'),
          MapEntry('Hospital', v.hospitalName),
          if (v.department != null) MapEntry('Department', v.department!.displayName),
          if (_n(v.purpose) != null) MapEntry('Purpose', v.purpose!),
          if (v.reminderEnabled && v.reminderTime != null) MapEntry('Reminder', v.reminderTime!.displayName),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'prescription': ScreenConfig(
      getTitle: (r) => (r as Prescription).medicationName,
      getSubtitle: (r) => '${(r as Prescription).dosage} • ${r.frequency.displayName}',
      getDate: (r) => (r as Prescription).startDate,
      getProvider: (id) => prescriptionProvider(id),
      simulateSave: (ref, id) => ref.read(prescriptionProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(prescriptionProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(prescriptionProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as Prescription;
        return [
          MapEntry('Dosage', v.dosage),
          MapEntry('Frequency', v.frequency.displayName),
          MapEntry('Route', v.route.displayName),
          MapEntry('Started', _dateFmt.format(v.startDate)),
          if (v.endDate != null) MapEntry('Ends', _dateFmt.format(v.endDate!)),
          if (_n(v.prescribedBy) != null) MapEntry('Prescribed by', v.prescribedBy!),
          if (_n(v.purpose) != null) MapEntry('Purpose', v.purpose!),
          MapEntry('Status', v.status.displayName),
          if (_n(v.sideEffects) != null) MapEntry('Side effects', v.sideEffects!),
          if (_n(v.instructions) != null) MapEntry('Instructions', v.instructions!),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'allergy': ScreenConfig(
      getTitle: (r) => (r as Allergy).allergen,
      getSubtitle: (r) => '${(r as Allergy).reactionType.displayName} • ${r.severity.displayName}',
      getDate: (r) => (r as Allergy).diagnosedDate,
      getProvider: (id) => allergyProvider(id),
      simulateSave: (ref, id) => ref.read(allergyProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(allergyProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(allergyProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as Allergy;
        return [
          MapEntry('Type', v.reactionType.displayName),
          MapEntry('Severity', v.severity.displayName),
          MapEntry('Diagnosed', _dateFmt.format(v.diagnosedDate)),
          if (_n(v.symptoms) != null) MapEntry('Symptoms', v.symptoms!),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'vaccine': ScreenConfig(
      getTitle: (r) => (r as Vaccine).vaccineName,
      getSubtitle: (r) {
        final v = r as Vaccine;
        return v.doseNumber != null ? 'Dose ${v.doseNumber}' : v.administeredBy;
      },
      getDate: (r) => (r as Vaccine).vaccineDate,
      getProvider: (id) => vaccineProvider(id),
      simulateSave: (ref, id) => ref.read(vaccineProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(vaccineProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(vaccineProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as Vaccine;
        return [
          MapEntry('Given', _dateFmt.format(v.vaccineDate)),
          if (v.doseNumber != null) MapEntry('Dose', '${v.doseNumber}'),
          if (v.nextDueDate != null) MapEntry('Next due', _dateFmt.format(v.nextDueDate!)),
          if (_n(v.administeredBy) != null) MapEntry('Administered by', v.administeredBy!),
          if (_n(v.location) != null) MapEntry('Location', v.location!),
          if (_n(v.lotNumber) != null) MapEntry('Lot number', v.lotNumber!),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'medication': ScreenConfig(
      getTitle: (r) => (r as Medication).medicationName,
      getSubtitle: (r) => '${(r as Medication).dosage} • ${r.status.displayName}',
      getDate: (r) => (r as Medication).startDate,
      getProvider: (id) => medicationProvider(id),
      simulateSave: (ref, id) => ref.read(medicationProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(medicationProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(medicationProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as Medication;
        return [
          MapEntry('Source', v.sourceType.displayName),
          MapEntry('Dosage', v.dosage),
          MapEntry('Frequency', v.frequency.displayName),
          MapEntry('Route', v.route.displayName),
          MapEntry('Started', _dateFmt.format(v.startDate)),
          if (v.endDate != null) MapEntry('Ends', _dateFmt.format(v.endDate!)),
          MapEntry('Status', v.status.displayName),
          if (_n(v.prescribedBy) != null) MapEntry('Prescribed by', v.prescribedBy!),
          if (_n(v.purpose) != null) MapEntry('Purpose', v.purpose!),
          if (_n(v.sideEffects) != null) MapEntry('Side effects', v.sideEffects!),
          if (_n(v.instructions) != null) MapEntry('Instructions', v.instructions!),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'lab_result': ScreenConfig(
      getTitle: (r) => (r as LabResult).testName,
      getSubtitle: (r) => (r as LabResult).result,
      getDate: (r) => (r as LabResult).testDate,
      getProvider: (id) => labResultProvider(id),
      simulateSave: (ref, id) => ref.read(labResultProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(labResultProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(labResultProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as LabResult;
        return [
          MapEntry('Tested', _dateFmt.format(v.testDate)),
          MapEntry('Result', '${v.result}${_n(v.unit) != null ? ' ${v.unit}' : ''}'),
          if (_n(v.normalRange) != null) MapEntry('Normal range', v.normalRange!),
          if (_n(v.labName) != null) MapEntry('Lab', v.labName!),
          if (_n(v.orderedBy) != null) MapEntry('Ordered by', v.orderedBy!),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'radiology_result': ScreenConfig(
      getTitle: (r) => '${(r as RadiologyResult).scanType} - ${r.bodyPart}',
      getSubtitle: (r) => (r as RadiologyResult).findings,
      getDate: (r) => (r as RadiologyResult).scanDate,
      getProvider: (id) => radiologyResultProvider(id),
      simulateSave: (ref, id) => ref.read(radiologyResultProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(radiologyResultProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(radiologyResultProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as RadiologyResult;
        return [
          MapEntry('Scanned', _dateFmt.format(v.scanDate)),
          MapEntry('Body part', v.bodyPart),
          if (_n(v.radiologyCenter) != null) MapEntry('Centre', v.radiologyCenter!),
          if (_n(v.orderedBy) != null) MapEntry('Ordered by', v.orderedBy!),
          if (_n(v.findings) != null) MapEntry('Findings', v.findings!),
          if (_n(v.radiologistName) != null) MapEntry('Radiologist', v.radiologistName!),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'medical_history': ScreenConfig(
      getTitle: (r) => (r as MedicalHistory).condition,
      getSubtitle: (r) => (r as MedicalHistory).status.displayName,
      getDate: (r) => (r as MedicalHistory).diagnosedDate,
      getProvider: (id) => medicalHistoryProvider(id),
      simulateSave: (ref, id) => ref.read(medicalHistoryProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(medicalHistoryProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(medicalHistoryProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as MedicalHistory;
        return [
          MapEntry('Diagnosed', _dateFmt.format(v.diagnosedDate)),
          MapEntry('Status', v.status.displayName),
          if (_n(v.treatedBy) != null) MapEntry('Treated by', v.treatedBy!),
          if (_n(v.treatment) != null) MapEntry('Treatment', v.treatment!),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
    'surgery': ScreenConfig(
      getTitle: (r) => (r as Surgery).surgeryName,
      getSubtitle: (r) => (r as Surgery).hospital,
      getDate: (r) => (r as Surgery).surgeryDate,
      getProvider: (id) => surgeryProvider(id),
      simulateSave: (ref, id) => ref.read(surgeryProvider(id).notifier).simulateSave(),
      simulateDelete: (ref, id) => ref.read(surgeryProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(surgeryProvider(id).notifier).loadRecords(),
      getDetailRows: (r) {
        final v = r as Surgery;
        return [
          MapEntry('Date', _dateFmt.format(v.surgeryDate)),
          if (_n(v.hospital) != null) MapEntry('Hospital', v.hospital!),
          if (_n(v.surgeon) != null) MapEntry('Surgeon', v.surgeon!),
          if (_n(v.reason) != null) MapEntry('Reason', v.reason!),
          if (_n(v.complications) != null) MapEntry('Complications', v.complications!),
          if (_n(v.notes) != null) MapEntry('Notes', v.notes!),
        ];
      },
    ),
  };

  static ScreenConfig getConfig(String moduleKey) =>
      _configs[moduleKey] ?? _defaultConfig;

  static final _defaultConfig = ScreenConfig(
    getTitle: (r) => 'Record #${r.id}',
    getSubtitle: (r) => null,
    getDate: (r) => r.createdAt,
    getProvider: (id) => medicalVisitProvider(id),
    simulateSave: (ref, id) => ref.read(medicalVisitProvider(id).notifier).simulateSave(),
    simulateDelete: (ref, id) => ref.read(medicalVisitProvider(id).notifier).simulateDelete(),
      reload: (ref, id) => ref.read(medicalVisitProvider(id).notifier).loadRecords(),
    getDetailRows: (r) => [MapEntry('Created', _dateFmt.format(r.createdAt))],
  );
}
