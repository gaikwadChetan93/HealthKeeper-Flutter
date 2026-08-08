class FamilyMember {
  final int id;
  final String name;
  final int age;
  final String relation;
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FamilyMember({
    this.id = 0,
    required this.name,
    required this.age,
    required this.relation,
    this.avatarPath,
    required this.createdAt,
    required this.updatedAt,
  });

  FamilyMember copyWith({
    int? id,
    String? name,
    int? age,
    String? relation,
    String? avatarPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      relation: relation ?? this.relation,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
