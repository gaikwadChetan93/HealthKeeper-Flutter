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

class ScreenConfig {
  final String Function(HealthRecord) getTitle;
  final String? Function(HealthRecord) getSubtitle;
  final DateTime Function(HealthRecord) getDate;
  final ProviderListenable<HealthRecordState> Function(int memberId) getProvider;

  const ScreenConfig({
    required this.getTitle,
    required this.getSubtitle,
    required this.getDate,
    required this.getProvider,
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
    ),
    'blood_glucose': ScreenConfig(
      getTitle: (r) => '${(r as BloodGlucose).glucose} ${r.unit.abbreviation}',
      getSubtitle: (r) => (r as BloodGlucose).mealContext?.displayName,
      getDate: (r) => (r as BloodGlucose).measurementDate,
      getProvider: (id) => bloodGlucoseProvider(id),
    ),
    'heart_rate': ScreenConfig(
      getTitle: (r) => '${(r as HeartRate).bpm} bpm',
      getSubtitle: (r) => (r as HeartRate).activityContext?.displayName,
      getDate: (r) => (r as HeartRate).measurementDate,
      getProvider: (id) => heartRateProvider(id),
    ),
    'oxygen_saturation': ScreenConfig(
      getTitle: (r) => '${(r as OxygenSaturation).spO2}%',
      getSubtitle: (r) => (r as OxygenSaturation).notes,
      getDate: (r) => (r as OxygenSaturation).measurementDate,
      getProvider: (id) => oxygenSaturationProvider(id),
    ),
    'temperature': ScreenConfig(
      getTitle: (r) => '${(r as Temperature).temperature} ${r.unit.abbreviation}',
      getSubtitle: (r) => (r as Temperature).location?.displayName,
      getDate: (r) => (r as Temperature).measurementDate,
      getProvider: (id) => temperatureProvider(id),
    ),
    'weight': ScreenConfig(
      getTitle: (r) => '${(r as Weight).weight} ${r.unit.abbreviation}',
      getSubtitle: (r) => (r as Weight).notes,
      getDate: (r) => (r as Weight).measurementDate,
      getProvider: (id) => weightProvider(id),
    ),
    'height': ScreenConfig(
      getTitle: (r) => '${(r as Height).height} ${r.unit.abbreviation}',
      getSubtitle: (r) => (r as Height).notes,
      getDate: (r) => (r as Height).measurementDate,
      getProvider: (id) => heightProvider(id),
    ),
    'sleep': ScreenConfig(
      getTitle: (r) => '${(r as SleepRecord).hoursSlept} hrs',
      getSubtitle: (r) => (r as SleepRecord).quality?.displayName,
      getDate: (r) => (r as SleepRecord).sleepDate,
      getProvider: (id) => sleepProvider(id),
    ),
    'exercise': ScreenConfig(
      getTitle: (r) => (r as Exercise).activityType.displayName,
      getSubtitle: (r) => '${(r as Exercise).duration} min${r.calories != null ? " • ${r.calories} kcal" : ""}',
      getDate: (r) => (r as Exercise).exerciseDate,
      getProvider: (id) => exerciseProvider(id),
    ),
    'hydration': ScreenConfig(
      getTitle: (r) => '${(r as Hydration).waterIntake} ${r.unit.abbreviation}',
      getSubtitle: (r) => (r as Hydration).notes,
      getDate: (r) => (r as Hydration).date,
      getProvider: (id) => hydrationProvider(id),
    ),
    'medical_visit': ScreenConfig(
      getTitle: (r) => (r as MedicalVisit).hospitalName,
      getSubtitle: (r) => (r as MedicalVisit).reasonForVisit,
      getDate: (r) => (r as MedicalVisit).visitDate,
      getProvider: (id) => medicalVisitProvider(id),
    ),
    'appointment': ScreenConfig(
      getTitle: (r) => (r as Appointment).doctorName,
      getSubtitle: (r) => (r as Appointment).purpose,
      getDate: (r) => (r as Appointment).appointmentDate,
      getProvider: (id) => appointmentProvider(id),
    ),
    'prescription': ScreenConfig(
      getTitle: (r) => (r as Prescription).medicationName,
      getSubtitle: (r) => '${(r as Prescription).dosage} • ${r.frequency.displayName}',
      getDate: (r) => (r as Prescription).startDate,
      getProvider: (id) => prescriptionProvider(id),
    ),
    'allergy': ScreenConfig(
      getTitle: (r) => (r as Allergy).allergen,
      getSubtitle: (r) => '${(r as Allergy).reactionType.displayName} • ${r.severity.displayName}',
      getDate: (r) => (r as Allergy).diagnosedDate,
      getProvider: (id) => allergyProvider(id),
    ),
    'vaccine': ScreenConfig(
      getTitle: (r) => (r as Vaccine).vaccineName,
      getSubtitle: (r) {
        final v = r as Vaccine;
        return v.doseNumber != null ? 'Dose ${v.doseNumber}' : v.administeredBy;
      },
      getDate: (r) => (r as Vaccine).vaccineDate,
      getProvider: (id) => vaccineProvider(id),
    ),
    'medication': ScreenConfig(
      getTitle: (r) => (r as Medication).medicationName,
      getSubtitle: (r) => '${(r as Medication).dosage} • ${r.status.displayName}',
      getDate: (r) => (r as Medication).startDate,
      getProvider: (id) => medicationProvider(id),
    ),
    'lab_result': ScreenConfig(
      getTitle: (r) => (r as LabResult).testName,
      getSubtitle: (r) => (r as LabResult).result,
      getDate: (r) => (r as LabResult).testDate,
      getProvider: (id) => labResultProvider(id),
    ),
    'radiology_result': ScreenConfig(
      getTitle: (r) => '${(r as RadiologyResult).scanType} - ${r.bodyPart}',
      getSubtitle: (r) => (r as RadiologyResult).findings,
      getDate: (r) => (r as RadiologyResult).scanDate,
      getProvider: (id) => radiologyResultProvider(id),
    ),
    'medical_history': ScreenConfig(
      getTitle: (r) => (r as MedicalHistory).condition,
      getSubtitle: (r) => (r as MedicalHistory).status.displayName,
      getDate: (r) => (r as MedicalHistory).diagnosedDate,
      getProvider: (id) => medicalHistoryProvider(id),
    ),
    'surgery': ScreenConfig(
      getTitle: (r) => (r as Surgery).surgeryName,
      getSubtitle: (r) => (r as Surgery).hospital,
      getDate: (r) => (r as Surgery).surgeryDate,
      getProvider: (id) => surgeryProvider(id),
    ),
  };

  static ScreenConfig getConfig(String moduleKey) =>
      _configs[moduleKey] ?? _defaultConfig;

  static final _defaultConfig = ScreenConfig(
    getTitle: (r) => 'Record #${r.id}',
    getSubtitle: (r) => null,
    getDate: (r) => r.createdAt,
    getProvider: (id) => medicalVisitProvider(id),
  );
}
