import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// StorageService - Privacy-First Local Storage
///
/// All menstrual and cycle data is stored ONLY on the device.
/// No sensitive biological data is ever transmitted to remote servers.
/// Uses Hive with encrypted storage for maximum privacy.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const String _cycleBoxName = 'cycle_data';
  static const String _settingsBoxName = 'settings';
  static const String _userBoxName = 'user_profile';
  static const String _encryptionKeyName = 'liora_encryption_key';

  late Box<dynamic> _cycleBox;
  late Box<dynamic> _settingsBox;
  late Box<dynamic> _userBox;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Initialize encrypted storage
  Future<void> init() async {
    // Get or create encryption key
    final encryptionKeyString =
        await _secureStorage.read(key: _encryptionKeyName);
    final List<int> encryptionKey;

    if (encryptionKeyString == null) {
      encryptionKey = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _encryptionKeyName,
        value: base64UrlEncode(encryptionKey),
      );
    } else {
      encryptionKey = base64Url.decode(encryptionKeyString);
    }

    // Open encrypted boxes
    _cycleBox = await Hive.openBox(
      _cycleBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    _settingsBox = await Hive.openBox(
      _settingsBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    _userBox = await Hive.openBox(
      _userBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  // =====================
  // CYCLE DATA (LOCAL ONLY)
  // =====================

  /// Save period start date
  Future<void> savePeriodStart(DateTime date) async {
    final key = _dateKey(date);
    final existing =
        _cycleBox.get('period_starts', defaultValue: <String>[]) as List;
    if (!existing.contains(key)) {
      existing.add(key);
      existing.sort();
      await _cycleBox.put('period_starts', existing);
    }
  }

  /// Remove period start date
  Future<void> removePeriodStart(DateTime date) async {
    final key = _dateKey(date);
    final existing =
        _cycleBox.get('period_starts', defaultValue: <String>[]) as List;
    existing.remove(key);
    await _cycleBox.put('period_starts', existing);
  }

  /// Get all period start dates
  List<DateTime> getPeriodStarts() {
    final starts =
        _cycleBox.get('period_starts', defaultValue: <String>[]) as List;
    return starts.map((s) => DateTime.parse(s as String)).toList();
  }

  /// Save period days for a cycle
  Future<void> savePeriodDays(DateTime startDate, List<DateTime> days) async {
    final key = 'period_days_${_dateKey(startDate)}';
    await _cycleBox.put(key, days.map((d) => _dateKey(d)).toList());
  }

  /// Get period days for a cycle
  List<DateTime> getPeriodDays(DateTime startDate) {
    final key = 'period_days_${_dateKey(startDate)}';
    final days = _cycleBox.get(key, defaultValue: <String>[]) as List;
    return days.map((d) => DateTime.parse(d as String)).toList();
  }

  /// Mark a specific day as period
  Future<void> markPeriodDay(DateTime date, bool isPeriod) async {
    final key = 'period_${_dateKey(date)}';
    await _cycleBox.put(key, isPeriod);
  }

  /// Check if a day is marked as period
  bool isPeriodDay(DateTime date) {
    final key = 'period_${_dateKey(date)}';
    return _cycleBox.get(key, defaultValue: false) as bool;
  }

  /// Get all marked period days
  List<DateTime> getAllPeriodDays() {
    final List<DateTime> periodDays = [];
    for (final key in _cycleBox.keys) {
      if (key.toString().startsWith('period_') &&
          !key.toString().startsWith('period_starts') &&
          !key.toString().startsWith('period_days_')) {
        final dateStr = key.toString().replaceFirst('period_', '');
        if (_cycleBox.get(key) == true) {
          try {
            periodDays.add(DateTime.parse(dateStr));
          } catch (_) {}
        }
      }
    }
    return periodDays;
  }

  /// Save symptoms for a day
  Future<void> saveSymptoms(DateTime date, List<String> symptoms) async {
    final key = 'symptoms_${_dateKey(date)}';
    await _cycleBox.put(key, symptoms);
  }

  /// Get symptoms for a day
  List<String> getSymptoms(DateTime date) {
    final key = 'symptoms_${_dateKey(date)}';
    final symptoms = _cycleBox.get(key, defaultValue: <String>[]) as List;
    return symptoms.cast<String>();
  }

  /// Save flow intensity for a day
  Future<void> saveFlowIntensity(DateTime date, String intensity) async {
    final key = 'flow_${_dateKey(date)}';
    await _cycleBox.put(key, intensity);
  }

  /// Get flow intensity for a day
  String? getFlowIntensity(DateTime date) {
    final key = 'flow_${_dateKey(date)}';
    return _cycleBox.get(key) as String?;
  }

  /// Save mood for a day
  Future<void> saveMood(DateTime date, String mood) async {
    final key = 'mood_${_dateKey(date)}';
    await _cycleBox.put(key, mood);
  }

  /// Get mood for a day
  String? getMood(DateTime date) {
    final key = 'mood_${_dateKey(date)}';
    return _cycleBox.get(key) as String?;
  }

  /// Save notes for a day
  Future<void> saveNotes(DateTime date, String notes) async {
    final key = 'notes_${_dateKey(date)}';
    await _cycleBox.put(key, notes);
  }

  /// Get notes for a day
  String? getNotes(DateTime date) {
    final key = 'notes_${_dateKey(date)}';
    return _cycleBox.get(key) as String?;
  }

  // =====================
  // USER PROFILE (LOCAL)
  // =====================

  /// Save user profile data
  Future<void> saveUserProfile({
    DateTime? dateOfBirth,
    DateTime? lastMenstrualPeriod,
    int? averageCycleLength,
    int? averagePeriodLength,
    List<String>? wellnessFlags,
  }) async {
    if (dateOfBirth != null) {
      await _userBox.put('date_of_birth', _dateKey(dateOfBirth));
    }
    if (lastMenstrualPeriod != null) {
      await _userBox.put(
          'last_menstrual_period', _dateKey(lastMenstrualPeriod));
    }
    if (averageCycleLength != null) {
      await _userBox.put('average_cycle_length', averageCycleLength);
    }
    if (averagePeriodLength != null) {
      await _userBox.put('average_period_length', averagePeriodLength);
    }
    if (wellnessFlags != null) {
      await _userBox.put('wellness_flags', wellnessFlags);
    }
  }

  /// Get user date of birth
  DateTime? getDateOfBirth() {
    final dob = _userBox.get('date_of_birth') as String?;
    return dob != null ? DateTime.parse(dob) : null;
  }

  /// Get last menstrual period
  DateTime? getLastMenstrualPeriod() {
    final lmp = _userBox.get('last_menstrual_period') as String?;
    return lmp != null ? DateTime.parse(lmp) : null;
  }

  /// Get average cycle length
  int getAverageCycleLength() {
    return _userBox.get('average_cycle_length', defaultValue: 28) as int;
  }

  /// Get average period length
  int getAveragePeriodLength() {
    return _userBox.get('average_period_length', defaultValue: 5) as int;
  }

  /// Get wellness flags
  List<String> getWellnessFlags() {
    final flags =
        _userBox.get('wellness_flags', defaultValue: <String>[]) as List;
    return flags.cast<String>();
  }

  /// Check if onboarding is complete
  bool isOnboardingComplete() {
    return _userBox.get('onboarding_complete', defaultValue: false) as bool;
  }

  /// Mark onboarding as complete
  Future<void> setOnboardingComplete(bool complete) async {
    await _userBox.put('onboarding_complete', complete);
  }

  // =====================
  // SETTINGS
  // =====================

  /// Save notification settings
  Future<void> saveNotificationSettings({
    bool? periodReminder,
    bool? dailyReminder,
    int? reminderDaysBefore,
    String? reminderTime,
  }) async {
    if (periodReminder != null) {
      await _settingsBox.put('period_reminder', periodReminder);
    }
    if (dailyReminder != null) {
      await _settingsBox.put('daily_reminder', dailyReminder);
    }
    if (reminderDaysBefore != null) {
      await _settingsBox.put('reminder_days_before', reminderDaysBefore);
    }
    if (reminderTime != null) {
      await _settingsBox.put('reminder_time', reminderTime);
    }
  }

  /// Get period reminder setting
  bool getPeriodReminderEnabled() {
    return _settingsBox.get('period_reminder', defaultValue: true) as bool;
  }

  /// Get daily reminder setting
  bool getDailyReminderEnabled() {
    return _settingsBox.get('daily_reminder', defaultValue: false) as bool;
  }

  /// Get reminder days before period
  int getReminderDaysBefore() {
    return _settingsBox.get('reminder_days_before', defaultValue: 3) as int;
  }

  /// Get reminder time
  String getReminderTime() {
    return _settingsBox.get('reminder_time', defaultValue: '09:00') as String;
  }

  // =====================
  // DATA MANAGEMENT
  // =====================

  /// Clear all cycle data (for data reset)
  Future<void> clearCycleData() async {
    await _cycleBox.clear();
  }

  /// Clear all data (full reset)
  Future<void> clearAllData() async {
    await _cycleBox.clear();
    await _settingsBox.clear();
    await _userBox.clear();
  }

  /// Export data as JSON (for local backup)
  Map<String, dynamic> exportData() {
    return {
      'cycle_data': _cycleBox.toMap(),
      'settings': _settingsBox.toMap(),
      'user_profile': _userBox.toMap(),
      'export_date': DateTime.now().toIso8601String(),
    };
  }

  /// Import data from JSON (for local restore)
  Future<void> importData(Map<String, dynamic> data) async {
    if (data['cycle_data'] != null) {
      final cycleData = data['cycle_data'] as Map;
      for (final entry in cycleData.entries) {
        await _cycleBox.put(entry.key, entry.value);
      }
    }
    if (data['settings'] != null) {
      final settings = data['settings'] as Map;
      for (final entry in settings.entries) {
        await _settingsBox.put(entry.key, entry.value);
      }
    }
    if (data['user_profile'] != null) {
      final userProfile = data['user_profile'] as Map;
      for (final entry in userProfile.entries) {
        await _userBox.put(entry.key, entry.value);
      }
    }
  }

  // =====================
  // HELPERS
  // =====================

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
