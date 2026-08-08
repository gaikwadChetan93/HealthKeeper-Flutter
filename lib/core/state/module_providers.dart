import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/mock_data.dart';
import '../models/allergy.dart';
import '../models/appointment.dart';
import '../models/blood_glucose.dart';
import '../models/blood_pressure.dart';
import '../models/doctor.dart';
import '../models/exercise.dart';
import '../models/family_member.dart';
import '../models/heart_rate.dart';
import '../models/height.dart';
import '../models/hydration.dart';
import '../models/lab_result.dart';
import '../models/medical_history.dart';
import '../models/medical_visit.dart';
import '../models/medication.dart';
import '../models/oxygen_saturation.dart';
import '../models/prescription.dart';
import '../models/radiology_result.dart';
import '../models/sleep.dart';
import '../models/surgery.dart';
import '../models/temperature.dart';
import '../models/vaccine.dart';
import '../models/weight.dart';
import 'health_record_notifier.dart';
import 'health_record_state.dart';

// ─── Family Members & Doctors (non-parameterized) ─────────────

final familyMembersProvider =
    StateProvider<List<FamilyMember>>((ref) => MockData.familyMembers);

final doctorsProvider =
    StateProvider<List<Doctor>>((ref) => MockData.doctors);

// ─── Health Record Providers (per module, per member) ─────────

final bloodPressureProvider = StateNotifierProvider.family<
    HealthRecordNotifier<BloodPressure>,
    HealthRecordState<BloodPressure>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.bloodPressureRecords,
      memberId: memberId,
    ));

final bloodGlucoseProvider = StateNotifierProvider.family<
    HealthRecordNotifier<BloodGlucose>,
    HealthRecordState<BloodGlucose>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.bloodGlucoseRecords,
      memberId: memberId,
    ));

final heartRateProvider = StateNotifierProvider.family<
    HealthRecordNotifier<HeartRate>,
    HealthRecordState<HeartRate>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.heartRateRecords,
      memberId: memberId,
    ));

final oxygenSaturationProvider = StateNotifierProvider.family<
    HealthRecordNotifier<OxygenSaturation>,
    HealthRecordState<OxygenSaturation>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.oxygenSaturationRecords,
      memberId: memberId,
    ));

final temperatureProvider = StateNotifierProvider.family<
    HealthRecordNotifier<Temperature>,
    HealthRecordState<Temperature>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.temperatureRecords,
      memberId: memberId,
    ));

final weightProvider = StateNotifierProvider.family<
    HealthRecordNotifier<Weight>,
    HealthRecordState<Weight>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.weightRecords,
      memberId: memberId,
    ));

final heightProvider = StateNotifierProvider.family<
    HealthRecordNotifier<Height>,
    HealthRecordState<Height>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.heightRecords,
      memberId: memberId,
    ));

final sleepProvider = StateNotifierProvider.family<
    HealthRecordNotifier<SleepRecord>,
    HealthRecordState<SleepRecord>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.sleepRecords,
      memberId: memberId,
    ));

final exerciseProvider = StateNotifierProvider.family<
    HealthRecordNotifier<Exercise>,
    HealthRecordState<Exercise>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.exerciseRecords,
      memberId: memberId,
    ));

final hydrationProvider = StateNotifierProvider.family<
    HealthRecordNotifier<Hydration>,
    HealthRecordState<Hydration>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.hydrationRecords,
      memberId: memberId,
    ));

final medicalVisitProvider = StateNotifierProvider.family<
    HealthRecordNotifier<MedicalVisit>,
    HealthRecordState<MedicalVisit>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.medicalVisitRecords,
      memberId: memberId,
    ));

final appointmentProvider = StateNotifierProvider.family<
    HealthRecordNotifier<Appointment>,
    HealthRecordState<Appointment>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.appointmentRecords,
      memberId: memberId,
    ));

final prescriptionProvider = StateNotifierProvider.family<
    HealthRecordNotifier<Prescription>,
    HealthRecordState<Prescription>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.prescriptionRecords,
      memberId: memberId,
    ));

final allergyProvider = StateNotifierProvider.family<
    HealthRecordNotifier<Allergy>,
    HealthRecordState<Allergy>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.allergyRecords,
      memberId: memberId,
    ));

final vaccineProvider = StateNotifierProvider.family<
    HealthRecordNotifier<Vaccine>,
    HealthRecordState<Vaccine>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.vaccineRecords,
      memberId: memberId,
    ));

final medicationProvider = StateNotifierProvider.family<
    HealthRecordNotifier<Medication>,
    HealthRecordState<Medication>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.medicationRecords,
      memberId: memberId,
    ));

final labResultProvider = StateNotifierProvider.family<
    HealthRecordNotifier<LabResult>,
    HealthRecordState<LabResult>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.labResultRecords,
      memberId: memberId,
    ));

final radiologyResultProvider = StateNotifierProvider.family<
    HealthRecordNotifier<RadiologyResult>,
    HealthRecordState<RadiologyResult>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.radiologyResultRecords,
      memberId: memberId,
    ));

final medicalHistoryProvider = StateNotifierProvider.family<
    HealthRecordNotifier<MedicalHistory>,
    HealthRecordState<MedicalHistory>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.medicalHistoryRecords,
      memberId: memberId,
    ));

final surgeryProvider = StateNotifierProvider.family<
    HealthRecordNotifier<Surgery>,
    HealthRecordState<Surgery>,
    int>((ref, memberId) => HealthRecordNotifier(
      mockDataLoader: MockData.surgeryRecords,
      memberId: memberId,
    ));
