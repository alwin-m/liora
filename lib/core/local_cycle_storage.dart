import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'cycle_state.dart';

/// ===================================================================
/// LOCAL STORAGE FOR STATE MACHINE
/// Persists the entire CycleState object to device storage.
/// NO PREDICTIONS STORED - only state.
/// ===================================================================
class LocalCycleStorage {
  static const String _cycleStateKey = 'cycle_state';
  static const String _notificationsKey = 'notifications';

  /// ==================== STATE PERSISTENCE ====================

  /// Save entire cycle state to device storage
  static Future<void> saveCycleState(CycleState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cycleStateKey, jsonEncode(state.toJson()));
  }

  /// Load entire cycle state from device storage
  static Future<CycleState> loadCycleState() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_cycleStateKey);

    if (json == null) {
      return CycleState(); // Return default state if none saved
    }

    try {
      return CycleState.fromJson(jsonDecode(json));
    } catch (e) {
      return CycleState();
    }
  }

  /// ==================== NOTIFICATION SETTINGS ====================

  /// Get notification settings
  static Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_notificationsKey);

    if (json == null) {
      return {
        'cycleReminder': true,
        'periodReminder': true,
      };
    }

    return Map<String, bool>.from(jsonDecode(json));
  }

  /// Save notification settings
  static Future<void> saveNotificationSettings(
      Map<String, bool> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationsKey, jsonEncode(settings));
  }

  /// ==================== PRIVACY & CLEANUP ====================

  /// Clear all local data (on logout)
  /// This wipes:
  /// - All cycle history
  /// - All state
  /// - All notifications
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cycleStateKey);
    await prefs.remove(_notificationsKey);
  }
}
