import '../models/allergy.dart';
import '../models/appointment.dart';
import '../models/blood_glucose.dart';
import '../models/blood_pressure.dart';
import '../models/chart_models.dart';
import '../models/doctor.dart';
import '../models/document.dart';
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
import '../models/sync_status.dart';
import '../models/temperature.dart';
import '../models/vaccine.dart';
import '../models/weight.dart';

class MockData {
  MockData._();

  static final _now = DateTime.now();
  static DateTime _daysAgo(int days) => _now.subtract(Duration(days: days));

  // ─── Family Members ───────────────────────────────────────────

  static final familyMembers = [
    FamilyMember(
      id: 1,
      name: 'Rahul Sharma',
      age: 32,
      relation: 'Self',
      createdAt: _daysAgo(365),
      updatedAt: _daysAgo(1),
    ),
    FamilyMember(
      id: 2,
      name: 'Priya Sharma',
      age: 29,
      relation: 'Wife',
      createdAt: _daysAgo(300),
      updatedAt: _daysAgo(5),
    ),
    FamilyMember(
      id: 3,
      name: 'Aarav Sharma',
      age: 5,
      relation: 'Son',
      createdAt: _daysAgo(200),
      updatedAt: _daysAgo(10),
    ),
  ];

  // ─── Doctors ──────────────────────────────────────────────────

  static final doctors = [
    Doctor(
      id: 1,
      name: 'Dr. Anita Desai',
      speciality: 'General Physician',
      contactNumber: '9876543210',
      createdAt: _daysAgo(300),
      updatedAt: _daysAgo(30),
    ),
    Doctor(
      id: 2,
      name: 'Dr. Vikram Mehta',
      speciality: 'Cardiologist',
      contactNumber: '9876543211',
      createdAt: _daysAgo(250),
      updatedAt: _daysAgo(15),
    ),
    Doctor(
      id: 3,
      name: 'Dr. Sneha Patel',
      speciality: 'Pediatrician',
      contactNumber: '9876543212',
      createdAt: _daysAgo(200),
      updatedAt: _daysAgo(5),
    ),
    Doctor(
      id: 4,
      name: 'Dr. Rajesh Kumar',
      speciality: 'Dermatologist',
      contactNumber: '9876543213',
      createdAt: _daysAgo(150),
      updatedAt: _daysAgo(10),
    ),
  ];

  // ─── Blood Pressure ──────────────────────────────────────────

