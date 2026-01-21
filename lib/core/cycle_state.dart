import 'cycle_history_entry.dart';

/// STATE MACHINE: Two possible bleeding states
enum BleedingState { NO_ACTIVE_BLEEDING, ACTIVE_BLEEDING }

/// ===================================================================
/// SINGLE SOURCE OF TRUTH FOR ALL CYCLE STATE
/// ===================================================================
/// This is the authoritative object. Calendar, predictions, and UI
/// are ALL derived from this. Nothing else stores cycle state.
///
class CycleState {
  /// ==================== BLEEDING STATE ====================
  BleedingState bleedingState;
  DateTime? bleedingStartDate;
  DateTime? bleedingEndDate;

  /// ==================== HISTORICAL AVERAGES ====================
  /// Calculated from cycle history. Used for predictions.
  /// Updated whenever a cycle is finalized.
  int averageCycleLength;
  int averageBleedingLength;

  /// ==================== CYCLE HISTORY ====================
  /// All confirmed and provisional cycles ever recorded.
  /// Latest cycle is last in list.
  /// Each cycle is immutable once confirmed.
  List<CycleHistoryEntry> cycleHistory;

  /// ==================== ONBOARDING BASELINE ====================
  /// From user's initial setup (onboarding).
  /// Only used if cycleHistory is empty.
  int defaultCycleLength;
  int defaultBleedingLength;

  CycleState({
    this.bleedingState = BleedingState.NO_ACTIVE_BLEEDING,
    this.bleedingStartDate,
    this.bleedingEndDate,
    this.averageCycleLength = 28,
    this.averageBleedingLength = 5,
    this.cycleHistory = const [],
    this.defaultCycleLength = 28,
    this.defaultBleedingLength = 5,
  });

  /// ==================== STATE MUTATIONS ====================

  /// User marked period START
  void markPeriodStart(DateTime startDate) {
    bleedingState = BleedingState.ACTIVE_BLEEDING;
    bleedingStartDate = startDate;
    bleedingEndDate = null; // Reset end until user confirms stop

    // Append provisional cycle entry (not confirmed yet)
    final provisionalCycle = CycleHistoryEntry(
      cycleStartDate: startDate,
      bleedingLength: averageBleedingLength, // Provisional
      cycleLength: averageCycleLength, // Provisional
      isConfirmed: false,
    );
    cycleHistory.add(provisionalCycle);
  }

  /// User marked period STOP
  void markPeriodStop(DateTime stopDate) {
    if (bleedingStartDate == null) return;

    bleedingState = BleedingState.NO_ACTIVE_BLEEDING;
    bleedingEndDate = stopDate;

    // Calculate actual bleeding length
    final actualBleedingLength = stopDate.difference(bleedingStartDate!).inDays + 1;

    // If we have a previous confirmed cycle, calculate actual cycle length
    int actualCycleLength = averageCycleLength;
    if (cycleHistory.length >= 2) {
      final previousStart = cycleHistory[cycleHistory.length - 2].cycleStartDate;
      actualCycleLength = bleedingStartDate!.difference(previousStart).inDays;
    }

    // Finalize the last (provisional) cycle entry
    if (cycleHistory.isNotEmpty) {
      final lastCycle = cycleHistory.last;
      cycleHistory[cycleHistory.length - 1] = CycleHistoryEntry(
        cycleStartDate: lastCycle.cycleStartDate,
        cycleEndDate: stopDate,
        cycleLength: actualCycleLength,
        bleedingLength: actualBleedingLength,
        isConfirmed: true,
      );
    }

    // Update averages using weighted calculation
    _updateAveragesFromHistory();
  }

  /// ==================== PRIVATE HELPERS ====================

  /// Recalculate weighted averages from history
  /// Last 3 cycles: 60% weight, older cycles: 40% weight
  void _updateAveragesFromHistory() {
    if (cycleHistory.isEmpty) return;

    final confirmedCycles =
        cycleHistory.where((c) => c.isConfirmed).toList();
    if (confirmedCycles.isEmpty) return;

    int totalCycleLength = 0;
    int totalBleedingLength = 0;
    double totalWeight = 0;

    // Weight calculation
    for (int i = 0; i < confirmedCycles.length; i++) {
      final cycle = confirmedCycles[i];
      final weight = i >= confirmedCycles.length - 3
          ? 0.6 / 3 // Last 3 cycles split 60% equally
          : 0.4 / (confirmedCycles.length - 3).clamp(1, double.infinity);

      totalCycleLength += (cycle.cycleLength * weight).toInt();
      totalBleedingLength += (cycle.bleedingLength * weight).toInt();
      totalWeight += weight;
    }

    averageCycleLength = (totalCycleLength / totalWeight).round().clamp(18, 40);
    averageBleedingLength =
        (totalBleedingLength / totalWeight).round().clamp(2, 10);
  }

  /// ==================== QUERIES ====================

  /// Get most recent confirmed cycle
  CycleHistoryEntry? getLastConfirmedCycle() {
    try {
      return cycleHistory.lastWhere((c) => c.isConfirmed);
    } catch (e) {
      return null;
    }
  }

  /// Get effective cycle length for predictions
  /// Prefers recent confirmed cycles, falls back to defaults
  int getEffectiveCycleLength() {
    if (cycleHistory.isEmpty) return defaultCycleLength;
    return averageCycleLength;
  }

  /// Get effective bleeding length for predictions
  int getEffectiveBleedingLength() {
    if (cycleHistory.isEmpty) return defaultBleedingLength;
    return averageBleedingLength;
  }

  /// ==================== SERIALIZATION ====================

  Map<String, dynamic> toJson() {
    return {
      'bleedingState': bleedingState.toString(),
      'bleedingStartDate': bleedingStartDate?.toIso8601String(),
      'bleedingEndDate': bleedingEndDate?.toIso8601String(),
      'averageCycleLength': averageCycleLength,
      'averageBleedingLength': averageBleedingLength,
      'cycleHistory': cycleHistory.map((c) => c.toJson()).toList(),
      'defaultCycleLength': defaultCycleLength,
      'defaultBleedingLength': defaultBleedingLength,
    };
  }

  factory CycleState.fromJson(Map<String, dynamic> json) {
    return CycleState(
      bleedingState: json['bleedingState']?.contains('ACTIVE_BLEEDING') ?? false
          ? BleedingState.ACTIVE_BLEEDING
          : BleedingState.NO_ACTIVE_BLEEDING,
      bleedingStartDate: json['bleedingStartDate'] != null
          ? DateTime.parse(json['bleedingStartDate'])
          : null,
      bleedingEndDate: json['bleedingEndDate'] != null
          ? DateTime.parse(json['bleedingEndDate'])
          : null,
      averageCycleLength: json['averageCycleLength'] ?? 28,
      averageBleedingLength: json['averageBleedingLength'] ?? 5,
      cycleHistory: (json['cycleHistory'] as List?)
              ?.map((c) => CycleHistoryEntry.fromJson(c))
              .toList() ??
          [],
      defaultCycleLength: json['defaultCycleLength'] ?? 28,
      defaultBleedingLength: json['defaultBleedingLength'] ?? 5,
    );
  }
}
