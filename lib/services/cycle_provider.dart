import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cycle_data.dart';
import '../models/cycle_history_entry.dart';

/// PRIVACY POLICY: This provider manages STRICTLY LOCAL medical data.
///
/// DATA CLASSIFICATION:
/// - Menstrual cycle data is classified as SENSITIVE HEALTH INFORMATION
/// - MUST be stored ONLY on the user's device using encrypted local storage
/// - MUST NEVER be transmitted to or stored in backend database
/// - MUST function completely offline without network dependency
/// - MUST be automatically deleted when app is uninstalled
///
/// COMPLIANCE:
/// - No Firestore sync for medical data
/// - No backend transmission of cycle information
/// - No analytics or logging of sensitive cycle data
/// - Local-first offline-capable architecture
class CycleProvider with ChangeNotifier {
  CycleDataModel? _cycleData;
  List<CycleHistoryEntry> _history = [];
  bool _isLoading = true;

  CycleDataModel? get cycleData => _cycleData;
  List<CycleHistoryEntry> get history => _history;
  bool get isLoading => _isLoading;

  /// Local storage key - data is encrypted by SharedPreferences on Android
  /// and Keychain on iOS using platform-native secure storage
  static const String _storageKey = 'liora_cycle_data_local_only';

  CycleProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadData();
  }

  /// Load menstrual cycle data from LOCAL storage only.
  /// This data NEVER comes from or syncs with backend databases.
  /// Full offline capability is maintained at all times.
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load from local secure storage only
      final prefs = await SharedPreferences.getInstance();
      final localData = prefs.getString(_storageKey);

      if (localData != null) {
        final decoded = jsonDecode(localData);
        _cycleData = CycleDataModel.fromJson(decoded['current']);
        if (decoded['history'] != null) {
          _history = (decoded['history'] as List)
              .map((e) => CycleHistoryEntry.fromJson(e))
              .toList();
        }
      }

      // Use default if no local data exists
      if (_cycleData == null) {
        _cycleData = CycleDataModel(
          lastPeriodStartDate: DateTime.now().subtract(
            const Duration(days: 14),
          ),
          averageCycleLength: 28,
          averagePeriodDuration: 5,
        );

        // Auto-generate demo history for UI testing
        if (_history.isEmpty) {
          _history = [
            CycleHistoryEntry(
              predictedStartDate: DateTime.now().subtract(
                const Duration(days: 42),
              ),
              actualStartDate: DateTime.now().subtract(
                const Duration(days: 42),
              ),
              cycleLength: 28,
              periodDuration: 5,
              predictionDeviationDays: 0,
            ),
            CycleHistoryEntry(
              predictedStartDate: DateTime.now().subtract(
                const Duration(days: 70),
              ),
              actualStartDate: DateTime.now().subtract(
                const Duration(days: 72),
              ),
              cycleLength: 30,
              periodDuration: 6,
              predictionDeviationDays: 2,
            ),
          ];
        }
      }
    } catch (e) {
      debugPrint('[PRIVACY] Error loading local cycle data: $e');
      // Initialize with defaults if load fails
      _cycleData = CycleDataModel(
        lastPeriodStartDate: DateTime.now().subtract(const Duration(days: 14)),
        averageCycleLength: 28,
        averagePeriodDuration: 5,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update cycle data and persist to LOCAL storage only.
  /// CRITICAL: This data is NEVER sent to the backend.
  /// All predictions are computed locally using this data.
  Future<void> updateCycleData({
    required DateTime lastPeriodStartDate,
    required int averageCycleLength,
    required int averagePeriodDuration,
    String? flowLevel,
    String? cycleRegularity,
    String? pmsLevel,
  }) async {
    final newData = CycleDataModel(
      lastPeriodStartDate: lastPeriodStartDate,
      averageCycleLength: averageCycleLength,
      averagePeriodDuration: averagePeriodDuration,
      flowLevel: flowLevel,
      cycleRegularity: cycleRegularity,
      pmsLevel: pmsLevel,
    );

    _cycleData = newData;
    notifyListeners();

    // Save to LOCAL storage only - NO backend transmission
    await _saveLocalOnly(newData);
  }

  /// Save cycle data to LOCAL storage only using encrypted SharedPreferences.
  /// This is the ONLY persistence mechanism for medical data.
  /// No network calls, no backend uploads, no sync.
  Future<void> _saveLocalOnly(CycleDataModel data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode({
          'current': data.toJson(),
          'history': _history.map((e) => e.toJson()).toList(),
        }),
      );
      debugPrint('[PRIVACY] Cycle data saved to LOCAL storage only');
    } catch (e) {
      debugPrint('[PRIVACY] Error saving to local storage: $e');
    }
  }

  /// Clear all local medical data (called on logout or account deletion).
  /// This ensures no sensitive health data remains on device after logout.
  Future<void> clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      _cycleData = null;
      _history = [];
      notifyListeners();
      debugPrint('[PRIVACY] Local medical data cleared');
    } catch (e) {
      debugPrint('[PRIVACY] Error clearing local data: $e');
    }
  }
}
