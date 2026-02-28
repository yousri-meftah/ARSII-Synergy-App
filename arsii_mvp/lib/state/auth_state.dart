import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/models/user.dart';
import 'package:arsii_mvp/services/auth_service.dart';
import 'package:arsii_mvp/core/secure_storage.dart';

class AuthState {
  final bool isLoading;
  final String? token;
  final User? user;
  final String? error;

  const AuthState({
    required this.isLoading,
    required this.token,
    required this.user,
    required this.error,
  });

  bool get isAuthenticated => token != null && user != null;

  AuthState copyWith({
    bool? isLoading,
    String? token,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      user: user ?? this.user,
      error: error,
    );
  }

  factory AuthState.initial() => const AuthState(
        isLoading: true,
        token: null,
        user: null,
        error: null,
      );
}

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  final SecureStore _secureStore;

  AuthController(this._authService, this._secureStore) : super(AuthState.initial()) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final token = await _secureStore.readToken();
    if (token == null) {
      state = state.copyWith(isLoading: false, token: null, user: null);
      return;
    }
    try {
      final user = await _authService.me(token);
      state = state.copyWith(isLoading: false, token: token, user: user, error: null);
    } catch (e) {
      await _secureStore.clear();
      state = state.copyWith(isLoading: false, token: null, user: null, error: 'Session expired');
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final (token, user) = await _authService.login(email, password);
      await _secureStore.saveToken(token);
      state = state.copyWith(isLoading: false, token: token, user: user, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Invalid credentials');
    }
  }

  Future<void> logout() async {
    await _secureStore.clear();
    state = state.copyWith(token: null, user: null, isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(AuthService(), SecureStore());
});
