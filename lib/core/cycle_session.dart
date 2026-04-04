import 'dart:math';
import 'advanced_cycle_profile.dart';
import 'cycle_algorithm.dart';
import 'local_storage.dart';
import 'annie_hathaway_algorithm.dart';
import '../models/cycle_record.dart';
import '../models/hathaway_cycle_log.dart';
import '../models/hathaway_day_log.dart';

/// Global session manager for all cycle-related state.
/// Holds both the legacy static algorithm and the living Annie Hathaway engine.
class CycleSession {
  static AdvancedCycleProfile? _profile;
  static CycleAlgorithm? _algorithm;
  static List<CycleRecord> _history = [];

  // ── Annie Hathaway state ──────────────────────────────────────────────────
  static List<HathawayCycleLog> _annieLogs = [];
  static AnnieHathawayAlgorithm? _annie;
  static String? _activeCycleId; // ID of the current open cycle log

  // ================= GETTERS =================

  static AdvancedCycleProfile get profile {
    if (_profile == null) throw Exception('CycleSession not initialized');
    return _profile!;
  }

  static CycleAlgorithm get algorithm {
    if (_algorithm == null) throw Exception('CycleSession algorithm not initialized');
    return _algorithm!;
  }

  static List<CycleRecord> get history => _history;
  static List<HathawayCycleLog> get annieLogs => _annieLogs;
  static bool get isInitialized => _profile != null;

  /// The Annie Hathaway prediction engine.
  static AnnieHathawayAlgorithm get annie {
    if (_annie == null) throw Exception('CycleSession not initialized');
    return _annie!;
  }

  /// True if Annie has enough training data to personalise predictions.
  static bool get isAnnieTrained => _annie?.isTrained ?? false;

  /// The current open cycle log (period in progress), or null.
  static HathawayCycleLog? get activeCycleLog => _activeCycleId == null
      ? null
      : _annieLogs.cast<HathawayCycleLog?>().firstWhere(
            (l) => l?.id == _activeCycleId,
            orElse: () => null,
          );

  // ================= INITIALIZE =================

  static Future<void> initialize() async {
    final storedProfile = await LocalStorage.getProfile();
    final storedHistory = await LocalStorage.getCycleHistory();
    final storedAnnieLogs = await LocalStorage.loadAnnieLogs();

    if (storedProfile != null) {
      _profile = storedProfile;
      _algorithm = CycleAlgorithm(profile: storedProfile);
    }

    if (storedHistory != null) _history = storedHistory;

    _annieLogs = storedAnnieLogs;
    _rebuildAnnie();

    // Find active cycle (one without actualPeriodLength finalized)
    _activeCycleId = _annieLogs
        .cast<HathawayCycleLog?>()
        .firstWhere(
          (l) => l != null && l.actualPeriodLength == null && l.hasActualStart,
          orElse: () => null,
        )
        ?.id;
  }

  static Future<void> loadFromLocalStorage() async => initialize();

  // ================= SAVE PROFILE =================

  static Future<void> saveToLocalStorage(AdvancedCycleProfile profile) async {
    _profile = profile;
    _algorithm = CycleAlgorithm(profile: profile);
    await LocalStorage.saveProfile(profile);
  }

  // ================= LEGACY: ADD CYCLE RECORD =================

