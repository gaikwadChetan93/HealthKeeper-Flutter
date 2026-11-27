/// One health record from the API, for any module. Field values are in
/// [payload], keyed by the module's field keys (see module_registry.dart).
class RecordItem {
  final String id;
  final String memberId;
  final String module;
  final DateTime recordDate;
  final Map<String, dynamic> payload;

  /// The saved doctor this record is linked to, if any.
  final String? doctorId;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecordItem({
    required this.id,
    required this.memberId,
    required this.module,
    required this.recordDate,
    required this.payload,
    this.doctorId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecordItem.fromJson(Map<String, dynamic> j) => RecordItem(
        id: j['id'] as String,
        memberId: j['member_id'] as String,
        module: j['module'] as String,
        recordDate: DateTime.parse(j['record_date'] as String).toLocal(),
        payload: Map<String, dynamic>.from(j['payload'] as Map),
        doctorId: j['doctor_id'] as String?,
        version: j['version'] as int,
        createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(j['updated_at'] as String).toLocal(),
      );
}

/// What the signed-in person's account looks like, from GET /v1/me.
class Me {
  final String id;
  final String email;
  final String name;
  final String planId;
  final Map<String, dynamic> planFeatures;
  final String? selfMemberId;
  final bool healthDataConsent;

  const Me({
    required this.id,
    required this.email,
    required this.name,
    required this.planId,
    required this.planFeatures,
    required this.selfMemberId,
    required this.healthDataConsent,
  });

  int? get maxFamilyMembers =>
      (planFeatures['max_family_members'] as Map?)?['limit'] as int?;

  factory Me.fromJson(Map<String, dynamic> j) => Me(
        id: j['id'] as String,
        email: j['email'] as String,
        name: j['name'] as String,
        planId: (j['plan'] as Map)['id'] as String,
        planFeatures:
            Map<String, dynamic>.from((j['plan'] as Map)['features'] as Map),
        selfMemberId: j['self_member_id'] as String?,
        healthDataConsent: j['health_data_consent'] as bool,
      );
}
