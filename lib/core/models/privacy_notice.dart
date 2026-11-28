/// What people read before agreeing, from GET /v1/public/privacy-notice: what is
/// collected and why, where it's kept, their rights, and how to withdraw or complain.
class PrivacyNotice {
  final String policyVersion;
  final String controller;
  final String? contactEmail;
  final String dataLocation;
  final String summary;
  final List<({String data, String purpose})> items;
  final String sharing;
  final List<String> rights;
  final String withdraw;
  final String complain;
  final String notMedicalAdvice;

  /// "privacy", "terms", "health-data" -> a full URL or a path on the API.
  final Map<String, String> links;

  const PrivacyNotice({
    required this.policyVersion,
    required this.controller,
    required this.contactEmail,
    required this.dataLocation,
    required this.summary,
    required this.items,
    required this.sharing,
    required this.rights,
    required this.withdraw,
    required this.complain,
    required this.notMedicalAdvice,
    required this.links,
  });

  factory PrivacyNotice.fromJson(Map<String, dynamic> j) => PrivacyNotice(
        policyVersion: j['policy_version'] as String,
        controller: j['controller'] as String,
        contactEmail: j['contact_email'] as String?,
        dataLocation: j['data_location'] as String,
        summary: j['summary'] as String,
        items: [
          for (final i in j['items'] as List)
            (
              data: (i as Map)['data'] as String,
              purpose: i['purpose'] as String
            ),
        ],
        sharing: j['sharing'] as String,
        rights: [for (final r in j['rights'] as List) r as String],
        withdraw: j['withdraw'] as String,
        complain: j['complain'] as String,
        notMedicalAdvice: j['not_medical_advice'] as String,
        links: Map<String, String>.from(j['links'] as Map),
      );
}
