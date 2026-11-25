import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../core/widgets/bottom_nav_shell.dart';
import '../features/auth/screens/consent_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/sign_in_screen.dart';
import '../features/home/screens/family_members_screen.dart';
import '../features/home/screens/add_family_member_screen.dart';
import '../features/doctors/screens/my_doctors_screen.dart';
import '../features/doctors/screens/add_doctor_screen.dart';
import '../features/health_overview/screens/health_overview_screen.dart';
import '../features/health_records/screens/generic_list_screen.dart';
import '../features/health_records/screens/generic_form_screen.dart';
import '../features/health_records/screens/generic_detail_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/vitals/screens/vital_trend_screen.dart';
import '../features/privacy/screens/privacy_and_data_screen.dart';
import '../features/privacy/screens/data_export_screen.dart';
import '../features/privacy/screens/delete_account_screen.dart';
import '../features/subscription/screens/paywall_screen.dart';
import '../features/subscription/screens/manage_subscription_screen.dart';
import '../features/invite/screens/invite_friends_screen.dart';
import 'route_constants.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

const _signedOutRoutes = {Routes.welcome, Routes.signIn};
const _setupRoutes = {
  Routes.splash,
  Routes.welcome,
  Routes.signIn,
  Routes.consent,
  Routes.createProfile
};

/// Where someone must be, given their sign-in state. Null means "stay".
String? authRedirect(AuthState auth, String location) {
  switch (auth.status) {
    case AuthStatus.starting:
      return location == Routes.splash ? null : Routes.splash;
    case AuthStatus.signedOut:
      return _signedOutRoutes.contains(location) ? null : Routes.welcome;
    case AuthStatus.signedIn:
      if (auth.needsConsent)
        return location == Routes.consent ? null : Routes.consent;
      if (auth.needsProfile)
        return location == Routes.createProfile ? null : Routes.createProfile;
      return _setupRoutes.contains(location) ? Routes.home : null;
  }
}

/// Re-runs the redirect whenever the sign-in state changes.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: _AuthListenable(ref),
    redirect: (_, state) =>
        authRedirect(ref.read(authProvider), state.matchedLocation),
    routes: [
      // Sign-in and first-time setup
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: Routes.welcome, builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: Routes.signIn, builder: (_, __) => const SignInScreen()),
      GoRoute(path: Routes.consent, builder: (_, __) => const ConsentScreen()),
      GoRoute(
        path: Routes.createProfile,
        builder: (_, __) => const AddFamilyMemberScreen(creatingSelf: true),
      ),

      // Main app with bottom nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(
              path: Routes.home,
              builder: (_, __) => const FamilyMembersScreen()),
          GoRoute(
              path: Routes.doctors,
              builder: (_, __) => const MyDoctorsScreen()),
          GoRoute(
              path: Routes.settings,
              builder: (_, __) => const SettingsScreen()),
        ],
      ),

      // Family member CRUD
      GoRoute(
          path: Routes.addFamilyMember,
          builder: (_, __) => const AddFamilyMemberScreen()),
      GoRoute(
        path: '/family-member/edit/:id',
        builder: (_, state) =>
            AddFamilyMemberScreen(memberId: state.pathParameters['id']),
      ),

      // Doctor CRUD (still sample data; doctors come in a later release)
      GoRoute(
          path: Routes.addDoctor, builder: (_, __) => const AddDoctorScreen()),
      GoRoute(
        path: '/doctor/edit/:id',
        builder: (_, state) => AddDoctorScreen(
            doctorId: int.tryParse(state.pathParameters['id'] ?? '')),
      ),

      // Health overview
      GoRoute(
        path: '/health-overview/:memberId',
        builder: (_, state) =>
            HealthOverviewScreen(memberId: state.pathParameters['memberId']!),
      ),

      // Vital trends
      GoRoute(
        path: '/vitals/:vitalKey/:memberId/chart',
        builder: (_, state) => VitalTrendScreen(
          moduleKey: state.pathParameters['vitalKey']!,
          memberId: state.pathParameters['memberId']!,
        ),
      ),

      // Generic health module routes
      GoRoute(
        path: '/health/:moduleKey/detail/:recordId',
        builder: (_, state) => GenericDetailScreen(
          moduleKey: state.pathParameters['moduleKey']!,
          recordId: state.pathParameters['recordId']!,
        ),
      ),
      GoRoute(
        path: '/health/:moduleKey/:memberId',
        builder: (_, state) => GenericListScreen(
          moduleKey: state.pathParameters['moduleKey']!,
          memberId: state.pathParameters['memberId']!,
        ),
      ),
      GoRoute(
        path: '/health/:moduleKey/:memberId/add',
        builder: (_, state) => GenericFormScreen(
          moduleKey: state.pathParameters['moduleKey']!,
          memberId: state.pathParameters['memberId']!,
        ),
      ),
      GoRoute(
        path: '/health/:moduleKey/:memberId/edit/:recordId',
        builder: (_, state) => GenericFormScreen(
          moduleKey: state.pathParameters['moduleKey']!,
          memberId: state.pathParameters['memberId']!,
          recordId: state.pathParameters['recordId'],
        ),
      ),

      // Settings sub-screens
      GoRoute(
          path: Routes.privacyAndData,
          builder: (_, __) => const PrivacyAndDataScreen()),
      GoRoute(
          path: Routes.dataExport,
          builder: (_, __) => const DataExportScreen()),
      GoRoute(
          path: Routes.deleteAccount,
          builder: (_, __) => const DeleteAccountScreen()),
      GoRoute(
          path: Routes.inviteFriends,
          builder: (_, __) => const InviteFriendsScreen()),
      GoRoute(path: Routes.paywall, builder: (_, __) => const PaywallScreen()),
      GoRoute(
          path: Routes.manageSubscription,
          builder: (_, __) => const ManageSubscriptionScreen()),
    ],
  );
});
