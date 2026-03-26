import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const String _darkModeKey = "dark_mode";
  static const String _periodAlertKey = "period_alert";

  // ================= DARK MODE =================

  static Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  // ================= PERIOD ALERT =================

  static Future<void> savePeriodAlert(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_periodAlertKey, value);
  }

  static Future<bool> getPeriodAlert() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_periodAlertKey) ?? true;
  }
}