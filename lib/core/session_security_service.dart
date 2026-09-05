import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// SessionSecurityService manages session-level security features
///
/// Responsibilities:
/// - Track failed authentication attempts
/// - Enforce lockout after max attempts
/// - Manage temporary app states during session
class SessionSecurityService {
  static const String _failedAttemptsKey = "failed_lock_attempts";
  static const String _lockoutTimeKey = "lockout_time";
  static const int maxAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Increments failed authentication attempts for current user
  static Future<int> recordFailedAttempt() async {
    if (_uid == null) return 0;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = "${_uid}_$_failedAttemptsKey";

      final current = prefs.getInt(key) ?? 0;
      final updated = current + 1;

      await prefs.setInt(key, updated);

      // If max attempts reached, record lockout time
      if (updated >= maxAttempts) {
        final lockoutKey = "${_uid}_$_lockoutTimeKey";
        await prefs.setInt(lockoutKey, DateTime.now().millisecondsSinceEpoch);
      }

      return updated;
    } catch (e) {
      debugPrint("Error recording failed attempt: $e");
      return 0;
    }
  }

  /// Clears failed attempts after successful authentication
  static Future<void> clearFailedAttempts() async {
    if (_uid == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = "${_uid}_$_failedAttemptsKey";
      final lockoutKey = "${_uid}_$_lockoutTimeKey";

      await prefs.remove(key);
      await prefs.remove(lockoutKey);
    } catch (e) {
      debugPrint("Error clearing failed attempts: $e");
    }
  }

  /// Gets current number of failed attempts
  static Future<int> getFailedAttempts() async {
    if (_uid == null) return 0;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = "${_uid}_$_failedAttemptsKey";
      return prefs.getInt(key) ?? 0;
    } catch (e) {
      debugPrint("Error getting failed attempts: $e");
      return 0;
    }
  }

  /// Checks if user is currently in lockout period
  static Future<bool> isLockedOut() async {
    if (_uid == null) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lockoutKey = "${_uid}_$_lockoutTimeKey";

      final lockoutTimeMs = prefs.getInt(lockoutKey);
      if (lockoutTimeMs == null) return false;

      final lockoutTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimeMs);
      final now = DateTime.now();

      final isStillLocked = now.difference(lockoutTime) < lockoutDuration;

      if (!isStillLocked) {
        // Lockout period expired, clear it
        await prefs.remove(lockoutKey);
        await prefs.remove("${_uid}_$_failedAttemptsKey");
      }

      return isStillLocked;
    } catch (e) {
      debugPrint("Error checking lockout status: $e");
      return false;
    }
  }

  /// Gets remaining lockout time in seconds
  static Future<int> getRemainingLockoutSeconds() async {
    if (_uid == null) return 0;

    try {
      final prefs = await SharedPreferences.getInstance();
      final lockoutKey = "${_uid}_$_lockoutTimeKey";

      final lockoutTimeMs = prefs.getInt(lockoutKey);
      if (lockoutTimeMs == null) return 0;

      final lockoutTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimeMs);
      final now = DateTime.now();
      final elapsed = now.difference(lockoutTime);

      final remaining = lockoutDuration.inSeconds - elapsed.inSeconds;
      return remaining > 0 ? remaining : 0;
    } catch (e) {
      debugPrint("Error getting remaining lockout: $e");
      return 0;
    }
  }
}
