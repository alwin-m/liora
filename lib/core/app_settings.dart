import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppSettings {
  static const String _darkModeKey = "dark_mode";
  static const String _periodAlertKey = "period_alert";
  static const String _appLockKey = "app_lock";
  static const String _dailyCycleAlertKey = "daily_cycle_alert";

  // Helper to get a user-specific key
  static String _getUserKey(String key) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";
    return "${uid}_$key";
  }

  // ================= DARK MODE =================

  static Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getUserKey(_darkModeKey), value);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_getUserKey(_darkModeKey)) ?? false;
  }

  // ================= PERIOD ALERT =================

  static Future<void> savePeriodAlert(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getUserKey(_periodAlertKey), value);
  }

  static Future<bool> getPeriodAlert() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_getUserKey(_periodAlertKey)) ?? true;
  }

  // ================= APP LOCK =================

  static Future<void> saveAppLock(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getUserKey(_appLockKey), value);
  }

  static Future<bool> getAppLock() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_getUserKey(_appLockKey)) ?? false;
  }

  // ================= DAILY CYCLE ALERT =================

  static Future<void> saveDailyCycleAlert(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getUserKey(_dailyCycleAlertKey), value);
  }

  static Future<bool> getDailyCycleAlert() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_getUserKey(_dailyCycleAlertKey)) ?? true;
  }
}