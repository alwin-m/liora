import 'cycle_state.dart';

/// ===================================================================
/// PURE FUNCTIONS FOR CYCLE PREDICTIONS
/// These are stateless functions derived entirely from CycleState.
/// No side effects. Always deterministic.
/// ===================================================================

class PredictionEngine {
  /// Calculate next period start date based on state
  static DateTime getNextPeriodStart(CycleState state) {
    if (state.bleedingStartDate == null) {
      return DateTime.now().add(Duration(days: 14));
    }

    // If currently bleeding, next period = start + cycle length
    if (state.bleedingState == BleedingState.activeBleeding) {
      return state.bleedingStartDate!.add(
        Duration(days: state.getEffectiveCycleLength()),
      );
    }

    // If bleeding stopped, next = start + cycle length
    if (state.bleedingEndDate != null) {
      return state.bleedingStartDate!.add(
        Duration(days: state.getEffectiveCycleLength()),
      );
    }

    return DateTime.now().add(Duration(days: 14));
  }

  /// Calculate next period end date
  static DateTime getNextPeriodEnd(CycleState state) {
    final nextStart = getNextPeriodStart(state);
    return nextStart.add(
      Duration(days: state.getEffectiveBleedingLength() - 1),
    );
  }

  /// Calculate ovulation date (14 days before next period)
  static DateTime getOvulationDate(CycleState state) {
    final nextStart = getNextPeriodStart(state);
    return nextStart.subtract(const Duration(days: 14));
  }

  /// Calculate fertile window (5 days before ovulation, including ovulation day)
  static DateRange getFertileWindow(CycleState state) {
    final ovulation = getOvulationDate(state);
    return DateRange(
      start: ovulation.subtract(const Duration(days: 5)),
      end: ovulation,
    );
  }

  /// Helper: Normalize a date to midnight for comparison
  static DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Helper: Check if a date is within a range (inclusive)
  static bool _isInRange(DateTime date, DateTime start, DateTime end) {
    final d = _normalize(date);
    final s = _normalize(start);
    final e = _normalize(end);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  /// Determine day type for calendar rendering
  ///
  /// Rendering priority (as per spec):
  /// 1. Today highlight (handled by UI, not here)
  /// 2. Confirmed bleeding days (solid red)
  /// 3. Active bleeding days (animated / live red)
  /// 4. Predicted bleeding days (light red / dotted)
  /// 5. Ovulation window
  /// 6. Fertile window
  /// 7. Normal
  static DayType getDayType(DateTime date, CycleState state) {
    final normalizedDate = _normalize(date);

    // ========== 1. CHECK ALL HISTORICAL CONFIRMED BLEEDING DAYS ==========
    // This ensures past confirmed periods are always shown correctly
    for (final cycle in state.confirmedCycles) {
      if (cycle.cycleEndDate != null) {
        if (_isInRange(
          normalizedDate,
          cycle.cycleStartDate,
          cycle.cycleEndDate!,
        )) {
          return DayType.period;
        }
      }
    }

    // ========== 2. CURRENT CONFIRMED BLEEDING (start and end marked) ==========
    if (state.bleedingStartDate != null && state.bleedingEndDate != null) {
      if (_isInRange(
        normalizedDate,
        state.bleedingStartDate!,
        state.bleedingEndDate!,
      )) {
        return DayType.period;
      }
    }

    // ========== 3. ACTIVE BLEEDING (ongoing, no end yet) ==========
    if (state.isActiveBleeding &&
        state.bleedingStartDate != null &&
        state.bleedingEndDate == null) {
      final start = _normalize(state.bleedingStartDate!);
      // For active bleeding, show from start to today (or start + average)
      final today = _normalize(DateTime.now());
      final provisionalEnd = start.add(
        Duration(days: state.getEffectiveBleedingLength() - 1),
      );

      // Use whichever is later: today or provisional end
      final effectiveEnd = today.isAfter(provisionalEnd)
          ? today
          : provisionalEnd;

      if (_isInRange(normalizedDate, start, effectiveEnd)) {
        return DayType.activePeriod;
      }
    }

    // ========== 4. PREDICTED BLEEDING ==========
    // Only show predictions when not currently bleeding
    if (!state.isActiveBleeding || state.bleedingEndDate != null) {
      final nextStart = getNextPeriodStart(state);
      final nextEnd = getNextPeriodEnd(state);

      if (_isInRange(normalizedDate, nextStart, nextEnd)) {
        return DayType.predictedPeriod;
      }
    }

    // ========== 5. OVULATION ==========
    final ovulation = getOvulationDate(state);
    if (_normalize(ovulation).isAtSameMomentAs(normalizedDate)) {
      return DayType.ovulation;
    }

    // ========== 6. FERTILE WINDOW ==========
    final fertile = getFertileWindow(state);
    // Exclude ovulation day itself (already handled above)
    if (_isInRange(normalizedDate, fertile.start, fertile.end) &&
        !_normalize(ovulation).isAtSameMomentAs(normalizedDate)) {
      return DayType.fertile;
    }

    return DayType.normal;
  }
}

/// ==================== ENUMS & HELPERS ====================

enum DayType {
  period, // Confirmed bleeding (solid red)
  activePeriod, // Currently ongoing bleeding (animated/live red)
  predictedPeriod, // Predicted bleeding (light red)
  ovulation, // Ovulation day (purple)
  fertile, // Fertile window (green)
  normal, // No prediction
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}
