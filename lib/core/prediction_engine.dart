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
    if (state.bleedingState == BleedingState.ACTIVE_BLEEDING) {
      return state.bleedingStartDate!
          .add(Duration(days: state.getEffectiveCycleLength()));
    }

    // If bleeding stopped, next = start + cycle length
    if (state.bleedingEndDate != null) {
      return state.bleedingStartDate!
          .add(Duration(days: state.getEffectiveCycleLength()));
    }

    return DateTime.now().add(Duration(days: 14));
  }

  /// Calculate next period end date
  static DateTime getNextPeriodEnd(CycleState state) {
    final nextStart = getNextPeriodStart(state);
    return nextStart.add(
        Duration(days: state.getEffectiveBleedingLength() - 1));
  }

  /// Calculate ovulation date (14 days before next period)
  static DateTime getOvulationDate(CycleState state) {
    final nextStart = getNextPeriodStart(state);
    return nextStart.subtract(const Duration(days: 14));
  }

  /// Calculate fertile window (5 days before ovulation)
  static DateRange getFertileWindow(CycleState state) {
    final ovulation = getOvulationDate(state);
    return DateRange(
      start: ovulation.subtract(const Duration(days: 5)),
      end: ovulation.subtract(const Duration(days: 1)),
    );
  }

  /// Determine day type for calendar rendering
  static DayType getDayType(DateTime date, CycleState state) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // ========== CONFIRMED BLEEDING DAYS ==========
    if (state.bleedingStartDate != null && state.bleedingEndDate != null) {
      final start = DateTime(state.bleedingStartDate!.year,
          state.bleedingStartDate!.month, state.bleedingStartDate!.day);
      final end = DateTime(state.bleedingEndDate!.year,
          state.bleedingEndDate!.month, state.bleedingEndDate!.day);

      if (normalizedDate.isAfter(start.subtract(const Duration(days: 1))) &&
          normalizedDate.isBefore(end.add(const Duration(days: 1)))) {
        return DayType.period;
      }
    }

    // ========== ACTIVE BLEEDING (NO END YET) ==========
    if (state.bleedingState == BleedingState.ACTIVE_BLEEDING &&
        state.bleedingStartDate != null &&
        state.bleedingEndDate == null) {
      final start = DateTime(state.bleedingStartDate!.year,
          state.bleedingStartDate!.month, state.bleedingStartDate!.day);
      final provisionalEnd = start.add(
          Duration(days: state.getEffectiveBleedingLength() - 1));

      if (normalizedDate.isAfter(start.subtract(const Duration(days: 1))) &&
          normalizedDate.isBefore(provisionalEnd.add(const Duration(days: 1)))) {
        return DayType.period;
      }
    }

    // ========== PREDICTED BLEEDING ==========
    if (state.cycleHistory.isNotEmpty) {
      final nextStart = getNextPeriodStart(state);
      final nextEnd = getNextPeriodEnd(state);

      // Only show predicted if not already in confirmed/active
      if (state.bleedingState == BleedingState.NO_ACTIVE_BLEEDING ||
          state.bleedingEndDate != null) {
        final predStart = DateTime(nextStart.year, nextStart.month,
            nextStart.day);
        final predEnd = DateTime(nextEnd.year, nextEnd.month, nextEnd.day);

        if (normalizedDate
                .isAfter(predStart.subtract(const Duration(days: 1))) &&
            normalizedDate.isBefore(predEnd.add(const Duration(days: 1)))) {
          return DayType.predictedPeriod;
        }
      }
    }

    // ========== OVULATION ==========
    final ovulation = getOvulationDate(state);
    final ovulationDate = DateTime(ovulation.year, ovulation.month,
        ovulation.day);
    if (normalizedDate.isAtSameMomentAs(ovulationDate)) {
      return DayType.ovulation;
    }

    // ========== FERTILE WINDOW ==========
    final fertile = getFertileWindow(state);
    if (normalizedDate.isAfter(
            DateTime(fertile.start.year, fertile.start.month,
                fertile.start.day)) &&
        normalizedDate.isBefore(
            DateTime(fertile.end.year, fertile.end.month, fertile.end.day)
                .add(const Duration(days: 1)))) {
      return DayType.fertile;
    }

    return DayType.normal;
  }
}

/// ==================== ENUMS & HELPERS ====================

enum DayType {
  period, // Confirmed bleeding (solid red)
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
