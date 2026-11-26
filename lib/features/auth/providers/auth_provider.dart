import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final String? userName;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userName,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userName,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    // Simulate sign-in delay
    await Future.delayed(const Duration(seconds: 1));

    state = state.copyWith(
      status: AuthStatus.authenticated,
      userName: 'Rahul Sharma',
    );
  }

  Future<void> continueAsGuest() async {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      userName: 'Guest',
    );
  }

  void signOut() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(milliseconds: 500));
    // Default: not authenticated, show welcome
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});
