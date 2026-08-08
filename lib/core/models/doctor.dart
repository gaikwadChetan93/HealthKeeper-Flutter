class Doctor {
  final int id;
  final String name;
  final String speciality;
  final String contactNumber;
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Doctor({
    this.id = 0,
    required this.name,
    required this.speciality,
    required this.contactNumber,
    this.avatarPath,
    required this.createdAt,
    required this.updatedAt,
  });

  Doctor copyWith({
    int? id,
    String? name,
    String? speciality,
    String? contactNumber,
    String? avatarPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      speciality: speciality ?? this.speciality,
      contactNumber: contactNumber ?? this.contactNumber,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
