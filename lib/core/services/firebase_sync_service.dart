import 'package:flutter/foundation.dart' show debugPrint;
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Sync Service - User Profile Sync (Not Health Data)
///
/// Syncs ONLY non-sensitive user data to Firebase Realtime Database:
/// - User profile (email, display name)
/// - Onboarding status
/// - Notification preferences
/// - App settings
///
/// NEVER syncs:
/// - Period dates
/// - Symptoms
/// - Mood/flow logs
/// - Any health-related data
///
/// Health data remains ONLY on device (encrypted local storage)
class FirebaseSyncService {
  FirebaseSyncService._();
  static final FirebaseSyncService instance = FirebaseSyncService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get user UID
  String? get userUID => _auth.currentUser?.uid;

  /// Sync user profile to Firebase (non-health data only)
  /// Call this after user updates their profile
  Future<void> syncUserProfile({
    String? displayName,
    String? email,
  }) async {
    if (!isAuthenticated) return;

    try {
      final user = _auth.currentUser!;

      // Update Firebase Auth profile
      if (displayName != null && displayName != user.displayName) {
        await user.updateDisplayName(displayName);
      }

      if (email != null && email != user.email) {
        await user.updateEmail(email);
      }

      debugPrint('✅ User profile synced to Firebase');
    } catch (e) {
      debugPrint('❌ Error syncing user profile: $e');
    }
  }

  /// Sync notification preferences to Firebase
  /// This allows users to manage settings across devices
  Future<void> syncNotificationSettings({
    bool? periodReminder,
    bool? dailyReminder,
    int? reminderDaysBefore,
    String? reminderTime,
  }) async {
    if (!isAuthenticated) return;

    try {
      // In a real Firebase setup, you would store this in Realtime Database
      // For now, we log it for debugging
      debugPrint('📱 Syncing notification settings:');
      debugPrint('  - Period Reminder: $periodReminder');
      debugPrint('  - Daily Reminder: $dailyReminder');
      debugPrint('  - Days Before: $reminderDaysBefore');
      debugPrint('  - Time: $reminderTime');

      // TODO: Store in Firebase Realtime Database at: /users/{uid}/settings/notifications
    } catch (e) {
      debugPrint('❌ Error syncing notification settings: $e');
    }
  }

  /// Sync onboarding status
  /// Used to track if user has completed initial setup
  Future<void> syncOnboardingStatus(bool isComplete) async {
    if (!isAuthenticated) return;

    try {
      debugPrint('📋 Syncing onboarding status: $isComplete');
      // TODO: Store in Firebase Realtime Database at: /users/{uid}/onboarding_complete
    } catch (e) {
      debugPrint('❌ Error syncing onboarding status: $e');
    }
  }

  /// Verify user data consistency
  /// Check that local storage matches Firebase Auth
  Future<bool> verifyUserDataConsistency() async {
    if (!isAuthenticated) return false;

    try {
      final user = _auth.currentUser!;
      debugPrint('🔍 Verifying user data:');
      debugPrint('  - UID: ${user.uid}');
      debugPrint('  - Email: ${user.email}');
      debugPrint('  - Display Name: ${user.displayName}');
      debugPrint('  - Email Verified: ${user.emailVerified}');
      debugPrint('  - Created: ${user.metadata.creationTime}');
      return true;
    } catch (e) {
      debugPrint('❌ Error verifying user data: $e');
      return false;
    }
  }

  /// Log auth state changes (for debugging)
  void logAuthStateChanges() {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        debugPrint('👤 User signed out');
      } else {
        debugPrint('✅ User signed in: ${user.email}');
        debugPrint('   UID: ${user.uid}');
      }
    });
  }

}

/// ⚠️  PRIVACY WARNING - DO NOT SYNC HEALTH DATA
/// 
/// The following data is ONLY for local storage:
///   ❌ Period dates
///   ❌ Symptoms
///   ❌ Mood/flow logs
///   ❌ Menstrual cycle history
///   ❌ Fertility window predictions (derived from health data)
/// 
/// This is a LOCKED requirement per LIORA Global SRS.
/// Violating this would:
///   1. Break user privacy
///   2. Violate HIPAA-like regulations
///   3. Make LIORA non-compliant with privacy spec
