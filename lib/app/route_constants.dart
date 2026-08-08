class Routes {
  Routes._();

  static const splash = '/splash';
  static const welcome = '/welcome';
  static const signIn = '/sign-in';
  static const home = '/';
  static const doctors = '/doctors';
  static const settings = '/settings';

  // Family member
  static const addFamilyMember = '/family-member/add';
  static String editFamilyMember(int id) => '/family-member/edit/$id';

  // Doctor
  static const addDoctor = '/doctor/add';
  static String editDoctor(int id) => '/doctor/edit/$id';

  // Health overview
  static String healthOverview(int memberId) => '/health-overview/$memberId';

  // Generic health module routes
  static String healthList(String moduleKey, int memberId) =>
      '/health/$moduleKey/$memberId';
  static String healthAdd(String moduleKey, int memberId) =>
      '/health/$moduleKey/$memberId/add';
  static String healthEdit(String moduleKey, int memberId, int recordId) =>
      '/health/$moduleKey/$memberId/edit/$recordId';
  static String healthDetail(String moduleKey, int recordId) =>
      '/health/$moduleKey/detail/$recordId';

  // Vital charts
  static String vitalChart(String vitalKey, int memberId) =>
      '/vitals/$vitalKey/$memberId/chart';

  // Settings sub-screens
  static const privacyAndData = '/privacy';
  static const dataExport = '/export';
  static const deleteAccount = '/delete-account';
  static const backupRestore = '/backup';
  static const inviteFriends = '/invite';
  static const paywall = '/paywall';
  static const manageSubscription = '/subscription';
}
