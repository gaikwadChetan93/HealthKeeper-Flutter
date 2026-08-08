import 'package:flutter/material.dart';

import '../models/domain_config.dart';
import '../models/field_descriptor.dart';

// ─── Quick Health Modules ──────────────────────────────────────

class MedicalVisitConfig extends DomainConfig {
  @override final domainName = 'Medical Visit';
  @override final domainKey = 'medical_visit';
  @override final icon = Icons.local_hospital_outlined;
  @override final category = ModuleCategory.quickHealth;
  @override final sortField = 'visitDate';
  @override final shortDescription = 'Track your medical visits';
  @override final emptyStateTitle = 'No Medical Visits Yet';
  @override final emptyStateDescription = 'Start tracking your medical visits to keep a record.';
  @override final emptyStateCTA = 'Add Medical Visit';
  @override
  final fields = const <FieldDescriptor>[
    DateTimeFieldDescriptor(key: 'visitDate', label: 'Visit Date', required: true, allowFuture: false),
    TextFieldDescriptor(key: 'hospitalName', label: 'Hospital / Clinic', required: true),
    TextFieldDescriptor(key: 'doctorName', label: 'Doctor Name'),
    TextFieldDescriptor(key: 'reasonForVisit', label: 'Reason for Visit', required: true),
    TextFieldDescriptor(key: 'diagnosisNotes', label: 'Diagnosis Notes', multiline: true),
    FileFieldDescriptor(key: 'attachments', label: 'Attachments', isAdvanced: true),
    EnumFieldDescriptor(key: 'department', label: 'Department', isAdvanced: true, options: [
      EnumOption('CARDIOLOGY', 'Cardiology'), EnumOption('ORTHOPEDICS', 'Orthopedics'),
      EnumOption('NEUROLOGY', 'Neurology'), EnumOption('PEDIATRICS', 'Pediatrics'),
      EnumOption('DERMATOLOGY', 'Dermatology'), EnumOption('GYNECOLOGY', 'Gynecology'),
      EnumOption('UROLOGY', 'Urology'), EnumOption('ENT', 'ENT'),
      EnumOption('OPHTHALMOLOGY', 'Ophthalmology'), EnumOption('DENTISTRY', 'Dentistry'),
      EnumOption('PSYCHIATRY', 'Psychiatry'), EnumOption('GENERAL_MEDICINE', 'General Medicine'),
      EnumOption('EMERGENCY', 'Emergency'), EnumOption('OTHER', 'Other'),
    ]),
    DateFieldDescriptor(key: 'followUpDate', label: 'Follow-Up Date', isAdvanced: true),
    NumberFieldDescriptor(key: 'cost', label: 'Cost', decimal: true, isAdvanced: true, layoutWidth: LayoutWidth.half),
    EnumFieldDescriptor(key: 'paymentMode', label: 'Payment Mode', isAdvanced: true, layoutWidth: LayoutWidth.half, options: [
      EnumOption('CASH', 'Cash'), EnumOption('CARD', 'Card'),
      EnumOption('UPI', 'UPI'), EnumOption('INSURANCE', 'Insurance'),
      EnumOption('OTHER', 'Other'),
    ]),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class AppointmentConfig extends DomainConfig {
  @override final domainName = 'Appointment';
  @override final domainKey = 'appointment';
  @override final icon = Icons.calendar_today_outlined;
  @override final category = ModuleCategory.quickHealth;
  @override final sortField = 'appointmentDate';
  @override final shortDescription = 'Schedule appointments';
  @override final emptyStateTitle = 'No Appointments Yet';
  @override final emptyStateDescription = 'Schedule your upcoming appointments.';
  @override final emptyStateCTA = 'Add Appointment';
  @override
  final fields = const <FieldDescriptor>[
    DateFieldDescriptor(key: 'appointmentDate', label: 'Appointment Date', required: true),
    TimeFieldDescriptor(key: 'appointmentTime', label: 'Appointment Time', required: true),
    TextFieldDescriptor(key: 'doctorName', label: 'Doctor Name', required: true),
    TextFieldDescriptor(key: 'hospitalName', label: 'Hospital / Clinic', required: true),
    TextFieldDescriptor(key: 'purpose', label: 'Purpose'),
    EnumFieldDescriptor(key: 'department', label: 'Department', isAdvanced: true, options: [
      EnumOption('CARDIOLOGY', 'Cardiology'), EnumOption('ORTHOPEDICS', 'Orthopedics'),
      EnumOption('NEUROLOGY', 'Neurology'), EnumOption('PEDIATRICS', 'Pediatrics'),
      EnumOption('DERMATOLOGY', 'Dermatology'), EnumOption('GENERAL_MEDICINE', 'General Medicine'),
      EnumOption('OTHER', 'Other'),
    ]),
    BooleanFieldDescriptor(key: 'reminderEnabled', label: 'Enable Reminder', isAdvanced: true),
    EnumFieldDescriptor(key: 'reminderTime', label: 'Reminder Time', isAdvanced: true, options: [
      EnumOption('ONE_HOUR', '1 hour before'), EnumOption('ONE_DAY', '1 day before'),
      EnumOption('TWO_DAYS', '2 days before'), EnumOption('ONE_WEEK', '1 week before'),
    ]),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class AllergyConfig extends DomainConfig {
  @override final domainName = 'Allergy';
  @override final domainKey = 'allergy';
  @override final icon = Icons.warning_amber_outlined;
  @override final category = ModuleCategory.quickHealth;
  @override final sortField = 'diagnosedDate';
  @override final shortDescription = 'Track your allergies';
  @override final emptyStateTitle = 'No Allergies Recorded';
  @override final emptyStateDescription = 'Record your allergies for quick reference.';
  @override final emptyStateCTA = 'Add Allergy';
  @override
  final fields = const <FieldDescriptor>[
    TextFieldDescriptor(key: 'allergen', label: 'Allergen', required: true),
    EnumFieldDescriptor(key: 'reactionType', label: 'Type', required: true, layoutWidth: LayoutWidth.half, options: [
      EnumOption('FOOD', 'Food Allergy'), EnumOption('DRUG', 'Drug/Medication'),
      EnumOption('ENVIRONMENTAL', 'Environmental'), EnumOption('INSECT', 'Insect Sting'),
      EnumOption('OTHER', 'Other'),
    ]),
    EnumFieldDescriptor(key: 'severity', label: 'Severity', required: true, layoutWidth: LayoutWidth.half, options: [
      EnumOption('MILD', 'Mild'), EnumOption('MODERATE', 'Moderate'),
      EnumOption('SEVERE', 'Severe/Life-threatening'),
    ]),
    DateFieldDescriptor(key: 'diagnosedDate', label: 'Diagnosed Date', required: true, allowFuture: false),
    TextFieldDescriptor(key: 'symptoms', label: 'Symptoms', multiline: true),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class VaccineConfig extends DomainConfig {
  @override final domainName = 'Vaccine';
  @override final domainKey = 'vaccine';
  @override final icon = Icons.vaccines_outlined;
  @override final category = ModuleCategory.quickHealth;
  @override final sortField = 'vaccineDate';
  @override final shortDescription = 'Track vaccinations';
  @override final emptyStateTitle = 'No Vaccines Recorded';
  @override final emptyStateDescription = 'Keep track of your vaccinations.';
  @override final emptyStateCTA = 'Add Vaccine';
  @override
  final fields = const <FieldDescriptor>[
    TextFieldDescriptor(key: 'vaccineName', label: 'Vaccine Name', required: true),
    DateFieldDescriptor(key: 'vaccineDate', label: 'Vaccination Date', required: true, allowFuture: false),
    DateFieldDescriptor(key: 'nextDueDate', label: 'Next Due Date'),
    NumberFieldDescriptor(key: 'doseNumber', label: 'Dose Number', min: 1, max: 10, layoutWidth: LayoutWidth.half),
    FileFieldDescriptor(key: 'certificate', label: 'Certificate', isAdvanced: true),
    TextFieldDescriptor(key: 'administeredBy', label: 'Administered By', isAdvanced: true),
    TextFieldDescriptor(key: 'location', label: 'Location', isAdvanced: true),
    TextFieldDescriptor(key: 'lotNumber', label: 'Lot Number', isAdvanced: true),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class MedicationConfig extends DomainConfig {
  @override final domainName = 'Medication';
  @override final domainKey = 'medication';
  @override final icon = Icons.medication_outlined;
  @override final category = ModuleCategory.quickHealth;
  @override final sortField = 'startDate';
  @override final shortDescription = 'Manage medications';
  @override final emptyStateTitle = 'No Medications';
  @override final emptyStateDescription = 'Track your current and past medications.';
  @override final emptyStateCTA = 'Add Medication';
  @override
  final fields = const <FieldDescriptor>[
    TextFieldDescriptor(key: 'medicationName', label: 'Medication Name', required: true),
    EnumFieldDescriptor(key: 'sourceType', label: 'Source', required: true, options: [
      EnumOption('PRESCRIPTION', 'Prescription'), EnumOption('OTC', 'Over-the-Counter'),
      EnumOption('SUPPLEMENT', 'Supplement/Vitamin'), EnumOption('OTHER', 'Other'),
    ]),
    TextFieldDescriptor(key: 'dosage', label: 'Dosage', required: true, layoutWidth: LayoutWidth.half),
    EnumFieldDescriptor(key: 'frequency', label: 'Frequency', required: true, layoutWidth: LayoutWidth.half, options: [
      EnumOption('ONCE_DAILY', 'Once daily'), EnumOption('TWICE_DAILY', 'Twice daily'),
      EnumOption('THRICE_DAILY', 'Thrice daily'), EnumOption('FOUR_TIMES_DAILY', 'Four times daily'),
      EnumOption('AS_NEEDED', 'As needed'), EnumOption('EVERY_OTHER_DAY', 'Every other day'),
      EnumOption('WEEKLY', 'Weekly'), EnumOption('MONTHLY', 'Monthly'),
    ]),
    EnumFieldDescriptor(key: 'route', label: 'Route', required: true, layoutWidth: LayoutWidth.half, options: [
      EnumOption('ORAL', 'Oral'), EnumOption('TOPICAL', 'Topical'),
      EnumOption('INJECTION', 'Injection'), EnumOption('INHALATION', 'Inhalation'),
      EnumOption('SUBLINGUAL', 'Sublingual'), EnumOption('RECTAL', 'Rectal'),
      EnumOption('TRANSDERMAL', 'Transdermal'), EnumOption('OTHER', 'Other'),
    ]),
    EnumFieldDescriptor(key: 'status', label: 'Status', required: true, layoutWidth: LayoutWidth.half, options: [
      EnumOption('ACTIVE', 'Active'), EnumOption('COMPLETED', 'Completed'),
      EnumOption('STOPPED', 'Stopped'), EnumOption('ON_HOLD', 'On Hold'),
    ]),
    DateFieldDescriptor(key: 'startDate', label: 'Start Date', required: true, layoutWidth: LayoutWidth.half),
    DateFieldDescriptor(key: 'endDate', label: 'End Date', layoutWidth: LayoutWidth.half),
    FileFieldDescriptor(key: 'attachments', label: 'Attachments', isAdvanced: true),
    TextFieldDescriptor(key: 'prescribedBy', label: 'Prescribed By', isAdvanced: true),
    TextFieldDescriptor(key: 'purpose', label: 'Purpose', isAdvanced: true),
    TextFieldDescriptor(key: 'sideEffects', label: 'Side Effects', multiline: true, isAdvanced: true),
    TextFieldDescriptor(key: 'instructions', label: 'Instructions', multiline: true, isAdvanced: true),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class PrescriptionConfig extends DomainConfig {
  @override final domainName = 'Prescription';
  @override final domainKey = 'prescription';
  @override final icon = Icons.receipt_long_outlined;
  @override final category = ModuleCategory.quickHealth;
  @override final sortField = 'startDate';
  @override final shortDescription = 'Manage prescriptions';
  @override final emptyStateTitle = 'No Prescriptions';
  @override final emptyStateDescription = 'Track your prescriptions here.';
  @override final emptyStateCTA = 'Add Prescription';
  @override
  final fields = const <FieldDescriptor>[
    TextFieldDescriptor(key: 'medicationName', label: 'Medication Name', required: true),
    TextFieldDescriptor(key: 'dosage', label: 'Dosage', required: true, layoutWidth: LayoutWidth.half),
    EnumFieldDescriptor(key: 'frequency', label: 'Frequency', required: true, layoutWidth: LayoutWidth.half, options: [
      EnumOption('ONCE_DAILY', 'Once daily'), EnumOption('TWICE_DAILY', 'Twice daily'),
      EnumOption('THRICE_DAILY', 'Thrice daily'), EnumOption('FOUR_TIMES_DAILY', 'Four times daily'),
      EnumOption('AS_NEEDED', 'As needed'), EnumOption('WEEKLY', 'Weekly'), EnumOption('MONTHLY', 'Monthly'),
    ]),
    EnumFieldDescriptor(key: 'route', label: 'Route', required: true, layoutWidth: LayoutWidth.half, options: [
      EnumOption('ORAL', 'Oral'), EnumOption('TOPICAL', 'Topical'),
      EnumOption('INJECTION', 'Injection'), EnumOption('INHALATION', 'Inhalation'),
      EnumOption('OTHER', 'Other'),
    ]),
    EnumFieldDescriptor(key: 'status', label: 'Status', required: true, layoutWidth: LayoutWidth.half, options: [
      EnumOption('ACTIVE', 'Active'), EnumOption('COMPLETED', 'Completed'),
      EnumOption('STOPPED', 'Stopped'), EnumOption('ON_HOLD', 'On Hold'),
    ]),
    DateFieldDescriptor(key: 'startDate', label: 'Start Date', required: true, layoutWidth: LayoutWidth.half),
    DateFieldDescriptor(key: 'endDate', label: 'End Date', layoutWidth: LayoutWidth.half),
    TextFieldDescriptor(key: 'prescribedBy', label: 'Prescribed By', isAdvanced: true),
    TextFieldDescriptor(key: 'purpose', label: 'Purpose', isAdvanced: true),
    FileFieldDescriptor(key: 'attachments', label: 'Attachments', isAdvanced: true),
    TextFieldDescriptor(key: 'sideEffects', label: 'Side Effects', multiline: true, isAdvanced: true),
    TextFieldDescriptor(key: 'instructions', label: 'Instructions', multiline: true, isAdvanced: true),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class LabResultConfig extends DomainConfig {
  @override final domainName = 'Lab Result';
  @override final domainKey = 'lab_result';
  @override final icon = Icons.biotech_outlined;
  @override final category = ModuleCategory.quickHealth;
  @override final sortField = 'testDate';
  @override final shortDescription = 'Track lab results';
  @override final emptyStateTitle = 'No Lab Results';
  @override final emptyStateDescription = 'Add your lab test results here.';
  @override final emptyStateCTA = 'Add Lab Result';
  @override
  final fields = const <FieldDescriptor>[
    TextFieldDescriptor(key: 'testName', label: 'Test Name', required: true),
    DateFieldDescriptor(key: 'testDate', label: 'Test Date', required: true, allowFuture: false),
    TextFieldDescriptor(key: 'result', label: 'Result', required: true),
    TextFieldDescriptor(key: 'unit', label: 'Unit', layoutWidth: LayoutWidth.half),
    TextFieldDescriptor(key: 'normalRange', label: 'Normal Range', layoutWidth: LayoutWidth.half),
    FileFieldDescriptor(key: 'reportFile', label: 'Report File', isAdvanced: true),
    TextFieldDescriptor(key: 'labName', label: 'Lab Name', isAdvanced: true),
    TextFieldDescriptor(key: 'orderedBy', label: 'Ordered By', isAdvanced: true),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class MedicalHistoryConfig extends DomainConfig {
  @override final domainName = 'Medical History';
  @override final domainKey = 'medical_history';
  @override final icon = Icons.history_outlined;
  @override final category = ModuleCategory.quickHealth;
  @override final sortField = 'diagnosedDate';
  @override final shortDescription = 'Track medical history';
  @override final emptyStateTitle = 'No Medical History';
  @override final emptyStateDescription = 'Record your past medical conditions.';
  @override final emptyStateCTA = 'Add Condition';
  @override
  final fields = const <FieldDescriptor>[
    TextFieldDescriptor(key: 'condition', label: 'Condition', required: true),
    DateFieldDescriptor(key: 'diagnosedDate', label: 'Diagnosed Date', required: true, allowFuture: false),
    EnumFieldDescriptor(key: 'status', label: 'Status', required: true, options: [
      EnumOption('ACTIVE', 'Active'), EnumOption('RESOLVED', 'Resolved'),
      EnumOption('IN_REMISSION', 'In Remission'), EnumOption('CHRONIC', 'Chronic'),
    ]),
    TextFieldDescriptor(key: 'treatedBy', label: 'Treated By', isAdvanced: true),
    TextFieldDescriptor(key: 'treatment', label: 'Treatment', multiline: true, isAdvanced: true),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class SurgeryConfig extends DomainConfig {
  @override final domainName = 'Surgery';
  @override final domainKey = 'surgery';
  @override final icon = Icons.medical_services_outlined;
  @override final category = ModuleCategory.quickHealth;
  @override final sortField = 'surgeryDate';
  @override final shortDescription = 'Track surgeries';
  @override final emptyStateTitle = 'No Surgeries Recorded';
  @override final emptyStateDescription = 'Record your surgical history.';
  @override final emptyStateCTA = 'Add Surgery';
  @override
  final fields = const <FieldDescriptor>[
    TextFieldDescriptor(key: 'surgeryName', label: 'Surgery Name', required: true),
    DateFieldDescriptor(key: 'surgeryDate', label: 'Surgery Date', required: true, allowFuture: false),
    TextFieldDescriptor(key: 'hospital', label: 'Hospital', isAdvanced: true),
    TextFieldDescriptor(key: 'surgeon', label: 'Surgeon', isAdvanced: true),
    FileFieldDescriptor(key: 'documents', label: 'Documents', isAdvanced: true),
    TextFieldDescriptor(key: 'reason', label: 'Reason', multiline: true, isAdvanced: true),
    TextFieldDescriptor(key: 'complications', label: 'Complications', multiline: true, isAdvanced: true),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class RadiologyResultConfig extends DomainConfig {
  @override final domainName = 'Radiology Result';
  @override final domainKey = 'radiology_result';
  @override final icon = Icons.image_outlined;
  @override final category = ModuleCategory.quickHealth;
  @override final sortField = 'scanDate';
  @override final shortDescription = 'Track radiology results';
  @override final emptyStateTitle = 'No Radiology Results';
  @override final emptyStateDescription = 'Add your imaging and scan results.';
  @override final emptyStateCTA = 'Add Radiology Result';
  @override
  final fields = const <FieldDescriptor>[
    TextFieldDescriptor(key: 'scanType', label: 'Scan Type', required: true, layoutWidth: LayoutWidth.half),
    TextFieldDescriptor(key: 'bodyPart', label: 'Body Part', required: true, layoutWidth: LayoutWidth.half),
    DateFieldDescriptor(key: 'scanDate', label: 'Scan Date', required: true, allowFuture: false),
    TextFieldDescriptor(key: 'radiologyCenter', label: 'Radiology Center'),
    TextFieldDescriptor(key: 'findings', label: 'Findings', multiline: true),
    FileFieldDescriptor(key: 'reportFiles', label: 'Reports', isAdvanced: true),
    TextFieldDescriptor(key: 'orderedBy', label: 'Ordered By', isAdvanced: true),
    TextFieldDescriptor(key: 'radiologistName', label: 'Radiologist', isAdvanced: true),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

// ─── Vital Overview Modules ────────────────────────────────────

class BloodPressureConfig extends DomainConfig {
  @override final domainName = 'Blood Pressure';
  @override final domainKey = 'blood_pressure';
  @override final icon = Icons.favorite_outline;
  @override final category = ModuleCategory.vitalOverview;
  @override final sortField = 'measurementDate';
  @override final shortDescription = 'Monitor blood pressure';
  @override final emptyStateTitle = 'No Blood Pressure Readings';
  @override final emptyStateDescription = 'Start tracking your blood pressure.';
  @override final emptyStateCTA = 'Add Reading';
  @override
  final fields = const <FieldDescriptor>[
    NumberFieldDescriptor(key: 'systolic', label: 'Systolic', required: true, min: 60, max: 300, unit: 'mmHg', layoutWidth: LayoutWidth.half),
    NumberFieldDescriptor(key: 'diastolic', label: 'Diastolic', required: true, min: 30, max: 200, unit: 'mmHg', layoutWidth: LayoutWidth.half),
    DateTimeFieldDescriptor(key: 'measurementDate', label: 'Measurement Date', required: true, allowFuture: false),
    EnumFieldDescriptor(key: 'armSide', label: 'Arm Side', options: [
      EnumOption('LEFT', 'Left'), EnumOption('RIGHT', 'Right'),
    ]),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class WeightConfig extends DomainConfig {
  @override final domainName = 'Weight';
  @override final domainKey = 'weight';
  @override final icon = Icons.monitor_weight_outlined;
  @override final category = ModuleCategory.vitalOverview;
  @override final sortField = 'measurementDate';
  @override final shortDescription = 'Track your weight';
  @override final emptyStateTitle = 'No Weight Records';
  @override final emptyStateDescription = 'Start tracking your weight.';
  @override final emptyStateCTA = 'Add Weight';
  @override
  final fields = const <FieldDescriptor>[
    MeasurementFieldDescriptor(key: 'weight', label: 'Weight', required: true, unitType: UnitType.weight, min: 1, max: 500),
    DateTimeFieldDescriptor(key: 'measurementDate', label: 'Date', required: true, allowFuture: false),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class HeightConfig extends DomainConfig {
  @override final domainName = 'Height';
  @override final domainKey = 'height';
  @override final icon = Icons.height_outlined;
  @override final category = ModuleCategory.vitalOverview;
  @override final sortField = 'measurementDate';
  @override final shortDescription = 'Track your height';
  @override final emptyStateTitle = 'No Height Records';
  @override final emptyStateDescription = 'Start tracking your height.';
  @override final emptyStateCTA = 'Add Height';
  @override
  final fields = const <FieldDescriptor>[
    MeasurementFieldDescriptor(key: 'height', label: 'Height', required: true, unitType: UnitType.height, min: 30, max: 300),
    DateTimeFieldDescriptor(key: 'measurementDate', label: 'Date', required: true, allowFuture: false),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class BloodGlucoseConfig extends DomainConfig {
  @override final domainName = 'Blood Glucose';
  @override final domainKey = 'blood_glucose';
  @override final icon = Icons.bloodtype_outlined;
  @override final category = ModuleCategory.vitalOverview;
  @override final sortField = 'measurementDate';
  @override final shortDescription = 'Monitor blood glucose';
  @override final emptyStateTitle = 'No Blood Glucose Readings';
  @override final emptyStateDescription = 'Start tracking your blood glucose.';
  @override final emptyStateCTA = 'Add Reading';
  @override
  final fields = const <FieldDescriptor>[
    MeasurementFieldDescriptor(key: 'glucose', label: 'Glucose Level', required: true, unitType: UnitType.bloodGlucose, min: 20, max: 600),
    DateTimeFieldDescriptor(key: 'measurementDate', label: 'Date', required: true, allowFuture: false),
    EnumFieldDescriptor(key: 'mealContext', label: 'Meal Context', options: [
      EnumOption('FASTING', 'Fasting'), EnumOption('BEFORE_MEAL', 'Before meal'),
      EnumOption('AFTER_MEAL', 'After meal (2 hours)'), EnumOption('BEDTIME', 'Bedtime'),
      EnumOption('RANDOM', 'Random'),
    ]),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class HeartRateConfig extends DomainConfig {
  @override final domainName = 'Heart Rate';
  @override final domainKey = 'heart_rate';
  @override final icon = Icons.monitor_heart_outlined;
  @override final category = ModuleCategory.vitalOverview;
  @override final sortField = 'measurementDate';
  @override final shortDescription = 'Monitor heart rate';
  @override final emptyStateTitle = 'No Heart Rate Readings';
  @override final emptyStateDescription = 'Start tracking your heart rate.';
  @override final emptyStateCTA = 'Add Reading';
  @override
  final fields = const <FieldDescriptor>[
    NumberFieldDescriptor(key: 'bpm', label: 'Heart Rate', required: true, min: 30, max: 250, unit: 'bpm'),
    DateTimeFieldDescriptor(key: 'measurementDate', label: 'Date', required: true, allowFuture: false),
    EnumFieldDescriptor(key: 'activityContext', label: 'Activity', options: [
      EnumOption('RESTING', 'Resting'), EnumOption('LIGHT_ACTIVITY', 'Light activity'),
      EnumOption('MODERATE_EXERCISE', 'Moderate exercise'), EnumOption('INTENSE_EXERCISE', 'Intense exercise'),
    ]),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class TemperatureConfig extends DomainConfig {
  @override final domainName = 'Temperature';
  @override final domainKey = 'temperature';
  @override final icon = Icons.thermostat_outlined;
  @override final category = ModuleCategory.vitalOverview;
  @override final sortField = 'measurementDate';
  @override final shortDescription = 'Monitor body temperature';
  @override final emptyStateTitle = 'No Temperature Records';
  @override final emptyStateDescription = 'Start tracking your temperature.';
  @override final emptyStateCTA = 'Add Temperature';
  @override
  final fields = const <FieldDescriptor>[
    MeasurementFieldDescriptor(key: 'temperature', label: 'Temperature', required: true, unitType: UnitType.temperature, min: 90, max: 115),
    DateTimeFieldDescriptor(key: 'measurementDate', label: 'Date', required: true, allowFuture: false),
    EnumFieldDescriptor(key: 'location', label: 'Measurement Location', options: [
      EnumOption('ORAL', 'Oral'), EnumOption('EAR', 'Ear (tympanic)'),
      EnumOption('FOREHEAD', 'Forehead'), EnumOption('ARMPIT', 'Armpit (axillary)'),
      EnumOption('RECTAL', 'Rectal'),
    ]),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class OxygenSaturationConfig extends DomainConfig {
  @override final domainName = 'Oxygen Saturation';
  @override final domainKey = 'oxygen_saturation';
  @override final icon = Icons.air_outlined;
  @override final category = ModuleCategory.vitalOverview;
  @override final sortField = 'measurementDate';
  @override final shortDescription = 'Monitor SpO2';
  @override final emptyStateTitle = 'No SpO2 Readings';
  @override final emptyStateDescription = 'Start tracking your oxygen saturation.';
  @override final emptyStateCTA = 'Add Reading';
  @override
  final fields = const <FieldDescriptor>[
    NumberFieldDescriptor(key: 'spO2', label: 'SpO2', required: true, min: 50, max: 100, unit: '%', decimal: true),
    DateTimeFieldDescriptor(key: 'measurementDate', label: 'Date', required: true, allowFuture: false),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class SleepConfig extends DomainConfig {
  @override final domainName = 'Sleep';
  @override final domainKey = 'sleep';
  @override final icon = Icons.bedtime_outlined;
  @override final category = ModuleCategory.vitalOverview;
  @override final sortField = 'sleepDate';
  @override final shortDescription = 'Track sleep patterns';
  @override final emptyStateTitle = 'No Sleep Records';
  @override final emptyStateDescription = 'Start tracking your sleep.';
  @override final emptyStateCTA = 'Add Sleep Record';
  @override
  final fields = const <FieldDescriptor>[
    DateFieldDescriptor(key: 'sleepDate', label: 'Date', required: true, allowFuture: false),
    NumberFieldDescriptor(key: 'hoursSlept', label: 'Hours Slept', required: true, decimal: true, min: 0, max: 24, unit: 'hrs'),
    EnumFieldDescriptor(key: 'quality', label: 'Sleep Quality', options: [
      EnumOption('POOR', 'Poor'), EnumOption('FAIR', 'Fair'),
      EnumOption('GOOD', 'Good'), EnumOption('EXCELLENT', 'Excellent'),
    ]),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class ExerciseConfig extends DomainConfig {
  @override final domainName = 'Exercise';
  @override final domainKey = 'exercise';
  @override final icon = Icons.fitness_center_outlined;
  @override final category = ModuleCategory.vitalOverview;
  @override final sortField = 'exerciseDate';
  @override final shortDescription = 'Track workouts';
  @override final emptyStateTitle = 'No Exercise Records';
  @override final emptyStateDescription = 'Start tracking your workouts.';
  @override final emptyStateCTA = 'Add Workout';
  @override
  final fields = const <FieldDescriptor>[
    DateFieldDescriptor(key: 'exerciseDate', label: 'Date', required: true, allowFuture: false),
    EnumFieldDescriptor(key: 'activityType', label: 'Activity', required: true, options: [
      EnumOption('WALKING', 'Walking'), EnumOption('RUNNING', 'Running'),
      EnumOption('CYCLING', 'Cycling'), EnumOption('SWIMMING', 'Swimming'),
      EnumOption('GYM', 'Gym/Weights'), EnumOption('YOGA', 'Yoga'),
      EnumOption('SPORTS', 'Sports'), EnumOption('OTHER', 'Other'),
    ]),
    NumberFieldDescriptor(key: 'duration', label: 'Duration', required: true, min: 1, max: 720, unit: 'min', layoutWidth: LayoutWidth.half),
    NumberFieldDescriptor(key: 'calories', label: 'Calories', min: 0, max: 5000, unit: 'kcal', layoutWidth: LayoutWidth.half),
    MeasurementFieldDescriptor(key: 'distance', label: 'Distance', unitType: UnitType.distance, isAdvanced: true),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

class HydrationConfig extends DomainConfig {
  @override final domainName = 'Hydration';
  @override final domainKey = 'hydration';
  @override final icon = Icons.water_drop_outlined;
  @override final category = ModuleCategory.vitalOverview;
  @override final sortField = 'date';
  @override final shortDescription = 'Track water intake';
  @override final emptyStateTitle = 'No Hydration Records';
  @override final emptyStateDescription = 'Start tracking your water intake.';
  @override final emptyStateCTA = 'Add Record';
  @override
  final fields = const <FieldDescriptor>[
    DateFieldDescriptor(key: 'date', label: 'Date', required: true, allowFuture: false),
    MeasurementFieldDescriptor(key: 'waterIntake', label: 'Water Intake', required: true, unitType: UnitType.volume, min: 0, max: 10000),
    TextFieldDescriptor(key: 'notes', label: 'Notes', multiline: true, isAdvanced: true),
  ];
}

// ─── Registry ──────────────────────────────────────────────────

class ModuleRegistry {
  ModuleRegistry._();

  static final _modules = <String, DomainConfig>{
    'medical_visit': MedicalVisitConfig(),
    'appointment': AppointmentConfig(),
    'allergy': AllergyConfig(),
    'vaccine': VaccineConfig(),
    'medication': MedicationConfig(),
    'prescription': PrescriptionConfig(),
    'lab_result': LabResultConfig(),
    'medical_history': MedicalHistoryConfig(),
    'surgery': SurgeryConfig(),
    'radiology_result': RadiologyResultConfig(),
    'blood_pressure': BloodPressureConfig(),
    'weight': WeightConfig(),
    'height': HeightConfig(),
    'blood_glucose': BloodGlucoseConfig(),
    'heart_rate': HeartRateConfig(),
    'temperature': TemperatureConfig(),
    'oxygen_saturation': OxygenSaturationConfig(),
    'sleep': SleepConfig(),
    'exercise': ExerciseConfig(),
    'hydration': HydrationConfig(),
  };

  static DomainConfig? getModuleByKey(String key) => _modules[key];

  static List<DomainConfig> getAllModules() => _modules.values.toList();

  static List<DomainConfig> getModulesByCategory(ModuleCategory category) =>
      _modules.values.where((m) => m.category == category).toList();

  static List<DomainConfig> get quickHealthModules =>
      getModulesByCategory(ModuleCategory.quickHealth);

  static List<DomainConfig> get vitalOverviewModules =>
      getModulesByCategory(ModuleCategory.vitalOverview);
}