  static Future<void> addCycleRecord(DateTime newStartDate) async {
    if (_profile == null || _algorithm == null) return;

    final previousStart = _profile!.lastPeriodDate;
    final predicted = _algorithm!.getNextPeriodDate();
    final cycleLength = newStartDate.difference(previousStart).inDays;
    final deviation = newStartDate.difference(predicted).inDays;

    final record = CycleRecord(
      startDate: newStartDate,
      cycleLength: cycleLength,
      predictedDate: predicted,
      deviation: deviation,
    );

    _history.insert(0, record);

    _profile = AdvancedCycleProfile(
      lastPeriodDate: newStartDate,
      averageCycleLength: _profile!.averageCycleLength,
      averagePeriodLength: _profile!.averagePeriodLength,
      age: _profile!.age,
      isRegularCycle: _profile!.isRegularCycle,
      stressLevel: _profile!.stressLevel,
      painLevel: _profile!.painLevel,
      pmsSeverity: _profile!.pmsSeverity,
      flowIntensity: _profile!.flowIntensity,
      ovulationSymptoms: _profile!.ovulationSymptoms,
      sleepQuality: _profile!.sleepQuality,
      exerciseLevel: _profile!.exerciseLevel,
      bmiCategory: _profile!.bmiCategory,
      hasPCOS: _profile!.hasPCOS,
      hasThyroid: _profile!.hasThyroid,
      onHormonalMedication: _profile!.onHormonalMedication,
      recentlyPregnant: _profile!.recentlyPregnant,
      breastfeeding: _profile!.breastfeeding,
    );

    _algorithm = CycleAlgorithm(profile: _profile!);

    await LocalStorage.saveProfile(_profile!);
    await LocalStorage.saveCycleHistory(_history);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  ANNIE HATHAWAY — TRAINING ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// User confirms their period started on [actualDate].
  /// Creates (or updates) the active cycle log and trains Annie.
  static Future<void> confirmPeriodStart(DateTime actualDate) async {
    if (_profile == null) return;

    final predicted = isAnnieTrained
        ? annie.getNextPeriodDate()
        : _algorithm!.getNextPeriodDate();

    // Close out any previous dangling active cycle
    if (_activeCycleId != null) {
      _closeActiveCycle();
    }

    // Compute actual cycle length from the most recent confirmed start
    final prevStart = _confirmedAnnieStart;

    final newLog = HathawayCycleLog(
      id: _uuid(),
      predictedStart: predicted,
      actualStart: actualDate,
      actualCycleLength: prevStart != null
          ? actualDate.difference(prevStart).inDays
          : null,
      createdAt: DateTime.now(),
    );

    _annieLogs.insert(0, newLog);
    _activeCycleId = newLog.id;
    _rebuildAnnie();

    // Also update the static profile's lastPeriodDate for legacy algorithm
    await addCycleRecord(actualDate);
    await LocalStorage.saveAnnieLogs(_annieLogs);
  }

  /// Log flow percentage and pain for a specific period day number.
  /// Updates the active cycle log.
  static Future<void> logDay({
    required int dayNumber,
    required DateTime date,
    required int flowPercent,
    required int painLevel,
  }) async {
    if (_activeCycleId == null) return;

    final idx = _annieLogs.indexWhere((l) => l.id == _activeCycleId);
    if (idx == -1) return;

    final log = _annieLogs[idx];
    final existingIdx = log.dayLogs.indexWhere((d) => d.dayNumber == dayNumber);

    final newDayLog = HathawayDayLog(
      dayNumber: dayNumber,
      date: date,
      flowPercent: flowPercent.clamp(0, 100),
      painLevel: painLevel.clamp(0, 3),
    );

    final newDayLogs = List<HathawayDayLog>.from(log.dayLogs);
    if (existingIdx >= 0) {
      newDayLogs[existingIdx] = newDayLog;
    } else {
      newDayLogs.add(newDayLog);
    }
    newDayLogs.sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

    _annieLogs[idx] = log.copyWith(
      dayLogs: newDayLogs,
      actualPeriodLength: newDayLogs.length,
    );
    _rebuildAnnie();
    await LocalStorage.saveAnnieLogs(_annieLogs);
  }

  /// Get existing log for a specific day of the active cycle (if any).
  static HathawayDayLog? getDayLog(int dayNumber) {
    final active = activeCycleLog;
    if (active == null) return null;
    try {
      return active.dayLogs.firstWhere((d) => d.dayNumber == dayNumber);
    } catch (_) {
      return null;
    }
  }

  // ================= CLEAR =================

  static Future<void> clearSession() async {
    _profile = null;
    _algorithm = null;
    _annie = null;
    _history = [];
    _annieLogs = [];
    _activeCycleId = null;
    await LocalStorage.clearProfile();
    await LocalStorage.clearCycleHistory();
    await LocalStorage.clearAnnieLogs();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  static void _rebuildAnnie() {
    if (_algorithm == null) return;
    _annie = AnnieHathawayAlgorithm(
      logs: List.unmodifiable(_annieLogs),
      fallback: _algorithm!,
    );
  }

  static void _closeActiveCycle() {
    if (_activeCycleId == null) return;
    final idx = _annieLogs.indexWhere((l) => l.id == _activeCycleId);
    if (idx < 0) return;
    final log = _annieLogs[idx];
    if (log.dayLogs.isNotEmpty) {
      _annieLogs[idx] = log.copyWith(
        actualPeriodLength: log.dayLogs.length,
      );
    }
    _activeCycleId = null;
  }

  /// The actual start date from the most recently confirmed Hathaway cycle.
  static DateTime? get _confirmedAnnieStart {
    try {
      return _annieLogs.firstWhere((l) => l.hasActualStart).actualStart;
    } catch (_) {
      return null;
    }
  }

  static String _uuid() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int v) => v.toRadixString(16).padLeft(2, '0');
    return '${hex(bytes[0])}${hex(bytes[1])}${hex(bytes[2])}${hex(bytes[3])}'
        '-${hex(bytes[4])}${hex(bytes[5])}'
        '-${hex(bytes[6])}${hex(bytes[7])}'
        '-${hex(bytes[8])}${hex(bytes[9])}'
        '-${hex(bytes[10])}${hex(bytes[11])}${hex(bytes[12])}${hex(bytes[13])}${hex(bytes[14])}${hex(bytes[15])}';
  }
}