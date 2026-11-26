class Routes {
  Routes._();

  static const splash = '/splash';
  static const welcome = '/welcome';
  static const signIn = '/sign-in';
  static const consent = '/consent';
  static const createProfile = '/create-profile';
  static const home = '/';
  static const doctors = '/doctors';
  static const settings = '/settings';

  // Family member
  static const addFamilyMember = '/family-member/add';
  static String editFamilyMember(String id) => '/family-member/edit/$id';

  // Doctor
  static const addDoctor = '/doctor/add';
  static String editDoctor(String id) => '/doctor/edit/$id';
  static String doctorDetail(String id) => '/doctor/view/$id';

  // Health overview
  static String healthOverview(String memberId) => '/health-overview/$memberId';

  // Generic health module routes
  static String healthList(String moduleKey, String memberId) =>
      '/health/$moduleKey/$memberId';
  static String healthAdd(String moduleKey, String memberId) =>
      '/health/$moduleKey/$memberId/add';
  static String healthEdit(
          String moduleKey, String memberId, String recordId) =>
      '/health/$moduleKey/$memberId/edit/$recordId';
  static String healthDetail(String moduleKey, String recordId) =>
      '/health/$moduleKey/detail/$recordId';

  // Lab results
  static String labs(String memberId) => '/labs/$memberId';
  static String labAdd(String memberId) => '/labs/$memberId/add';
  static String labTest(String memberId, String testId) =>
      '/labs/$memberId/test/$testId';
  static String labReport(String reportId) => '/lab-report/$reportId';
  static String labUpload(String uploadId) => '/lab-upload/$uploadId';
  static String labUploadReview(String uploadId) =>
      '/lab-upload/$uploadId/review';

  // Vital charts
  static String vitalChart(String vitalKey, String memberId) =>
      '/vitals/$vitalKey/$memberId/chart';

  // Settings sub-screens
  static const privacyAndData = '/privacy';
  static const dataExport = '/export';
  static const deleteAccount = '/delete-account';
  static const inviteFriends = '/invite';
  static const paywall = '/paywall';
  static const manageSubscription = '/subscription';
}
