import 'cycle_state.dart';

/// ===================================================================
/// PREDICTION ENGINE - ADVANCED CYCLE CALCULATIONS
/// 
/// This engine provides scientifically accurate menstrual cycle 
/// predictions based on:
/// 1. User's cycle history (most recent 3 cycles weighted at 60%)
/// 2. Older cycle data (weighted at 40%)
/// 3. Cycle length variations (typically 21-35 days)
/// 4. Bleeding length variations (typically 2-10 days)
/// 5. Ovulation (typically occurs 14 days BEFORE next period)
/// 6. Fertile window (5-6 days before ovulation + ovulation day)
/// 
/// Medical Facts:
/// - Ovulation occurs ~14 days before next period start
/// - Sperm can survive 3-5 days
/// - Egg survives 12-24 hours
/// - Fertile window: typically 5 days before ovulation + ovulation day
/// - Most accurate predictions come from confirming periods with start/end dates
/// ===================================================================

class PredictionEngine {
  /// Calculate next period start date based on state
  /// Uses the most recent confirmed period as base
  static DateTime getNextPeriodStart(CycleState state) {
    // If no period has been recorded, default to 14 days from now
    if (state.bleedingStartDate == null && state.cycleHistory.isEmpty) {
      return DateTime.now().add(const Duration(days: 14));
    }

    // Use the most recent cycle start date as reference
    DateTime? lastPeriodStart = state.bleedingStartDate;
    
    // If no active period, get it from history
    if (lastPeriodStart == null && state.cycleHistory.isNotEmpty) {
      lastPeriodStart = state.cycleHistory.last.cycleStartDate;
    }

    if (lastPeriodStart == null) {
      return DateTime.now().add(const Duration(days: 14));
    }

    // Get effective cycle length (weighted average from history)
    final cycleLength = state.getEffectiveCycleLength();

    // Calculate: last period start + cycle length = next period start
    return lastPeriodStart.add(Duration(days: cycleLength));
  }

  /// Calculate next period end date
  /// Based on effective bleeding length from history
  static DateTime getNextPeriodEnd(CycleState state) {
    final nextStart = getNextPeriodStart(state);
    final bleedingLength = state.getEffectiveBleedingLength();
    
    // Period end = start date + bleeding length - 1 (because start day counts as day 1)
    return nextStart.add(Duration(days: bleedingLength - 1));
  }

  /// Calculate ovulation date (most fertile day)
  /// Ovulation occurs approximately 14 days BEFORE the next period starts
  /// (More precisely: 12-16 days, but 14 is the medical standard)
  static DateTime getOvulationDate(CycleState state) {
    final nextStart = getNextPeriodStart(state);
    // Standard: 14 days before next period
    return nextStart.subtract(const Duration(days: 14));
  }

  /// Calculate fertile window
  /// Medical consensus: 5 days before ovulation + day of ovulation
  /// This is when conception is most likely
  /// 
  /// Why this matters:
  /// - Sperm can survive 3-5 days in female reproductive tract
  /// - Egg survives only 12-24 hours after ovulation
  /// - Fertile window = best chance for conception
  static DateRange getFertileWindow(CycleState state) {
    final ovulation = getOvulationDate(state);
    
    // Start: 5 days before ovulation
    final start = ovulation.subtract(const Duration(days: 5));
    
    // End: day of ovulation
    final end = ovulation;
    
    return DateRange(start: start, end: end);
  }

