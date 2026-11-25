import 'package:intl/intl.dart';

import '../models/domain_config.dart';
import '../models/field_descriptor.dart';
import '../models/record_item.dart';

/// Converts between what the form holds, what the API stores, and what the
/// screens show. Field types follow module_registry.dart.
class RecordFormat {
  RecordFormat._();

  static final _day = DateFormat('yyyy-MM-dd');
  static final _showDay = DateFormat('dd MMM yyyy');
  static final _showDateTime = DateFormat('dd MMM yyyy, hh:mm a');

  /// Form values -> API payload. Empty fields are sent as null so an edit can clear them.
  static Map<String, dynamic> toPayload(
      DomainConfig config, Map<String, dynamic> form) {
    final out = <String, dynamic>{};
    for (final f in config.fields) {
      if (f is FileFieldDescriptor)
        continue; // attachments arrive in a later release
      out[f.key] = _toApi(f, form[f.key]);
    }
    return out;
  }

  static dynamic _toApi(FieldDescriptor f, dynamic v) {
    if (v == null || (v is String && v.trim().isEmpty)) return null;
    return switch (f) {
      TextFieldDescriptor _ => (v as String).trim(),
      NumberFieldDescriptor d => _number(v, d.decimal),
      MeasurementFieldDescriptor d => {
          'value': _number(v, d.decimal),
          'unit': d.unitType.defaultUnit
        },
      DateFieldDescriptor _ => _day.format(v as DateTime),
      DateTimeFieldDescriptor _ => (v as DateTime).toUtc().toIso8601String(),
      _ => v, // enum value, boolean, HH:MM time
    };
  }

  static num? _number(dynamic v, bool decimal) {
    final n = num.tryParse(v.toString().trim().replaceAll(',', '.'));
    if (n == null) return null;
    return decimal ? n : n.round();
  }

  /// API payload -> form values, for editing.
  static Map<String, dynamic> toForm(
      DomainConfig config, Map<String, dynamic> payload) {
    final out = <String, dynamic>{};
    for (final f in config.fields) {
      final v = payload[f.key];
      if (v == null) continue;
      out[f.key] = switch (f) {
        NumberFieldDescriptor _ => _plain(v),
        MeasurementFieldDescriptor _ => _plain((v as Map)['value']),
        DateFieldDescriptor _ => DateTime.parse(v as String),
        DateTimeFieldDescriptor _ => DateTime.parse(v as String).toLocal(),
        _ => v,
      };
    }
    return out;
  }

  static String _plain(dynamic n) {
    if (n is num && n == n.roundToDouble()) return n.toInt().toString();
    return n.toString();
  }

  /// A stored value as text for the detail screen.
  static String display(FieldDescriptor f, dynamic v) {
    if (v == null) return '—';
    return switch (f) {
      EnumFieldDescriptor d =>
        d.options.where((o) => o.value == v).firstOrNull?.displayName ?? '$v',
      BooleanFieldDescriptor _ => v == true ? 'Yes' : 'No',
      DateFieldDescriptor _ => _showDay.format(DateTime.parse(v as String)),
      DateTimeFieldDescriptor _ =>
        _showDateTime.format(DateTime.parse(v as String).toLocal()),
      MeasurementFieldDescriptor _ => _measurement(v),
      NumberFieldDescriptor d =>
        '${_plain(v)}${d.unit != null ? ' ${d.unit}' : ''}',
      _ => '$v',
    };
  }

  static String _measurement(dynamic v) {
    final m = v as Map;
    final entered = m['entered'] as Map?;
    final main = '${_plain(m['value'])} ${m['unit']}';
    if (entered == null || entered['unit'] == m['unit']) return main;
    return '$main (entered ${_plain(entered['value'])} ${entered['unit']})';
  }

  static String? _field(DomainConfig config, RecordItem r, String key) {
    final f = config.fields.where((f) => f.key == key).firstOrNull;
    final v = r.payload[key];
    if (f == null || v == null) return null;
    return display(f, v);
  }

  /// The list-card title for a record.
  static String title(DomainConfig config, RecordItem r) {
    String? f(String k) => _field(config, r, k);
    final p = r.payload;
    return switch (r.module) {
          'blood_pressure' => '${p['systolic']}/${p['diastolic']} mmHg',
          'heart_rate' => '${p['bpm']} bpm',
          'oxygen_saturation' => '${p['spO2']}%',
          'sleep' => '${_plain(p['hoursSlept'])} hrs',
          'weight' => f('weight'),
          'height' => f('height'),
          'blood_glucose' => f('glucose'),
          'temperature' => f('temperature'),
          'hydration' => f('waterIntake'),
          'exercise' => f('activityType'),
          'medical_visit' => f('hospitalName'),
          'appointment' => f('doctorName'),
          'prescription' || 'medication' => f('medicationName'),
          'allergy' => f('allergen'),
          'vaccine' => f('vaccineName'),
          'radiology_result' => '${p['scanType']} - ${p['bodyPart']}',
          'medical_history' => f('condition'),
          'surgery' => f('surgeryName'),
          _ => null,
        } ??
        config.domainName;
  }

  /// The list-card second line for a record.
  static String? subtitle(DomainConfig config, RecordItem r) {
    String? f(String k) => _field(config, r, k);
    String? join(List<String?> parts) {
      final s =
          parts.whereType<String>().where((x) => x.isNotEmpty).join(' • ');
      return s.isEmpty ? null : s;
    }

    return switch (r.module) {
      'blood_pressure' => f('armSide'),
      'blood_glucose' => f('mealContext'),
      'heart_rate' => f('activityContext'),
      'temperature' => f('location'),
      'sleep' => f('quality'),
      'exercise' => join([
          '${r.payload['duration']} min',
          f('calories') != null ? '${f('calories')} kcal' : null
        ]),
      'medical_visit' => f('reasonForVisit'),
      'appointment' => join([f('appointmentTime'), f('purpose')]),
      'prescription' => join([f('dosage'), f('frequency')]),
      'medication' => join([f('dosage'), f('status')]),
      'allergy' => join([f('reactionType'), f('severity')]),
      'vaccine' => r.payload['doseNumber'] != null
          ? 'Dose ${r.payload['doseNumber']}'
          : f('administeredBy'),
      'radiology_result' => f('findings'),
      'medical_history' => f('status'),
      'surgery' => f('hospital'),
      _ => f('notes'),
    };
  }
}
