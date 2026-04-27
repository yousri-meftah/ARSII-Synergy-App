import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/models/user.dart';
import 'package:arsii_mvp/services/auth_service.dart';
import 'package:arsii_mvp/core/biometric_auth.dart';
import 'package:arsii_mvp/core/secure_storage.dart';

const _unset = Object();

class AuthState {
  final bool isLoading;
  final String? token;
  final User? user;
  final String? error;
  final bool biometricAvailable;
  final bool biometricEnabled;

  const AuthState({
    required this.isLoading,
    required this.token,
    required this.user,
    required this.error,
    required this.biometricAvailable,
    required this.biometricEnabled,
  });

  bool get isAuthenticated => token != null && user != null;
  bool get canUseBiometrics => biometricAvailable && biometricEnabled && token != null && !isAuthenticated;

  AuthState copyWith({
    bool? isLoading,
    Object? token = _unset,
    Object? user = _unset,
    Object? error = _unset,
    bool? biometricAvailable,
    bool? biometricEnabled,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      token: identical(token, _unset) ? this.token : token as String?,
      user: identical(user, _unset) ? this.user : user as User?,
      error: identical(error, _unset) ? this.error : error as String?,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }

  factory AuthState.initial() => const AuthState(
        isLoading: true,
        token: null,
        user: null,
        error: null,
        biometricAvailable: false,
        biometricEnabled: false,
      );
}

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  final SecureStore _secureStore;
  final BiometricAuthService _biometricAuthService;

  AuthController(this._authService, this._secureStore, this._biometricAuthService)
      : super(AuthState.initial()) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final biometricAvailable = await _biometricAuthService.isAvailable();
    final biometricEnabled = await _secureStore.readBiometricEnabled();
    final token = await _secureStore.readToken();
    if (token == null) {
      state = state.copyWith(
        isLoading: false,
        token: null,
        user: null,
        biometricAvailable: biometricAvailable,
        biometricEnabled: biometricEnabled,
      );
      return;
    }

    if (biometricEnabled && biometricAvailable) {
      state = state.copyWith(
        isLoading: false,
        token: token,
        user: null,
        error: null,
        biometricAvailable: biometricAvailable,
        biometricEnabled: biometricEnabled,
      );
      return;
    }

    try {
      final user = await _authService.me(token);
      state = state.copyWith(
        isLoading: false,
        token: token,
        user: user,
        error: null,
        biometricAvailable: biometricAvailable,
        biometricEnabled: biometricEnabled,
      );
    } catch (e) {
      await _secureStore.clear();
      state = state.copyWith(
        isLoading: false,
        token: null,
        user: null,
        error: 'Session expired',
        biometricAvailable: biometricAvailable,
        biometricEnabled: false,
      );
    }
  }

  Future<void> login(String email, String password, {bool enableBiometrics = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final (token, user) = await _authService.login(email, password);
      await _secureStore.saveToken(token);
      final biometricEnabled = enableBiometrics && state.biometricAvailable;
      await _secureStore.saveBiometricEnabled(biometricEnabled);
      state = state.copyWith(
        isLoading: false,
        token: token,
        user: user,
        error: null,
        biometricEnabled: biometricEnabled,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Invalid credentials');
    }
  }

  Future<void> unlockWithBiometrics() async {
    if (state.token == null) {
      state = state.copyWith(error: 'No saved session found');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    final authenticated = await _biometricAuthService.authenticate();
    if (!authenticated) {
      state = state.copyWith(isLoading: false, error: 'Biometric authentication failed');
      return;
    }

    try {
      final user = await _authService.me(state.token!);
      state = state.copyWith(isLoading: false, user: user, error: null);
    } catch (e) {
      await _secureStore.clear();
      state = state.copyWith(
        isLoading: false,
        token: null,
        user: null,
        biometricEnabled: false,
        error: 'Session expired',
      );
    }
  }

  Future<void> logout() async {
    await _secureStore.clear();
    state = state.copyWith(
      token: null,
      user: null,
      error: null,
      isLoading: false,
      biometricEnabled: false,
    );
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(AuthService(), SecureStore(), BiometricAuthService());
});
