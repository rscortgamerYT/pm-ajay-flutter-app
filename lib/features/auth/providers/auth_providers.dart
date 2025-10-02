import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/permission_model.dart';

// ===== Service Providers =====

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    secureStorage: ref.watch(secureStorageServiceProvider),
  );
});

// ===== Auth State Provider =====

final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// ===== Current User Provider =====

final currentUserProvider = Provider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

// ===== Authentication Action Providers =====

final signInProvider = FutureProvider.family<AppUser, SignInParams>((ref, params) async {
  final authService = ref.watch(authServiceProvider);
  return authService.signInWithEmailPassword(
    email: params.email,
    password: params.password,
  );
});

final signUpProvider = FutureProvider.family<AppUser, SignUpParams>((ref, params) async {
  final authService = ref.watch(authServiceProvider);
  return authService.signUpWithEmailPassword(
    email: params.email,
    password: params.password,
    name: params.name,
    role: params.role,
    phone: params.phone,
  );
});

// ===== Permission Providers =====

final hasPermissionProvider = Provider.family<bool, Permission>((ref, permission) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return user.permissions.contains(permission);
});

final hasAnyPermissionProvider = Provider.family<bool, List<Permission>>((ref, permissions) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return permissions.any((p) => user.permissions.contains(p));
});

final hasAllPermissionsProvider = Provider.family<bool, List<Permission>>((ref, permissions) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return permissions.every((p) => user.permissions.contains(p));
});

// ===== Biometric Auth Provider =====

final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.isBiometricAvailable();
});

final availableBiometricsProvider = FutureProvider<List<String>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final biometrics = await authService.getAvailableBiometrics();
  return biometrics.map((b) => b.name).toList();
});

// ===== Auth Notifier =====

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(const AuthState.initial());

  Future<void> signIn(String email, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    state = const AuthState.loading();
    try {
      final user = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        name: name,
        role: role,
        phone: phone,
      );
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithBiometrics() async {
    state = const AuthState.loading();
    try {
      final success = await _authService.authenticateWithBiometrics();
      if (success) {
        final user = _authService.currentUser;
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.error('Biometric authentication failed');
        }
      } else {
        state = const AuthState.error('Biometric authentication was cancelled');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      state = const AuthState.passwordResetSent();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> updatePassword(String newPassword) async {
    state = const AuthState.loading();
    try {
      await _authService.updatePassword(newPassword);
      final user = _authService.currentUser;
      if (user != null) {
        state = AuthState.authenticated(user);
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> reauthenticate(String password) async {
    try {
      await _authService.reauthenticate(password);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void clearError() {
    if (state is AuthStateError) {
      state = const AuthState.unauthenticated();
    }
  }
}

// ===== Auth State Classes =====

sealed class AuthState {
  const AuthState();
  
  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authenticated(AppUser user) = AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.error(String message) = AuthStateError;
  const factory AuthState.passwordResetSent() = AuthStatePasswordResetSent;
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final AppUser user;
  const AuthStateAuthenticated(this.user);
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateError extends AuthState {
  final String message;
  const AuthStateError(this.message);
}

class AuthStatePasswordResetSent extends AuthState {
  const AuthStatePasswordResetSent();
}

// ===== Parameter Classes =====

class SignInParams {
  final String email;
  final String password;
  
  const SignInParams({
    required this.email,
    required this.password,
  });
}

class SignUpParams {
  final String email;
  final String password;
  final String name;
  final UserRole role;
  final String? phone;
  
  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    this.phone,
  });
}