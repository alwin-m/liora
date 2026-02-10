import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/firebase_sync_service.dart';

/// AuthProvider - Firebase Authentication State Management
///
/// Handles user authentication with gentle UX:
/// - Soft validation (no harsh red errors)
/// - Inline feedback
/// - Emotional safety
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = false;
  String? _error;
  AuthStatus _status = AuthStatus.initial;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  AuthStatus get status => _status;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      _status =
          user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _clearError();

    // Validate inputs first
    final validationError = validateSignInInputs(email, password);
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setLoading(true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getGentleErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}. Please check your connection and try again.');
      _setLoading(false);
      return false;
    }
  }

  /// Create new account with validation
  Future<bool> signUp({
    required String email,
    required String password,
    required String passwordConfirm,
    String? displayName,
  }) async {
    _clearError();

    // Validate inputs first (before making API call)
    final validationError = validateSignUpInputs(email, password, passwordConfirm);
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    _setLoading(true);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      // Sync user profile to Firebase
      await FirebaseSyncService.instance.syncUserProfile(
        displayName: displayName,
        email: email,
      );

      // Verify user data
      await FirebaseSyncService.instance.verifyUserDataConsistency();

      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getGentleErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}. Please try again or contact support.');
      _setLoading(false);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _auth.signOut();
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _setError('Unable to sign out. Please try again.');
    }

    _setLoading(false);
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getGentleErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Unable to send reset email. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    if (_user == null) return false;

    _setLoading(true);

    try {
      await _user!.delete();
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getGentleErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Unable to delete account. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  /// Validate email format
  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required.';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain lowercase letters.';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain uppercase letters.';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain numbers.';
    }
    return null; // Valid
  }

  /// Validate email
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required.';
    }
    if (!isEmailValid(email)) {
      return 'Please enter a valid email address (e.g., user@example.com).';
    }
    return null; // Valid
  }

  /// Pre-validate before sign up
  String? validateSignUpInputs(String email, String password, String passwordConfirm) {
    // Check email
    final emailError = validateEmail(email);
    if (emailError != null) return emailError;

    // Check password
    final passwordError = validatePassword(password);
    if (passwordError != null) return passwordError;

    // Check password match
    if (password != passwordConfirm) {
      return 'Passwords do not match.';
    }

    return null; // All valid
  }

  /// Pre-validate before sign in
  String? validateSignInInputs(String email, String password) {
    final emailError = validateEmail(email);
    if (emailError != null) return emailError;

    if (password.isEmpty) {
      return 'Password is required.';
    }

    return null; // Valid
  }


  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Convert Firebase error codes to detailed, helpful messages
  String _getGentleErrorMessage(String code) {
    switch (code) {
      // Email-related errors
      case 'user-not-found':
        return "No account found with this email. Please check the email or create a new account.";
      case 'invalid-email':
        return "Email format is invalid. Make sure it looks like: example@email.com";
      case 'email-already-in-use':
        return "This email is already registered. Please sign in or use a different email.";
      
      // Password-related errors
      case 'wrong-password':
        return "Password is incorrect. Please try again or reset your password.";
      case 'weak-password':
        return "Password is too weak. Use at least 6 characters including letters and numbers.";
      
      // Account-related errors
      case 'user-disabled':
        return "This account has been disabled. Contact support for assistance.";
      case 'operation-not-allowed':
        return "This authentication method is not enabled. Please try another way.";
      case 'too-many-requests':
        return "Too many failed login attempts. Please wait a few minutes before trying again.";
      
      // Network-related errors
      case 'network-request-failed':
        return "No internet connection. Please check your network and try again.";
      case 'unknown':
        return "Network error. Please check your connection and try again.";
      
      // Security-related errors
      case 'requires-recent-login':
        return "For security, please sign in again to complete this action.";
      case 'account-exists-with-different-credential':
        return "An account already exists with this email using a different sign-in method.";
      
      default:
        return "Unexpected error: $code. Please try again or contact support.";
    }
  }
}

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}
