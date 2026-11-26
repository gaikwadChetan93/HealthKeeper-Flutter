import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/bottom_nav_shell.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/sign_in_screen.dart';
import '../features/documents/screens/document_detail_screen.dart';
import '../features/documents/screens/documents_screen.dart';
import '../features/documents/scanner/scanner_capture_screen.dart';
import '../features/home/screens/family_members_screen.dart';
import '../features/home/screens/add_family_member_screen.dart';
import '../features/home/screens/home_tab_screen.dart';
import '../features/home/screens/person_picker_screen.dart';
import '../features/doctors/screens/my_doctors_screen.dart';
import '../features/doctors/screens/add_doctor_screen.dart';
import '../features/health_overview/screens/health_overview_screen.dart';
import '../features/health_records/screens/generic_list_screen.dart';
import '../features/health_records/screens/generic_form_screen.dart';
import '../features/health_records/screens/generic_detail_screen.dart';
import '../features/records/screens/records_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/vitals/screens/vital_detail_screen.dart';
import '../features/vitals/screens/vital_entry_screen.dart';
import '../features/vitals/screens/vitals_screen.dart';
import '../features/privacy/screens/privacy_and_data_screen.dart';
import '../features/privacy/screens/data_export_screen.dart';
import '../features/privacy/screens/delete_account_screen.dart';
import '../features/backup/screens/backup_restore_screen.dart';
import '../features/subscription/screens/paywall_screen.dart';
import '../features/subscription/screens/manage_subscription_screen.dart';
import '../features/invite/screens/invite_friends_screen.dart';
import 'route_constants.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    routes: [
      // Auth flow
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (_, __) => const SignInScreen(),
      ),

      // Main app with bottom nav: Home / Records / Vitals / Documents.
      // Family, Doctors and Settings moved out of the shell — reachable
      // from the Settings screen and the person picker instead.
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (_, __) => const HomeTabScreen(),
          ),
          GoRoute(
            path: Routes.records,
            builder: (_, __) => const RecordsScreen(),
          ),
          GoRoute(
            path: Routes.vitals,
            builder: (_, __) => const VitalsScreen(),
          ),
          GoRoute(
            path: Routes.documents,
            builder: (_, __) => const DocumentsScreen(),
          ),
        ],
      ),

      // Person context
      GoRoute(
        path: Routes.personPicker,
        builder: (_, __) => const PersonPickerScreen(),
      ),
      GoRoute(
        path: Routes.search,
        builder: (_, __) => const SearchScreen(),
      ),

      // Family list (moved out of the bottom nav — reachable from Settings
      // and the person picker's "Manage family").
      GoRoute(
        path: Routes.family,
        builder: (_, __) => const FamilyMembersScreen(),
      ),
      GoRoute(
        path: Routes.doctors,
        builder: (_, __) => const MyDoctorsScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),

      // Family member CRUD
      GoRoute(
        path: Routes.addFamilyMember,
        builder: (_, __) => const AddFamilyMemberScreen(),
      ),
      GoRoute(
        path: '/family-member/edit/:id',
        builder: (_, state) => AddFamilyMemberScreen(
          memberId: int.tryParse(state.pathParameters['id'] ?? ''),
        ),
      ),

      // Doctor CRUD
      GoRoute(
        path: Routes.addDoctor,
        builder: (_, __) => const AddDoctorScreen(),
      ),
      GoRoute(
        path: '/doctor/edit/:id',
        builder: (_, state) => AddDoctorScreen(
          doctorId: int.tryParse(state.pathParameters['id'] ?? ''),
        ),
      ),

      // Health overview
      GoRoute(
        path: '/health-overview/:memberId',
        builder: (_, state) => HealthOverviewScreen(
          memberId: int.parse(state.pathParameters['memberId']!),
        ),
      ),

      // Generic health module routes
      GoRoute(
        path: '/health/:moduleKey/:memberId',
        builder: (_, state) => GenericListScreen(
          moduleKey: state.pathParameters['moduleKey']!,
          memberId: int.parse(state.pathParameters['memberId']!),
        ),
      ),
      GoRoute(
        path: '/health/:moduleKey/:memberId/add',
        builder: (_, state) => GenericFormScreen(
          moduleKey: state.pathParameters['moduleKey']!,
          memberId: int.parse(state.pathParameters['memberId']!),
        ),
      ),
      GoRoute(
        path: '/health/:moduleKey/:memberId/edit/:recordId',
        builder: (_, state) => GenericFormScreen(
          moduleKey: state.pathParameters['moduleKey']!,
          memberId: int.parse(state.pathParameters['memberId']!),
          recordId: int.tryParse(state.pathParameters['recordId'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/health/:moduleKey/detail/:recordId',
        builder: (_, state) => GenericDetailScreen(
          moduleKey: state.pathParameters['moduleKey']!,
          recordId: int.parse(state.pathParameters['recordId']!),
        ),
      ),

      // Vital entry — numeric-keypad fast path, bypasses the generic form
      GoRoute(
        path: '/vitals/:moduleKey/:memberId/entry',
        builder: (_, state) => VitalEntryScreen(
          moduleKey: state.pathParameters['moduleKey']!,
          memberId: int.parse(state.pathParameters['memberId']!),
        ),
      ),
      GoRoute(
        path: '/vitals/:moduleKey/:memberId/chart',
        builder: (_, state) => VitalDetailScreen(
          moduleKey: state.pathParameters['moduleKey']!,
          memberId: int.parse(state.pathParameters['memberId']!),
        ),
      ),

      // Documents & scanner
      GoRoute(
        path: '/documents/detail/:documentId',
        builder: (_, state) => DocumentDetailScreen(
          documentId: int.parse(state.pathParameters['documentId']!),
        ),
      ),
      GoRoute(
        path: '/scanner/:memberId/capture',
        builder: (_, state) => ScannerCaptureScreen(
          memberId: int.parse(state.pathParameters['memberId']!),
        ),
      ),

      // Settings sub-screens
      GoRoute(
        path: Routes.privacyAndData,
        builder: (_, __) => const PrivacyAndDataScreen(),
      ),
      GoRoute(
        path: Routes.dataExport,
        builder: (_, __) => const DataExportScreen(),
      ),
      GoRoute(
        path: Routes.deleteAccount,
        builder: (_, __) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: Routes.backupRestore,
        builder: (_, __) => const BackupRestoreScreen(),
      ),
      GoRoute(
        path: Routes.inviteFriends,
        builder: (_, __) => const InviteFriendsScreen(),
      ),
      GoRoute(
        path: Routes.paywall,
        builder: (_, __) => const PaywallScreen(),
      ),
      GoRoute(
        path: Routes.manageSubscription,
        builder: (_, __) => const ManageSubscriptionScreen(),
      ),
    ],
  );
});
