import 'package:flutter_test/flutter_test.dart';
import 'package:health_keeper/app/route_constants.dart';
import 'package:health_keeper/app/router.dart';
import 'package:health_keeper/core/auth/auth_controller.dart';
import 'package:health_keeper/core/models/record_item.dart';

Me _me({bool consent = true, String? selfId = 'm1'}) => Me(
      id: 'a1',
      email: 'a@example.com',
      name: 'A',
      planId: 'free',
      planFeatures: const {},
      selfMemberId: selfId,
      healthDataConsent: consent,
    );

void main() {
  test('while starting up, everyone waits on the splash screen', () {
    const s = AuthState(AuthStatus.starting);
    expect(authRedirect(s, Routes.home), Routes.splash);
    expect(authRedirect(s, Routes.splash), isNull);
  });

  test('signed-out people only see welcome and sign-in (no guest mode)', () {
    const s = AuthState(AuthStatus.signedOut);
    expect(authRedirect(s, Routes.home), Routes.welcome);
    expect(authRedirect(s, '/health/weight/m1'), Routes.welcome);
    expect(authRedirect(s, Routes.signIn), isNull);
  });

  test('consent comes first, then the profile, then the app', () {
    expect(authRedirect(AuthState(AuthStatus.signedIn, me: _me(consent: false)), Routes.home), Routes.consent);
    expect(authRedirect(AuthState(AuthStatus.signedIn, me: _me(selfId: null)), Routes.home), Routes.createProfile);
    final ready = AuthState(AuthStatus.signedIn, me: _me());
    expect(authRedirect(ready, Routes.signIn), Routes.home);
    expect(authRedirect(ready, '/health/weight/m1'), isNull);
  });
}