  static List<BloodPressure> bloodPressureRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        BloodPressure(
          id: 1, familyMemberId: memberId, systolic: 120, diastolic: 80,
          measurementDate: _daysAgo(1), armSide: ArmSide.left,
          notes: 'Morning reading', syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(1), updatedAt: _daysAgo(1),
        ),
        BloodPressure(
          id: 2, familyMemberId: memberId, systolic: 118, diastolic: 78,
          measurementDate: _daysAgo(3), armSide: ArmSide.left,
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(3), updatedAt: _daysAgo(3),
        ),
        BloodPressure(
          id: 3, familyMemberId: memberId, systolic: 125, diastolic: 82,
          measurementDate: _daysAgo(7), armSide: ArmSide.right,
          notes: 'After exercise', syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(7), updatedAt: _daysAgo(7),
        ),
        BloodPressure(
          id: 4, familyMemberId: memberId, systolic: 130, diastolic: 85,
          measurementDate: _daysAgo(14), armSide: ArmSide.left,
          syncStatus: SyncStatus.pending,
          createdAt: _daysAgo(14), updatedAt: _daysAgo(14),
        ),
        BloodPressure(
          id: 5, familyMemberId: memberId, systolic: 115, diastolic: 76,
          measurementDate: _daysAgo(21),
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(21), updatedAt: _daysAgo(21),
        ),
      ];
  }

  // ─── Blood Glucose ───────────────────────────────────────────

  static List<BloodGlucose> bloodGlucoseRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        BloodGlucose(
          id: 1, familyMemberId: memberId, glucose: 95, unit: GlucoseUnit.mgDl,
          measurementDate: _daysAgo(1), mealContext: MealContext.fasting,
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(1), updatedAt: _daysAgo(1),
        ),
        BloodGlucose(
          id: 2, familyMemberId: memberId, glucose: 140, unit: GlucoseUnit.mgDl,
          measurementDate: _daysAgo(1), mealContext: MealContext.afterMeal,
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(1), updatedAt: _daysAgo(1),
        ),
        BloodGlucose(
          id: 3, familyMemberId: memberId, glucose: 88, unit: GlucoseUnit.mgDl,
          measurementDate: _daysAgo(5), mealContext: MealContext.fasting,
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(5), updatedAt: _daysAgo(5),
        ),
        BloodGlucose(
          id: 4, familyMemberId: memberId, glucose: 105, unit: GlucoseUnit.mgDl,
          measurementDate: _daysAgo(10), mealContext: MealContext.beforeMeal,
          syncStatus: SyncStatus.pending,
          createdAt: _daysAgo(10), updatedAt: _daysAgo(10),
        ),
      ];
  }

  // ─── Heart Rate ──────────────────────────────────────────────

  static List<HeartRate> heartRateRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        HeartRate(
          id: 1, familyMemberId: memberId, bpm: 72,
          measurementDate: _daysAgo(1), activityContext: ActivityContext.resting,
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(1), updatedAt: _daysAgo(1),
        ),
        HeartRate(
          id: 2, familyMemberId: memberId, bpm: 110,
          measurementDate: _daysAgo(2), activityContext: ActivityContext.moderateExercise,
          notes: 'Post jog', syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(2), updatedAt: _daysAgo(2),
        ),
        HeartRate(
          id: 3, familyMemberId: memberId, bpm: 68,
          measurementDate: _daysAgo(7), activityContext: ActivityContext.resting,
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(7), updatedAt: _daysAgo(7),
        ),
      ];
  }

  // ─── Oxygen Saturation ───────────────────────────────────────

  static List<OxygenSaturation> oxygenSaturationRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        OxygenSaturation(
          id: 1, familyMemberId: memberId, spO2: 98,
          measurementDate: _daysAgo(1), syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(1), updatedAt: _daysAgo(1),
        ),
        OxygenSaturation(
          id: 2, familyMemberId: memberId, spO2: 97,
          measurementDate: _daysAgo(5), syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(5), updatedAt: _daysAgo(5),
        ),
        OxygenSaturation(
          id: 3, familyMemberId: memberId, spO2: 99,
          measurementDate: _daysAgo(12), syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(12), updatedAt: _daysAgo(12),
        ),
      ];
  }

  // ─── Temperature ─────────────────────────────────────────────

  static List<Temperature> temperatureRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        Temperature(
          id: 1, familyMemberId: memberId, temperature: 98.6,
          unit: TemperatureUnit.fahrenheit, measurementDate: _daysAgo(2),
          location: MeasurementLocation.oral, syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(2), updatedAt: _daysAgo(2),
        ),
        Temperature(
          id: 2, familyMemberId: memberId, temperature: 99.1,
          unit: TemperatureUnit.fahrenheit, measurementDate: _daysAgo(10),
          location: MeasurementLocation.forehead,
          notes: 'Slight fever', syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(10), updatedAt: _daysAgo(10),
        ),
      ];
  }

  // ─── Weight ──────────────────────────────────────────────────

  static List<Weight> weightRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        Weight(
          id: 1, familyMemberId: memberId, weight: 72.5,
          unit: WeightUnit.kilograms, measurementDate: _daysAgo(1),
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(1), updatedAt: _daysAgo(1),
        ),
        Weight(
          id: 2, familyMemberId: memberId, weight: 73.0,
          unit: WeightUnit.kilograms, measurementDate: _daysAgo(15),
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(15), updatedAt: _daysAgo(15),
        ),
        Weight(
          id: 3, familyMemberId: memberId, weight: 73.8,
          unit: WeightUnit.kilograms, measurementDate: _daysAgo(30),
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(30), updatedAt: _daysAgo(30),
        ),
      ];
  }

  // ─── Height ──────────────────────────────────────────────────

  static List<Height> heightRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        Height(
          id: 1, familyMemberId: memberId, height: 175,
          unit: HeightUnit.centimeters, measurementDate: _daysAgo(90),
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(90), updatedAt: _daysAgo(90),
        ),
      ];
  }

  // ─── Sleep ───────────────────────────────────────────────────

  static List<SleepRecord> sleepRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        SleepRecord(
          id: 1, familyMemberId: memberId, sleepDate: _daysAgo(1),
          hoursSlept: 7.5, quality: SleepQuality.good,
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(1), updatedAt: _daysAgo(1),
        ),
        SleepRecord(
          id: 2, familyMemberId: memberId, sleepDate: _daysAgo(2),
          hoursSlept: 6.0, quality: SleepQuality.fair,
          notes: 'Woke up twice', syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(2), updatedAt: _daysAgo(2),
        ),
        SleepRecord(
          id: 3, familyMemberId: memberId, sleepDate: _daysAgo(3),
          hoursSlept: 8.0, quality: SleepQuality.excellent,
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(3), updatedAt: _daysAgo(3),
        ),
      ];
  }

  // ─── Exercise ────────────────────────────────────────────────

  static List<Exercise> exerciseRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        Exercise(
          id: 1, familyMemberId: memberId, exerciseDate: _daysAgo(1),
          activityType: ExerciseType.running, duration: 30,
          distance: 5.0, distanceUnit: DistanceUnit.kilometers,
          calories: 320, syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(1), updatedAt: _daysAgo(1),
        ),
        Exercise(
          id: 2, familyMemberId: memberId, exerciseDate: _daysAgo(3),
          activityType: ExerciseType.yoga, duration: 45,
          calories: 150, syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(3), updatedAt: _daysAgo(3),
        ),
        Exercise(
          id: 3, familyMemberId: memberId, exerciseDate: _daysAgo(5),
          activityType: ExerciseType.cycling, duration: 60,
          distance: 15.0, distanceUnit: DistanceUnit.kilometers,
          calories: 450, syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(5), updatedAt: _daysAgo(5),
        ),
      ];
  }

  // ─── Hydration ───────────────────────────────────────────────

  static List<Hydration> hydrationRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        Hydration(
          id: 1, familyMemberId: memberId, date: _daysAgo(0),
          waterIntake: 2500, unit: VolumeUnit.milliliters,
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(0), updatedAt: _daysAgo(0),
        ),
        Hydration(
          id: 2, familyMemberId: memberId, date: _daysAgo(1),
          waterIntake: 2000, unit: VolumeUnit.milliliters,
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(1), updatedAt: _daysAgo(1),
        ),
      ];
  }

  // ─── Medical Visits ──────────────────────────────────────────

  static List<MedicalVisit> medicalVisitRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        MedicalVisit(
          id: 1, familyMemberId: memberId, visitDate: _daysAgo(15),
          hospitalName: 'Apollo Hospital', doctorName: 'Dr. Anita Desai',
          department: Department.generalMedicine,
          reasonForVisit: 'Annual health checkup',
          diagnosisNotes: 'All vitals normal. Vitamin D slightly low.',
          cost: 2500, paymentMode: PaymentMode.insurance,
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(15), updatedAt: _daysAgo(15),
        ),
        MedicalVisit(
          id: 2, familyMemberId: memberId, visitDate: _daysAgo(60),
          hospitalName: 'Fortis Healthcare', doctorName: 'Dr. Vikram Mehta',
          department: Department.cardiology,
          reasonForVisit: 'Chest discomfort',
          diagnosisNotes: 'ECG normal. Stress test recommended.',
          followUpDate: _daysAgo(30), cost: 3500, paymentMode: PaymentMode.card,
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(60), updatedAt: _daysAgo(60),
        ),
      ];
  }

  // ─── Appointments ────────────────────────────────────────────

  static List<Appointment> appointmentRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        Appointment(
          id: 1, familyMemberId: memberId,
          appointmentDate: _now.add(const Duration(days: 7)),
          appointmentTime: '10:30 AM',
          doctorName: 'Dr. Anita Desai', hospitalName: 'Apollo Hospital',
          department: Department.generalMedicine,
          purpose: 'Follow-up checkup',
          reminderEnabled: true, reminderTime: ReminderTime.oneDay,
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(2), updatedAt: _daysAgo(2),
        ),
        Appointment(
          id: 2, familyMemberId: memberId,
          appointmentDate: _now.add(const Duration(days: 14)),
          appointmentTime: '02:00 PM',
          doctorName: 'Dr. Rajesh Kumar', hospitalName: 'Max Hospital',
          department: Department.dermatology,
          purpose: 'Skin rash consultation',
          syncStatus: SyncStatus.pending,
          createdAt: _daysAgo(1), updatedAt: _daysAgo(1),
        ),
      ];
  }

  // ─── Prescriptions ──────────────────────────────────────────

  static List<Prescription> prescriptionRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        Prescription(
          id: 1, familyMemberId: memberId,
          medicationName: 'Vitamin D3 60K',
          dosage: '60,000 IU', frequency: MedicationFrequency.weekly,
          route: MedicationRoute.oral, startDate: _daysAgo(30),
          endDate: _daysAgo(30).add(const Duration(days: 60)),
          prescribedBy: 'Dr. Anita Desai',
          purpose: 'Vitamin D deficiency',
          instructions: 'Take with milk after dinner',
          status: MedicationStatus.active, syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(30), updatedAt: _daysAgo(30),
        ),
        Prescription(
          id: 2, familyMemberId: memberId,
          medicationName: 'Amoxicillin 500mg',
          dosage: '500mg', frequency: MedicationFrequency.thriceDaily,
          route: MedicationRoute.oral, startDate: _daysAgo(10),
          endDate: _daysAgo(3),
          prescribedBy: 'Dr. Anita Desai', purpose: 'Throat infection',
          status: MedicationStatus.completed, syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(10), updatedAt: _daysAgo(3),
        ),
      ];
  }

  // ─── Allergies ───────────────────────────────────────────────

  static List<Allergy> allergyRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        Allergy(
          id: 1, familyMemberId: memberId, allergen: 'Peanuts',
          reactionType: AllergyType.food, severity: AllergySeverity.severe,
          diagnosedDate: _daysAgo(365),
          symptoms: 'Hives, swelling, difficulty breathing',
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(365), updatedAt: _daysAgo(365),
        ),
        Allergy(
          id: 2, familyMemberId: memberId, allergen: 'Dust mites',
          reactionType: AllergyType.environmental,
          severity: AllergySeverity.mild, diagnosedDate: _daysAgo(200),
          symptoms: 'Sneezing, runny nose',
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(200), updatedAt: _daysAgo(200),
        ),
      ];
  }

  // ─── Documents ───────────────────────────────────────────────
  // Seed documents have no real scanned pages (pagePaths is empty — the
  // library shows a placeholder thumbnail for these) since they were never
  // actually captured on a device. Anything scanned for real during the
  // session gets real pagePaths and shows the actual image.

  static List<Document> documentRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        Document(
          id: 1, familyMemberId: memberId,
          title: 'Lipid profile — Aug 2026',
          category: DocumentCategory.labReport,
          ocrText: 'LDL cholesterol: 118 mg/dL\nHDL cholesterol: 52 mg/dL\nTriglycerides: 140 mg/dL',
          scannedDate: _daysAgo(7),
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(7), updatedAt: _daysAgo(7),
        ),
        Document(
          id: 2, familyMemberId: memberId,
          title: 'Amoxicillin prescription',
          category: DocumentCategory.prescription,
          ocrText: 'Amoxicillin 500mg\nTwice daily for 7 days\nDr. Vikram Mehta',
          scannedDate: _daysAgo(40),
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(40), updatedAt: _daysAgo(40),
        ),
        Document(
          id: 3, familyMemberId: memberId,
          title: 'Apollo Hospital — consultation bill',
          category: DocumentCategory.bill,
          scannedDate: _daysAgo(90),
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(90), updatedAt: _daysAgo(90),
        ),
      ];
  }

  // ─── Vaccines ────────────────────────────────────────────────

  static List<Vaccine> vaccineRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        Vaccine(
          id: 1, familyMemberId: memberId, vaccineName: 'COVID-19 Booster',
          vaccineDate: _daysAgo(180), doseNumber: 3,
          administeredBy: 'Dr. Sneha Patel', location: 'City Vaccination Center',
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(180), updatedAt: _daysAgo(180),
        ),
        Vaccine(
          id: 2, familyMemberId: memberId, vaccineName: 'Influenza (Flu)',
          vaccineDate: _daysAgo(60), doseNumber: 1,
          administeredBy: 'Dr. Anita Desai', location: 'Apollo Hospital',
          nextDueDate: _now.add(const Duration(days: 305)),
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(60), updatedAt: _daysAgo(60),
        ),
      ];
  }

  // ─── Medications ─────────────────────────────────────────────

  static List<Medication> medicationRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        Medication(
          id: 1, familyMemberId: memberId,
          medicationName: 'Multivitamin',
          sourceType: MedicationSourceType.supplement,
          dosage: '1 tablet', frequency: MedicationFrequency.onceDaily,
          route: MedicationRoute.oral, startDate: _daysAgo(90),
          status: MedicationStatus.active, purpose: 'General wellness',
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(90), updatedAt: _daysAgo(90),
        ),
        Medication(
          id: 2, familyMemberId: memberId,
          medicationName: 'Cetirizine 10mg',
          sourceType: MedicationSourceType.otc,
          dosage: '10mg', frequency: MedicationFrequency.asNeeded,
          route: MedicationRoute.oral, startDate: _daysAgo(30),
          status: MedicationStatus.active, purpose: 'Allergy relief',
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(30), updatedAt: _daysAgo(30),
        ),
      ];
  }

  // ─── Lab Results ─────────────────────────────────────────────

  static List<LabResult> labResultRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        LabResult(
          id: 1, familyMemberId: memberId, testName: 'Complete Blood Count',
          testDate: _daysAgo(15), result: 'Normal',
          labName: 'SRL Diagnostics', orderedBy: 'Dr. Anita Desai',
          notes: 'All parameters within range',
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(15), updatedAt: _daysAgo(15),
        ),
        LabResult(
          id: 2, familyMemberId: memberId, testName: 'Vitamin D',
          testDate: _daysAgo(15), result: '18 ng/mL',
          normalRange: '30-100 ng/mL', unit: 'ng/mL',
          labName: 'SRL Diagnostics', orderedBy: 'Dr. Anita Desai',
          notes: 'Below normal — supplementation started',
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(15), updatedAt: _daysAgo(15),
        ),
        LabResult(
          id: 3, familyMemberId: memberId, testName: 'Lipid Profile',
          testDate: _daysAgo(15), result: 'Borderline',
          labName: 'SRL Diagnostics', orderedBy: 'Dr. Vikram Mehta',
          notes: 'LDL slightly elevated at 135 mg/dL',
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(15), updatedAt: _daysAgo(15),
        ),
      ];
  }

  // ─── Radiology Results ───────────────────────────────────────

  static List<RadiologyResult> radiologyResultRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        RadiologyResult(
          id: 1, familyMemberId: memberId, scanType: 'X-Ray',
          bodyPart: 'Chest', scanDate: _daysAgo(60),
          radiologyCenter: 'Apollo Radiology',
          orderedBy: 'Dr. Vikram Mehta',
          findings: 'No abnormalities detected. Heart size normal.',
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(60), updatedAt: _daysAgo(60),
        ),
      ];
  }

  // ─── Medical History ─────────────────────────────────────────

  static List<MedicalHistory> medicalHistoryRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        MedicalHistory(
          id: 1, familyMemberId: memberId, condition: 'Seasonal Allergies',
          diagnosedDate: _daysAgo(730),
          status: MedicalConditionStatus.chronic,
          treatedBy: 'Dr. Anita Desai',
          treatment: 'Antihistamines as needed',
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(730), updatedAt: _daysAgo(30),
        ),
        MedicalHistory(
          id: 2, familyMemberId: memberId, condition: 'Appendicitis',
          diagnosedDate: _daysAgo(1825),
          status: MedicalConditionStatus.resolved,
          treatedBy: 'Dr. Suresh Nair',
          treatment: 'Appendectomy surgery',
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(1825), updatedAt: _daysAgo(1825),
        ),
      ];
  }

  // ─── Surgeries ───────────────────────────────────────────────

  static List<Surgery> surgeryRecords(int memberId) {
    if (memberId != 1) return const [];

    return [
        Surgery(
          id: 1, familyMemberId: memberId, surgeryName: 'Appendectomy',
          surgeryDate: _daysAgo(1825), hospital: 'AIIMS Delhi',
          surgeon: 'Dr. Suresh Nair', reason: 'Acute appendicitis',
          notes: 'Laparoscopic procedure. Smooth recovery.',
          syncStatus: SyncStatus.synced,
          createdAt: _daysAgo(1825), updatedAt: _daysAgo(1825),
        ),
      ];
  }

  // ─── Chart Data Helpers ──────────────────────────────────────

  static List<ChartDataPoint> generateChartData({
    required int count,
    required double baseValue,
    double variance = 10,
    double? secondaryBase,
    double secondaryVariance = 8,
  }) {
    final now = DateTime.now();
    return List.generate(count, (i) {
      final daysAgo = count - 1 - i;
      final value = baseValue + (i % 3 == 0 ? variance : -variance / 2) +
          (i * 0.5);
      return ChartDataPoint(
        timestamp: now.subtract(Duration(days: daysAgo)),
        value: value.clamp(baseValue - variance * 2, baseValue + variance * 2),
        secondaryValue: secondaryBase != null
            ? (secondaryBase +
                    (i % 2 == 0
                        ? secondaryVariance
                        : -secondaryVariance / 2))
                .clamp(secondaryBase - secondaryVariance * 2,
                    secondaryBase + secondaryVariance * 2)
            : null,
      );
    });
  }
}
