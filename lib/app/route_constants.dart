class Routes {
  Routes._();

  static const splash = '/splash';
  static const welcome = '/welcome';
  static const signIn = '/sign-in';

  // Bottom nav tabs
  static const home = '/';
  static const records = '/records';
  static const vitals = '/vitals';
  static const documents = '/documents';

  // Moved out of the bottom nav in the redesign — reachable from Settings
  // and the person picker instead.
  static const family = '/family';
  static const doctors = '/doctors';
  static const settings = '/settings';

  // Person context
  static const personPicker = '/person-picker';
  static const search = '/search';

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

  // Vital entry — numeric-keypad fast path, bypasses the generic form
  static String vitalEntry(String moduleKey, int memberId) =>
      '/vitals/$moduleKey/$memberId/entry';

  // Documents & scanner
  static String documentDetail(int documentId) => '/documents/detail/$documentId';
  static String scannerCapture(int memberId) => '/scanner/$memberId/capture';

  // Settings sub-screens
  static const privacyAndData = '/privacy';
  static const dataExport = '/export';
  static const deleteAccount = '/delete-account';
  static const backupRestore = '/backup';
  static const inviteFriends = '/invite';
  static const paywall = '/paywall';
  static const manageSubscription = '/subscription';
}
