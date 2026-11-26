/// One numeric field in the vital-entry keypad (e.g. blood pressure has
/// two — systolic and diastolic; most vitals have just one).
class VitalEntryField {
  final String key;
  final String label;
  final String unit;
  final int maxDigits;
  final bool decimal;

  const VitalEntryField({
    required this.key,
    required this.label,
    required this.unit,
    this.maxDigits = 3,
    this.decimal = false,
  });
}

/// Everything the keypad screen needs for one vital type: which fields it
/// collects, the context chips underneath, and a short measurement hint.
/// Mirrors the design's `VITAL_SPECS` table.
class VitalEntrySpec {
  final List<VitalEntryField> fields;
  final List<String> chips;
  final String hint;
  final String cta;

  const VitalEntrySpec({
    required this.fields,
    required this.chips,
    this.hint = '',
    required this.cta,
  });
}

const vitalEntrySpecs = <String, VitalEntrySpec>{
  'blood_pressure': VitalEntrySpec(
    fields: [
      VitalEntryField(key: 'systolic', label: 'Systolic', unit: 'mmHg'),
      VitalEntryField(key: 'diastolic', label: 'Diastolic', unit: 'mmHg'),
    ],
    chips: ['Left arm', 'Right arm', 'Seated'],
    hint: 'Sit quietly for five minutes before measuring.',
    cta: 'Save reading',
  ),
  'weight': VitalEntrySpec(
    fields: [VitalEntryField(key: 'weight', label: 'Weight', unit: 'kg', maxDigits: 4, decimal: true)],
    chips: ['Morning', 'Before food'],
    hint: 'Weigh at the same time of day for comparable numbers.',
    cta: 'Save weight',
  ),
  'height': VitalEntrySpec(
    fields: [VitalEntryField(key: 'height', label: 'Height', unit: 'cm')],
    chips: ['Without shoes'],
    cta: 'Save height',
  ),
  'blood_glucose': VitalEntrySpec(
    fields: [VitalEntryField(key: 'glucose', label: 'Glucose', unit: 'mg/dL')],
    chips: ['Fasting', 'Before meal', 'After meal', 'Random'],
    hint: 'Tag the reading — fasting and post-meal ranges differ.',
    cta: 'Save reading',
  ),
  'heart_rate': VitalEntrySpec(
    fields: [VitalEntryField(key: 'bpm', label: 'Pulse', unit: 'bpm')],
    chips: ['Resting', 'After activity'],
    cta: 'Save reading',
  ),
  'temperature': VitalEntrySpec(
    fields: [VitalEntryField(key: 'temperature', label: 'Temperature', unit: '°C', decimal: true)],
    chips: ['Oral', 'Forehead', 'Underarm'],
    cta: 'Save temperature',
  ),
  'oxygen_saturation': VitalEntrySpec(
    fields: [VitalEntryField(key: 'spo2', label: 'SpO2', unit: '%')],
    chips: ['At rest', 'After activity'],
    hint: 'Keep the finger still until the reading settles.',
    cta: 'Save reading',
  ),
  'sleep': VitalEntrySpec(
    fields: [
      VitalEntryField(key: 'hours', label: 'Hours', unit: 'h', maxDigits: 2),
      VitalEntryField(key: 'minutes', label: 'Minutes', unit: 'min', maxDigits: 2),
    ],
    chips: ['Last night', 'Nap'],
    cta: 'Save sleep',
  ),
  // Chip order matches ExerciseType.values exactly — the screen maps the
  // selected chip index straight onto the enum.
  'exercise': VitalEntrySpec(
    fields: [VitalEntryField(key: 'duration', label: 'Duration', unit: 'min')],
    chips: ['Walking', 'Running', 'Cycling', 'Swimming', 'Gym', 'Yoga', 'Sports', 'Other'],
    cta: 'Save exercise',
  ),
  'hydration': VitalEntrySpec(
    fields: [VitalEntryField(key: 'ml', label: 'Amount', unit: 'ml', maxDigits: 4)],
    chips: ['Glass', 'Bottle', 'Litre'],
    hint: 'Tap a preset or type an exact amount.',
    cta: 'Add water',
  ),
};
