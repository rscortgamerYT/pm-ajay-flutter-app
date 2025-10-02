import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user_model.dart';
import '../models/permission_model.dart';
import 'secure_storage_service.dart';

/// Comprehensive authentication service with Firebase Auth and biometric support
class AuthService {
  final FirebaseAuth _firebaseAuth;
  final LocalAuthentication _localAuth;
  final SecureStorageService _secureStorage;
  
  // Cache current user
  AppUser? _currentUser;
  
  AuthService({
    FirebaseAuth? firebaseAuth,
    LocalAuthentication? localAuth,
    required SecureStorageService secureStorage,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage;

  /// Gets current authenticated user
  AppUser? get currentUser => _currentUser;
  
  /// Stream of authentication state changes
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        return null;
      }
      
      // Fetch user details from Firestore/API
      final user = await _fetchUserDetails(firebaseUser.uid);
      _currentUser = user;
      return user;
    });
  }

  /// Sign in with email and password
  Future<AppUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('Sign in failed: No user returned');
      }
      
      final user = await _fetchUserDetails(credential.user!.uid);
      _currentUser = user;
      
      // Store credentials securely for biometric re-auth
      await _secureStorage.saveCredentials(email, password);
      
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign up with email and password
  Future<AppUser> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw Exception('Sign up failed: No user returned');
      }
      
      // Update display name
      await credential.user!.updateDisplayName(name);
      
      // Create user profile in database
      final user = AppUser(
        id: credential.user!.uid,
        email: email,
        name: name,
        role: role,
        phone: phone,
        permissions: _getDefaultPermissions(role),
        createdAt: DateTime.now(),
        isActive: true,
      );
      
      await _createUserProfile(user);
      _currentUser = user;
      
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        throw Exception('Biometric authentication not available');
      }
      
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access PM-AJAY',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      if (authenticated) {
        // Re-authenticate with stored credentials
        final credentials = await _secureStorage.getCredentials();
        if (credentials != null) {
          await signInWithEmailPassword(
            email: credentials['email']!,
            password: credentials['password']!,
          );
          return true;
        }
      }
      
      return false;
    } catch (e) {
      throw Exception('Biometric authentication failed: $e');
    }
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
    await _secureStorage.deleteCredentials();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user logged in');
      
      await user.updatePassword(newPassword);
      
      // Update stored credentials
      if (_currentUser != null) {
        final credentials = await _secureStorage.getCredentials();
        if (credentials != null) {
          await _secureStorage.saveCredentials(
            credentials['email']!,
            newPassword,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Re-authenticate user (required for sensitive operations)
  Future<void> reauthenticate(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }
      
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Check if user has specific permission
  bool hasPermission(Permission permission) {
    if (_currentUser == null) return false;
    return _currentUser!.permissions.contains(permission);
  }

  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<Permission> permissions) {
    if (_currentUser == null) return false;
    return permissions.any((p) => _currentUser!.permissions.contains(p));
  }

  /// Check if user has all of the specified permissions
  bool hasAllPermissions(List<Permission> permissions) {
    if (_currentUser == null) return false;
    return permissions.every((p) => _currentUser!.permissions.contains(p));
  }

  /// Refresh user session
  Future<void> refreshSession() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
      _currentUser = await _fetchUserDetails(user.uid);
    }
  }

  // ===== Private Helper Methods =====

  Future<AppUser> _fetchUserDetails(String uid) async {
    // TODO: Fetch from Firestore or API
    // For now, return a dummy user
    return AppUser(
      id: uid,
      email: _firebaseAuth.currentUser?.email ?? '',
      name: _firebaseAuth.currentUser?.displayName ?? 'User',
      role: UserRole.officer,
      permissions: _getDefaultPermissions(UserRole.officer),
      createdAt: DateTime.now(),
      isActive: true,
    );
  }

  Future<void> _createUserProfile(AppUser user) async {
    // TODO: Create user profile in Firestore or API
  }

  List<Permission> _getDefaultPermissions(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return Permission.values; // All permissions
      case UserRole.admin:
        return [
          Permission.viewProjects,
          Permission.editProjects,
          Permission.viewFunds,
          Permission.approveFunds,
          Permission.viewAgencies,
          Permission.editAgencies,
          Permission.viewReports,
          Permission.generateReports,
          Permission.viewAIInsights,
        ];
      case UserRole.officer:
        return [
          Permission.viewProjects,
          Permission.editProjects,
          Permission.viewFunds,
          Permission.viewAgencies,
          Permission.viewReports,
          Permission.viewAIInsights,
        ];
      case UserRole.citizen:
        return [
          Permission.viewProjects,
          Permission.submitReports,
          Permission.viewOwnReports,
        ];
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}