  /// Helper: Normalize a date to midnight for accurate date comparison
  static DateTime _normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Helper: Check if a date falls within a range (inclusive on both ends)
  static bool _isInRange(DateTime date, DateTime start, DateTime end) {
    final d = _normalize(date);
    final s = _normalize(start);
    final e = _normalize(end);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  /// ===================================================================
  /// DETERMINE DAY TYPE - Core logic for calendar rendering
  /// 
  /// Rendering Priority (importance order):
  /// 1. Confirmed historical bleeding (user confirmed with start & end)
  /// 2. Active bleeding (period in progress - user marked start)
  /// 3. Predicted bleeding (algorithm predicts next period)
  /// 4. Ovulation day (most fertile single day)
  /// 5. Fertile window (5 days before ovulation)
  /// 6. Normal (no special significance)
  /// ===================================================================
  static DayType getDayType(DateTime date, CycleState state) {
    final normalizedDate = _normalize(date);

    // ========== 1. CONFIRMED HISTORICAL BLEEDING ==========
    // Check all previously confirmed periods from history
    // These are 100% accurate (user confirmed them)
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

    // ========== 2. CURRENT CONFIRMED BLEEDING ==========
    // User has marked both start AND end for current/recent period
    if (state.bleedingStartDate != null && state.bleedingEndDate != null) {
      if (_isInRange(
        normalizedDate,
        state.bleedingStartDate!,
        state.bleedingEndDate!,
      )) {
        return DayType.period;
      }
    }

    // ========== 3. ACTIVE BLEEDING ==========
    // Period is happening now (user marked start, but not end yet)
    if (state.isActiveBleeding &&
        state.bleedingStartDate != null &&
        state.bleedingEndDate == null) {
      final start = _normalize(state.bleedingStartDate!);
      final today = _normalize(DateTime.now());
      
      // Estimate when period will end based on average bleeding length
      final provisionalEnd = start.add(
        Duration(days: state.getEffectiveBleedingLength() - 1),
      );

      // Show active period from start to today (or provisional end if in future)
      final effectiveEnd = today.isAfter(provisionalEnd)
          ? today
          : provisionalEnd;

      if (_isInRange(normalizedDate, start, effectiveEnd)) {
        return DayType.activePeriod;
      }
    }

    // ========== 4. PREDICTED BLEEDING ==========
    // Only show next period prediction if not currently bleeding
    if (!state.isActiveBleeding || state.bleedingEndDate != null) {
      final nextStart = getNextPeriodStart(state);
      final nextEnd = getNextPeriodEnd(state);

      // Only show prediction for future dates or today
      final now = _normalize(DateTime.now());
      if (nextStart.isAtSameMomentAs(now) || nextStart.isAfter(now) || 
          (nextEnd.isAtSameMomentAs(now) || nextEnd.isAfter(now))) {
        if (_isInRange(normalizedDate, nextStart, nextEnd)) {
          return DayType.predictedPeriod;
        }
      }
    }

    // ========== 5. OVULATION DAY ==========
    // Most fertile single day of the cycle
    final ovulation = getOvulationDate(state);
    if (_normalize(ovulation).isAtSameMomentAs(normalizedDate)) {
      return DayType.ovulation;
    }

    // ========== 6. FERTILE WINDOW ==========
    // 5 days before ovulation through day of ovulation
    final fertile = getFertileWindow(state);
    
    // Exclude ovulation day (already marked as ovulation above)
    // So fertile window is the 5 days BEFORE ovulation
    final fertileDaysOnly = DateRange(
      start: fertile.start,
      end: fertile.end.subtract(const Duration(days: 1)), // Exclude ovulation day
    );
    
    if (_isInRange(normalizedDate, fertileDaysOnly.start, fertileDaysOnly.end)) {
      return DayType.fertile;
    }

    // ========== 7. NORMAL DAY ==========
    // No prediction applies
    return DayType.normal;
  }

  /// ===================================================================
  /// ADVANCED PREDICTIVE ANALYTICS
  /// Use this for personalized insights beyond calendar display
  /// ===================================================================

  /// Get days until next period
  static int getDaysUntilNextPeriod(CycleState state) {
    final nextStart = getNextPeriodStart(state);
    final today = DateTime.now();
    return nextStart.difference(today).inDays;
  }

  /// Get current cycle day (1 = first day of period)
  static int getCurrentCycleDay(CycleState state) {
    DateTime baseDate = state.bleedingStartDate ?? 
        (state.cycleHistory.isNotEmpty ? state.cycleHistory.last.cycleStartDate : DateTime.now());
    
    final today = _normalize(DateTime.now());
    final base = _normalize(baseDate);
    final diff = today.difference(base).inDays;
    
    final cycleLength = state.getEffectiveCycleLength();
    
    // Safe modulo: ensures positive result
    final cycleDay = ((diff % cycleLength) + cycleLength) % cycleLength + 1;
    
    return cycleDay;
  }

  /// Predict cycle statistics
  static CycleStatistics getPredictedStatistics(CycleState state) {
    return CycleStatistics(
      averageCycleLength: state.getEffectiveCycleLength(),
      averageBleedingLength: state.getEffectiveBleedingLength(),
      nextPeriodStart: getNextPeriodStart(state),
      nextPeriodEnd: getNextPeriodEnd(state),
      ovulationDate: getOvulationDate(state),
      fertileWindowStart: getFertileWindow(state).start,
      fertileWindowEnd: getFertileWindow(state).end,
      currentCycleDay: getCurrentCycleDay(state),
      daysUntilNextPeriod: getDaysUntilNextPeriod(state),
    );
  }
}

/// ===================================================================
/// DATA STRUCTURES
/// ===================================================================

enum DayType {
  period, // Confirmed bleeding (solid red)
  activePeriod, // Currently ongoing bleeding (animated/live red)
  predictedPeriod, // Predicted bleeding (light red)
  ovulation, // Ovulation day (purple) - most fertile
  fertile, // Fertile window (green) - 5 days before ovulation
  normal, // No prediction
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  /// Get the duration of this range
  int getDays() {
    return end.difference(start).inDays + 1;
  }
}

/// Container for cycle statistics
class CycleStatistics {
  final int averageCycleLength;
  final int averageBleedingLength;
  final DateTime nextPeriodStart;
  final DateTime nextPeriodEnd;
  final DateTime ovulationDate;
  final DateTime fertileWindowStart;
  final DateTime fertileWindowEnd;
  final int currentCycleDay;
  final int daysUntilNextPeriod;

  CycleStatistics({
    required this.averageCycleLength,
    required this.averageBleedingLength,
    required this.nextPeriodStart,
    required this.nextPeriodEnd,
    required this.ovulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
    required this.currentCycleDay,
    required this.daysUntilNextPeriod,
  });

  /// Format next period as readable string
  String getNextPeriodDisplay() {
    final format = _formatDate;
    return '${format(nextPeriodStart)} - ${format(nextPeriodEnd)}';
  }

  /// Helper function to format dates
  static String _formatDate(DateTime date) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month]} ${date.day}';
  }
}
