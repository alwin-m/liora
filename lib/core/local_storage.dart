import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'advanced_cycle_profile.dart';
import '../models/cycle_record.dart';

class LocalStorage {
  static const String _profileKey = "advanced_cycle_profile";
  static const String _onboardingKey = "onboarding_completed";
  static const String _historyKey = "cycle_history";

  // ==============================
  // SAVE ADVANCED PROFILE
  // ==============================

  static Future<void> saveAdvancedProfile(
      AdvancedCycleProfile profile) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(profile.toJson());

    await prefs.setString(_profileKey, jsonString);
    await prefs.setBool(_onboardingKey, true);
  }

  // ==============================
  // LOAD ADVANCED PROFILE
  // ==============================

  static Future<AdvancedCycleProfile?> loadAdvancedProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_profileKey);

    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> json =
          jsonDecode(jsonString);

      return AdvancedCycleProfile.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  // ==============================
  // SAVE CYCLE HISTORY
  // ==============================

  static Future<void> saveCycleHistory(
      List<CycleRecord> history) async {
    final prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> jsonList =
        history.map((e) => e.toJson()).toList();

    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  // ==============================
  // LOAD CYCLE HISTORY
  // ==============================

  static Future<List<CycleRecord>?> getCycleHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> decoded =
          jsonDecode(jsonString);

      return decoded
          .map((e) =>
              CycleRecord.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ==============================
  // CLEAR HISTORY
  // ==============================

  static Future<void> clearCycleHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ==============================
  // CHECK ONBOARDING STATUS
  // ==============================

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  // ==============================
  // CLEAR PROFILE (LOGOUT RESET)
  // ==============================

  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    await prefs.remove(_onboardingKey);
  }

  // ==============================
  // SAVE PROFILE (ALIAS)
  // ==============================

  static Future<void> saveProfile(
      AdvancedCycleProfile profile) async {
    return saveAdvancedProfile(profile);
  }

  // ==============================
  // GET PROFILE (ALIAS)
  // ==============================

  static Future<AdvancedCycleProfile?> getProfile() async {
    return loadAdvancedProfile();
  }
}