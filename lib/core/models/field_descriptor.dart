enum LayoutWidth { full, half }

enum UnitType {
  weight(defaultUnit: 'kg', alternateUnit: 'lbs'),
  height(defaultUnit: 'cm', alternateUnit: 'ft-in'),
  bloodPressure(defaultUnit: 'mmHg', alternateUnit: 'mmHg'),
  temperature(defaultUnit: '°F', alternateUnit: '°C'),
  bloodGlucose(defaultUnit: 'mg/dL', alternateUnit: 'mmol/L'),
  distance(defaultUnit: 'km', alternateUnit: 'miles'),
  volume(defaultUnit: 'ml', alternateUnit: 'oz');

  final String defaultUnit;
  final String alternateUnit;
  const UnitType({required this.defaultUnit, required this.alternateUnit});
}

class EnumOption {
  final String value;
  final String displayName;

  const EnumOption(this.value, this.displayName);
}

sealed class FieldDescriptor {
  final String key;
  final String label;
  final bool required;
  final bool isAdvanced;
  final LayoutWidth layoutWidth;
  final String? pairedWith;

  const FieldDescriptor({
    required this.key,
    required this.label,
    this.required = false,
    this.isAdvanced = false,
    this.layoutWidth = LayoutWidth.full,
    this.pairedWith,
  });
}

class TextFieldDescriptor extends FieldDescriptor {
  final bool multiline;
  final int? minLength;
  final int? maxLength;
  final String? placeholder;

  const TextFieldDescriptor({
    required super.key,
    required super.label,
    super.required,
    super.isAdvanced,
    super.layoutWidth,
    super.pairedWith,
    this.multiline = false,
    this.minLength,
    this.maxLength,
    this.placeholder,
  });
}

class NumberFieldDescriptor extends FieldDescriptor {
  final bool decimal;
  final double? min;
  final double? max;
  final String? unit;

  const NumberFieldDescriptor({
    required super.key,
    required super.label,
    super.required,
    super.isAdvanced,
    super.layoutWidth,
    super.pairedWith,
    this.decimal = false,
    this.min,
    this.max,
    this.unit,
  });
}

class DateFieldDescriptor extends FieldDescriptor {
  final bool allowFuture;
  final bool allowPast;

  const DateFieldDescriptor({
    required super.key,
    required super.label,
    super.required,
    super.isAdvanced,
    super.layoutWidth,
    super.pairedWith,
    this.allowFuture = true,
    this.allowPast = true,
  });
}

class DateTimeFieldDescriptor extends FieldDescriptor {
  final bool allowFuture;
  final bool allowPast;

  const DateTimeFieldDescriptor({
    required super.key,
    required super.label,
    super.required,
    super.isAdvanced,
    super.layoutWidth,
    super.pairedWith,
    this.allowFuture = true,
    this.allowPast = true,
  });
}

class TimeFieldDescriptor extends FieldDescriptor {
  const TimeFieldDescriptor({
    required super.key,
    required super.label,
    super.required,
    super.isAdvanced,
    super.layoutWidth,
    super.pairedWith,
  });
}

class EnumFieldDescriptor extends FieldDescriptor {
  final List<EnumOption> options;

  const EnumFieldDescriptor({
    required super.key,
    required super.label,
    required this.options,
    super.required,
    super.isAdvanced,
    super.layoutWidth,
    super.pairedWith,
  });
}

class BooleanFieldDescriptor extends FieldDescriptor {
  const BooleanFieldDescriptor({
    required super.key,
    required super.label,
    super.required,
    super.isAdvanced,
    super.layoutWidth,
    super.pairedWith,
  });
}

class FileFieldDescriptor extends FieldDescriptor {
  final bool allowMultiple;
  final int maxFiles;
  final int maxSizeMB;
  final List<String> acceptedTypes;

  const FileFieldDescriptor({
    required super.key,
    required super.label,
    super.required,
    super.isAdvanced,
    super.layoutWidth,
    super.pairedWith,
    this.allowMultiple = true,
    this.maxFiles = 5,
    this.maxSizeMB = 10,
    this.acceptedTypes = const ['image/*', 'application/pdf'],
  });
}

class MeasurementFieldDescriptor extends FieldDescriptor {
  final UnitType unitType;
  final double? min;
  final double? max;
  final bool decimal;

  const MeasurementFieldDescriptor({
    required super.key,
    required super.label,
    required this.unitType,
    super.required,
    super.isAdvanced,
    super.layoutWidth,
    super.pairedWith,
    this.min,
    this.max,
    this.decimal = true,
  });
}
