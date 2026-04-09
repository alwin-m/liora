import 'advanced_cycle_profile.dart';
import 'cycle_algorithm.dart';
import 'local_storage.dart';
import '../models/cycle_record.dart';

class CycleSession {
  static AdvancedCycleProfile? _profile;
  static CycleAlgorithm? _algorithm;
  static List<CycleRecord> _history = [];

  // ================= GETTERS =================

  static AdvancedCycleProfile get profile {
    if (_profile == null) {
      throw Exception("CycleSession not initialized");
    }
    return _profile!;
  }

  static CycleAlgorithm get algorithm {
    if (_algorithm == null) {
      throw Exception("CycleSession algorithm not initialized");
    }
    return _algorithm!;
  }

  static List<CycleRecord> get history => _history;

  static bool get isInitialized => _profile != null;

  // ================= INITIALIZE =================

  static Future<void> initialize() async {
    final storedProfile = await LocalStorage.getProfile();
    final storedHistory = await LocalStorage.getCycleHistory();

    if (storedProfile != null) {
      _profile = storedProfile;
      _algorithm = CycleAlgorithm(profile: storedProfile);
    }

    if (storedHistory != null) {
      _history = storedHistory;
    }
  }

  // ================= LOAD =================

  static Future<void> loadFromLocalStorage() async {
    return initialize();
  }

  // ================= SAVE PROFILE =================

  static Future<void> saveToLocalStorage(AdvancedCycleProfile profile) async {
    _profile = profile;
    _algorithm = CycleAlgorithm(profile: profile);
    await LocalStorage.saveProfile(profile);
  }

  static Future<void> updateProfile(AdvancedCycleProfile p) => saveToLocalStorage(p);

  // ================= ADD NEW CYCLE RECORD =================

  static Future<void> addCycleRecord(DateTime newStartDate) async {
    if (_profile == null || _algorithm == null) return;

    final history = _history;
    final predicted = _algorithm!.getNextPeriodDate();
    final cycleLength = newStartDate.difference(_profile!.lastPeriodDate).inDays;
    final deviation = newStartDate.difference(predicted).inDays;

    final record = CycleRecord(
      startDate: newStartDate,
      cycleLength: cycleLength,
      predictedDate: predicted,
      deviation: deviation,
    );

    _history.insert(0, record);

    // Update profile last period while preserving other fields (like profileImage)
    _profile = _profile!.copyWith(lastPeriodDate: newStartDate);
    _algorithm = CycleAlgorithm(profile: _profile!);

    await LocalStorage.saveProfile(_profile!);
    await LocalStorage.saveCycleHistory(_history);
  }

  // ================= CLEAR =================

  static Future<void> clearSession() async {
    _profile = null;
    _algorithm = null;
    _history = [];

    await LocalStorage.clearProfile();
    await LocalStorage.clearCycleHistory();
  }
}