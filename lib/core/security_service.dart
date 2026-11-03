import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'app_settings.dart';
import 'secure_storage_service.dart';

/// SecurityService manages all authentication-related operations:
/// - Biometric authentication (fingerprint, face recognition)
/// - PIN verification
/// - App lock status management
///
/// Architecture:
/// - Biometric: Handled by device OS via local_auth
/// - PIN: Managed via SecureStorageService (hashed)
/// - Lock Status: Stored in AppSettings (non-sensitive)
class SecurityService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const String _biometricEnabledKey = "biometric_enabled";

  // ================= LOCK STATUS =================

  /// Checks if ANY form of lock (PIN or Biometrics) is enabled and configured
  /// Returns true only if a valid security method is set up
  static Future<bool> isLockEnabled() async {
    final lockEnabled = await AppSettings.getAppLock();
    if (!lockEnabled) return false;

    final pinSet = await SecureStorageService.hasPIN();
    final bioEnabled = await isBiometricEnabled();
    return pinSet || bioEnabled;
  }

  // ================= BIOMETRICS =================

  /// Checks if device supports biometric authentication
  /// Returns true if device has fingerprint/face recognition capability
  static Future<bool> canAuthenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      debugPrint("Error checking biometric capability: $e");
      return false;
    }
  }

  /// Attempts biometric authentication (fingerprint/face)
  ///
  /// Parameters:
  /// - reason: Message shown to user during biometric prompt
  ///
  /// Returns:
  /// - true: User successfully authenticated
  /// - false: User cancelled, biometric failed, or device doesn't support
  static Future<bool> authenticateBiometrics({
    String reason = "Please authenticate to open Liora",
  }) async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true, // Only biometric, no PIN fallback here
          useErrorDialogs: true,
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint("Biometric Error: $e");
      return false;
    }
  }

  /// Enables biometric authentication for app lock
  /// NOTE: PIN is ALWAYS required as backup/fallback
  static Future<void> enableBiometric() async {
    try {
      // Verify biometric is available
      final canAuth = await canAuthenticate();
      if (!canAuth) {
        throw Exception("Device does not support biometric authentication");
      }

      // Request biometric from user
      final success = await authenticateBiometrics(
        reason: "Register your fingerprint for Liora app lock",
      );

      if (success) {
        // Store that biometric is enabled
        final uid = SecureStorageService.getCurrentUserUID();
        if (uid != null) {
          await SecureStorageService.saveBiometricEnabled(true);
          debugPrint("[SecurityService] Biometric enabled for user: $uid");
        }
      }
    } catch (e) {
      debugPrint("Error enabling biometric: $e");
      rethrow;
    }
  }

  /// Disables biometric authentication (PIN remains if set)
  static Future<void> disableBiometric() async {
    try {
      await SecureStorageService.saveBiometricEnabled(false);
      debugPrint("[SecurityService] Biometric disabled");
    } catch (e) {
      debugPrint("Error disabling biometric: $e");
      rethrow;
    }
  }

  /// Checks if biometric is currently enabled by user
  static Future<bool> isBiometricEnabled() async {
    try {
      return await SecureStorageService.getBiometricEnabled();
    } catch (e) {
      debugPrint("Error checking biometric status: $e");
      return false;
    }
  }

  /// Gets list of available biometric types on device
  /// Examples: fingerprint, face, iris
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint("Error getting available biometrics: $e");
      return [];
    }
  }

  // ================= CUSTOM PIN =================

  /// Verifies an entered PIN against the stored hash
  static Future<bool> verifyPIN(String pin) async {
    return await SecureStorageService.verifyPIN(pin);
  }

  /// Sets a new PIN for the current user
  /// Automatically enables app lock when PIN is set
  static Future<void> setPIN(String pin) async {
    try {
      await SecureStorageService.savePIN(pin);
      // Automatically enable app lock if setting a PIN
      await AppSettings.saveAppLock(true);
      debugPrint("[SecurityService] PIN saved and app lock enabled");
    } catch (e) {
      debugPrint("Error setting PIN: $e");
      rethrow;
    }
  }

  /// Checks if a PIN is already set for the current user
  static Future<bool> hasPIN() async {
    return await SecureStorageService.hasPIN();
  }

  /// Clears the PIN (called after recovery via email+password)
  static Future<void> clearPIN() async {
    await SecureStorageService.clearPIN();
  }

  // ================= LOGOUT & CLEANUP =================

  /// Performs security cleanup when user logs out
  /// Called after Firebase Auth signOut()
  ///
  /// What happens:
  /// - Clears temporary session data
  /// - App lock remains configured in local storage
  /// - UID-scoped keys become inaccessible (new user has different UID)
  /// - This ensures multi-user data isolation
  static Future<void> onUserLogout() async {
    try {
      await SecureStorageService.clearUserDataOnLogout();
      debugPrint("[SecurityService] Security cleanup completed on logout");
    } catch (e) {
      debugPrint("Error during logout cleanup: $e");
      // Don't rethrow - logout should proceed even if cleanup fails
    }
  }

  // ================= SYSTEM BIOMETRIC TYPES =================

  /// Returns a human-readable name for biometric type
  static String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return "Face Recognition";
      case BiometricType.fingerprint:
        return "Fingerprint";
      case BiometricType.iris:
        return "Iris Scan";
      case BiometricType.strong:
        return "Biometric (Strong)";
      case BiometricType.weak:
        return "Biometric (Weak)";
    }
  }
}
