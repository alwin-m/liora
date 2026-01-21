import 'cycle_history_entry.dart';
import 'prediction_engine.dart';

/// STATE MACHINE: Two possible bleeding states
enum BleedingState { noActiveBleeding, activeBleeding }

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
    this.bleedingState = BleedingState.noActiveBleeding,
    this.bleedingStartDate,
    this.bleedingEndDate,
    this.averageCycleLength = 28,
    this.averageBleedingLength = 5,
    List<CycleHistoryEntry>? cycleHistory,
    this.defaultCycleLength = 28,
    this.defaultBleedingLength = 5,
  }) : cycleHistory = cycleHistory ?? [];

  /// ==================== STATE MUTATIONS ====================

  /// User marked period START
  void markPeriodStart(DateTime startDate) {
    bleedingState = BleedingState.activeBleeding;
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

    bleedingState = BleedingState.noActiveBleeding;
    bleedingEndDate = stopDate;

    // Calculate actual bleeding length
    final actualBleedingLength =
        stopDate.difference(bleedingStartDate!).inDays + 1;

    // If we have a previous confirmed cycle, calculate actual cycle length
    int actualCycleLength = averageCycleLength;
    if (cycleHistory.length >= 2) {
      final previousStart =
          cycleHistory[cycleHistory.length - 2].cycleStartDate;
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

  /// ==================== CONVENIENCE GETTERS ====================

  /// Boolean accessor for active bleeding state
  bool get isActiveBleeding => bleedingState == BleedingState.activeBleeding;

  /// Get all confirmed cycles from history
  List<CycleHistoryEntry> get confirmedCycles =>
      cycleHistory.where((c) => c.isConfirmed).toList();

  /// Get all historical bleeding date ranges (for calendar rendering)
  List<DateRange> getHistoricalBleedingRanges() {
    final ranges = <DateRange>[];
    for (final cycle in confirmedCycles) {
      if (cycle.cycleEndDate != null) {
        ranges.add(
          DateRange(start: cycle.cycleStartDate, end: cycle.cycleEndDate!),
        );
      }
    }
    return ranges;
  }

  /// ==================== PRIVATE HELPERS ====================

  /// Recalculate weighted averages from history
  /// Last 3 cycles: 60% weight, older cycles: 40% weight
  ///
  /// Algorithm:
  /// - Recent cycles (last 3) share 60% of total weight
  /// - Older cycles share 40% of total weight
  /// - This ensures predictions adapt gradually, not wildly
  void _updateAveragesFromHistory() {
    if (cycleHistory.isEmpty) return;

    final confirmed = confirmedCycles;
    if (confirmed.isEmpty) return;

    // Simple average for small history
    if (confirmed.length <= 3) {
      int totalCycle = 0;
      int totalBleeding = 0;
      for (final c in confirmed) {
        totalCycle += c.cycleLength;
        totalBleeding += c.bleedingLength;
      }
      averageCycleLength = (totalCycle / confirmed.length).round().clamp(
        18,
        45,
      );
      averageBleedingLength = (totalBleeding / confirmed.length).round().clamp(
        2,
        10,
      );
      return;
    }

    // Weighted average for larger history
    double weightedCycleSum = 0;
    double weightedBleedingSum = 0;
    double totalWeight = 0;

    final recentCount = 3;
    final olderCount = confirmed.length - recentCount;

    for (int i = 0; i < confirmed.length; i++) {
      final cycle = confirmed[i];
      double weight;

      if (i >= confirmed.length - recentCount) {
        // Last 3 cycles: each gets 60% / 3 = 20% weight
        weight = 0.6 / recentCount;
      } else {
        // Older cycles: share 40% equally
        weight = 0.4 / olderCount;
      }

      weightedCycleSum += cycle.cycleLength * weight;
      weightedBleedingSum += cycle.bleedingLength * weight;
      totalWeight += weight;
    }

    // Normalize by total weight (should be ~1.0 but normalize for safety)
    averageCycleLength = (weightedCycleSum / totalWeight).round().clamp(18, 45);
    averageBleedingLength = (weightedBleedingSum / totalWeight).round().clamp(
      2,
      10,
    );
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
      bleedingState: json['bleedingState']?.contains('activeBleeding') ?? false
          ? BleedingState.activeBleeding
          : BleedingState.noActiveBleeding,
      bleedingStartDate: json['bleedingStartDate'] != null
          ? DateTime.parse(json['bleedingStartDate'])
          : null,
      bleedingEndDate: json['bleedingEndDate'] != null
          ? DateTime.parse(json['bleedingEndDate'])
          : null,
      averageCycleLength: json['averageCycleLength'] ?? 28,
      averageBleedingLength: json['averageBleedingLength'] ?? 5,
      cycleHistory:
          (json['cycleHistory'] as List?)
              ?.map((c) => CycleHistoryEntry.fromJson(c))
              .toList() ??
          [],
      defaultCycleLength: json['defaultCycleLength'] ?? 28,
      defaultBleedingLength: json['defaultBleedingLength'] ?? 5,
    );
  }
}
