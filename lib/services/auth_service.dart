import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// AUTHENTICATION SERVICE
///
/// DATA CLASSIFICATION: Backend-Stored Authentication & Authorization Data Only
///
/// ALLOWED DATA (Backend Database):
/// ✓ Email address
/// ✓ User ID / UID
/// ✓ Password hash (handled by Firebase Authentication)
/// ✓ Authentication tokens
/// ✓ Session identifiers
/// ✓ Account creation timestamp
/// ✓ Account status flags
/// ✓ User role (admin/user)
///
/// FORBIDDEN DATA (NEVER store in backend):
/// ✗ Menstrual cycle information
/// ✗ Period dates or predictions
/// ✗ Period duration
/// ✗ Cycle length calculations
/// ✗ Flow intensity level
/// ✗ PMS symptoms or health data
/// ✗ Any health-related information
///
/// USER DOCUMENT STRUCTURE (Backend):
/// users/{uid}
///   - email: string
///   - name: string
///   - role: string (admin/user)
///   - createdAt: timestamp
///   - profileCompleted: boolean
///   - [NO medical fields]
///
/// CRITICAL: Do NOT add medical fields to user document!
class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  /// Register new user with email and password.
  /// BACKEND ONLY: Stores identity data.
  /// CRITICAL: Medical data initialization happens LOCALLY ONLY in CycleProvider.
  Future<UserCredential?> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create Firebase Auth account (handled securely by Firebase)
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Store ONLY authentication metadata in backend
      // DO NOT add medical fields (lastPeriodDate, cycleLength, etc.)
      await _db.collection('users').doc(userCred.user!.uid).set({
        'email': email.trim(),
        'name': name.trim(),
        'createdAt': Timestamp.now(),
        'role': 'user',
        'profileCompleted': false,
        // PRIVACY: Medical data fields are NOT stored here
        // Medical data is stored ONLY on user's device via LocalMedicalDataService
      });

      debugPrint('[AUTH] User registered: ${userCred.user?.email}');
      return userCred;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AUTH] Registration error: ${e.message}');
      rethrow;
    }
  }

  /// Login user with email and password.
  /// BACKEND: Verifies credentials stored in Firebase Authentication.
  /// CRITICAL: Does NOT transmit or verify any medical data.
  Future<UserCredential?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      debugPrint('[AUTH] User logged in: ${userCred.user?.email}');
      return userCred;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AUTH] Login error: ${e.message}');
      rethrow;
    }
  }

  /// Update user document in backend.
  /// BACKEND ONLY: Update non-medical fields only.
  /// WARNING: Do NOT pass medical fields to this method!
  Future<void> updateUserProfile({
    required String uid,
    Map<String, dynamic>? updates,
  }) async {
    if (updates == null || updates.isEmpty) return;

    // PRIVACY GUARD: Prevent medical fields from being stored in backend
    final medicalFields = [
      'lastPeriodDate',
      'cycleLength',
      'periodLength',
      'lastPeriodStartDate',
      'averageCycleLength',
      'averagePeriodDuration',
      'flowLevel',
      'cycleRegularity',
      'pmsLevel',
    ];

    for (final field in medicalFields) {
      if (updates.containsKey(field)) {
        throw Exception(
          '[PRIVACY VIOLATION] Attempted to store medical field "$field" in backend: $field. '
          'Medical data must be stored ONLY locally via LocalMedicalDataService.',
        );
      }
    }

    try {
      await _db.collection('users').doc(uid).update(updates);
      debugPrint('[AUTH] User profile updated: $updates');
    } catch (e) {
      debugPrint('[AUTH] Error updating profile: $e');
      rethrow;
    }
  }

  /// Mark profile setup as complete.
  /// Only sets flag, does NOT accept medical data.
  Future<void> markProfileComplete(String uid) async {
    try {
      await _db.collection('users').doc(uid).update({'profileCompleted': true});
      debugPrint('[AUTH] Profile marked complete for user: $uid');
    } catch (e) {
      debugPrint('[AUTH] Error marking profile complete: $e');
      rethrow;
    }
  }

  /// Change user password (authentication only).
  /// Does NOT involve any medical data.
  Future<void> changePasswordSecurely(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      await user.updatePassword(newPassword);
      debugPrint('[AUTH] Password changed successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('[AUTH] Password change error: ${e.message}');
      rethrow;
    }
  }

  /// Delete user account.
  /// BACKEND: Removes authentication and user record.
  /// LOCAL: Medical data is handled separately via LocalMedicalDataService.clearAllPrivateDataOnLogout()
  Future<void> deleteAccount(String uid) async {
    try {
      final user = _auth.currentUser;

      // Delete user document from backend
      await _db.collection('users').doc(uid).delete();

      // Delete Firebase Auth account
      if (user != null) {
        await user.delete();
      }

      debugPrint('[AUTH] Account deleted: $uid');
    } on FirebaseAuthException catch (e) {
      debugPrint('[AUTH] Account deletion error: ${e.message}');
      rethrow;
    }
  }

  /// Logout user.
  /// Clears authentication session from backend.
  /// LOCAL: Medical data deletion is handled separately.
  Future<void> logout() async {
    try {
      await _auth.signOut();
      debugPrint('[AUTH] User logged out');
    } catch (e) {
      debugPrint('[AUTH] Logout error: $e');
      rethrow;
    }
  }

  /// Get current authenticated user.
  /// Returns ONLY authentication metadata, NOT medical data.
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if user is authenticated.
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Get user record from backend.
  /// Returns ONLY authentication metadata, NOT medical data.
  Future<DocumentSnapshot?> getUserRecord(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists ? doc : null;
    } catch (e) {
      debugPrint('[AUTH] Error fetching user record: $e');
      return null;
    }
  }
}
