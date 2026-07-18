import 'package:flutter_riverpod/flutter_riverpod.dart';

class DemoUser {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;

  DemoUser({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
  });
}

class AuthState {
  final DemoUser? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({DemoUser? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Demo mode — simulated Google sign-in
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(
        user: DemoUser(
          uid: 'demo_user_123',
          displayName: 'Демо Пользователь',
          email: 'demo@eurentrent.com',
        ),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<DemoUser?>((ref) {
  return ref.watch(authProvider).user;
});
