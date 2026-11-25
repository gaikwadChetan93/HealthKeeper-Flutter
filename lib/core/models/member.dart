import 'field_descriptor.dart';

/// A family member as stored by the API. Only adults (18+) for now.
class Member {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final int age;
  final String? sex;
  final String relation;
  final int version;

  const Member({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.age,
    required this.relation,
    required this.version,
    this.sex,
  });

  bool get isSelf => relation == 'self';

  String get relationLabel => labelFor(relations, relation);

  factory Member.fromJson(Map<String, dynamic> j) => Member(
        id: j['id'] as String,
        name: j['name'] as String,
        dateOfBirth: DateTime.parse(j['date_of_birth'] as String),
        age: j['age'] as int,
        sex: j['sex'] as String?,
        relation: j['relation'] as String,
        version: j['version'] as int,
      );

  static const relations = [
    EnumOption('self', 'Self'),
    EnumOption('spouse', 'Spouse'),
    EnumOption('parent', 'Parent'),
    EnumOption('child', 'Child (18+)'),
    EnumOption('sibling', 'Sibling'),
    EnumOption('grandparent', 'Grandparent'),
    EnumOption('other', 'Other'),
  ];

  static const sexes = [
    EnumOption('female', 'Female'),
    EnumOption('male', 'Male'),
    EnumOption('other', 'Other'),
  ];

  static String labelFor(List<EnumOption> options, String? value) =>
      options.where((o) => o.value == value).firstOrNull?.displayName ??
      (value ?? '');
}
