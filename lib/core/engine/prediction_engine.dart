import '../services/storage_service.dart';

/// PredictionEngine - On-Device Cycle Prediction Algorithm
///
/// This engine runs entirely on the user's device.
/// No AI cloud models are used - fully deterministic.
///
/// Algorithm Logic:
/// 1. Store historical cycle start dates locally
/// 2. Compute rolling average of cycle length
/// 3. Adjust predictions using last 3 cycles
/// 4. Confidence score increases with data
class PredictionEngine {
  PredictionEngine._();
  static final PredictionEngine instance = PredictionEngine._();

  final StorageService _storage = StorageService.instance;

  /// Minimum cycles needed for reliable prediction
  static const int minCyclesForPrediction = 1;

  /// Maximum cycles used for averaging (recent data is more relevant)
  static const int maxCyclesForAverage = 6;

  /// Get current cycle state
  CycleState getCycleState() {
    final periodStarts = _storage.getPeriodStarts();
    final lmp = _storage.getLastMenstrualPeriod();
    final avgCycleLength = _storage.getAverageCycleLength();
    final avgPeriodLength = _storage.getAveragePeriodLength();

    // Combine LMP with logged period starts
    final allStarts = <DateTime>{
      if (lmp != null) lmp,
      ...periodStarts,
    }.toList()
      ..sort();

    if (allStarts.isEmpty) {
      return CycleState.noData();
    }

    final lastPeriodStart = allStarts.last;
    final today = DateTime.now();
    final daysSinceLastPeriod = today.difference(lastPeriodStart).inDays;

    // Calculate predicted cycle length from historical data
    final predictedCycleLength =
        _calculateAverageCycleLength(allStarts, avgCycleLength);
    final predictedPeriodLength =
        _calculateAveragePeriodLength(avgPeriodLength);

    // Determine current phase
    final phase = _determinePhase(
        daysSinceLastPeriod, predictedCycleLength, predictedPeriodLength);

    // Calculate next period date
    final nextPeriodDate =
        lastPeriodStart.add(Duration(days: predictedCycleLength));
    final daysUntilNextPeriod = nextPeriodDate.difference(today).inDays;

    // Calculate fertile window (typically days 10-17 of a 28-day cycle)
    final fertileWindowStart = lastPeriodStart
        .add(Duration(days: (predictedCycleLength * 0.35).round()));
    final fertileWindowEnd = lastPeriodStart
        .add(Duration(days: (predictedCycleLength * 0.6).round()));
    final ovulationDay = lastPeriodStart
        .add(Duration(days: (predictedCycleLength * 0.5).round()));

    // Calculate confidence
    final confidence = _calculateConfidence(allStarts.length);

    return CycleState(
      hasData: true,
      currentPhase: phase,
      currentCycleDay: daysSinceLastPeriod + 1,
      lastPeriodStart: lastPeriodStart,
      nextPeriodDate: nextPeriodDate,
      daysUntilNextPeriod: daysUntilNextPeriod,
      predictedCycleLength: predictedCycleLength,
      predictedPeriodLength: predictedPeriodLength,
      fertileWindowStart: fertileWindowStart,
      fertileWindowEnd: fertileWindowEnd,
      ovulationDay: ovulationDay,
      confidenceScore: confidence,
      cycleCount: allStarts.length,
    );
  }

  /// Get predictions for calendar display
  CalendarPredictions getCalendarPredictions({int monthsAhead = 3}) {
    final state = getCycleState();

    if (!state.hasData) {
      return CalendarPredictions.empty();
    }

    final predictions = CalendarPredictions(
      periodDays: <DateTime>[],
      predictedPeriodDays: <DateTime>[],
      fertileDays: <DateTime>[],
      ovulationDays: <DateTime>[],
    );

    // Get actual logged period days
    final loggedPeriodDays = _storage.getAllPeriodDays();
    predictions.periodDays.addAll(loggedPeriodDays);

    // Generate predicted period days for upcoming cycles
    final today = DateTime.now();
    var nextPeriodStart = state.nextPeriodDate!;

    for (int cycle = 0; cycle < monthsAhead; cycle++) {
      // Skip if this period start is in the past and not logged
      if (nextPeriodStart.isBefore(today)) {
        nextPeriodStart =
            nextPeriodStart.add(Duration(days: state.predictedCycleLength));
        continue;
      }

      // Add predicted period days
      for (int day = 0; day < state.predictedPeriodLength; day++) {
        final periodDay = nextPeriodStart.add(Duration(days: day));
        if (!predictions.periodDays.contains(periodDay)) {
          predictions.predictedPeriodDays.add(periodDay);
        }
      }

      // Add fertile window
      final fertileStart = nextPeriodStart
          .add(Duration(days: (state.predictedCycleLength * 0.35).round()));
      final fertileEnd = nextPeriodStart
          .add(Duration(days: (state.predictedCycleLength * 0.6).round()));

      for (var date = fertileStart;
          date.isBefore(fertileEnd) || date.isAtSameMomentAs(fertileEnd);
          date = date.add(const Duration(days: 1))) {
        predictions.fertileDays.add(date);
      }

      // Add ovulation day
      predictions.ovulationDays.add(
        nextPeriodStart
            .add(Duration(days: (state.predictedCycleLength * 0.5).round())),
      );

      nextPeriodStart =
          nextPeriodStart.add(Duration(days: state.predictedCycleLength));
    }

    return predictions;
  }

  /// Calculate day type for a specific date
  DayType getDayType(DateTime date) {
    final predictions = getCalendarPredictions();
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Check if it's a logged period day
    if (predictions.periodDays.any((d) => _isSameDay(d, normalizedDate))) {
      return DayType.period;
    }

    // Check if it's a predicted period day
    if (predictions.predictedPeriodDays
        .any((d) => _isSameDay(d, normalizedDate))) {
      return DayType.predictedPeriod;
    }

    // Check if it's an ovulation day
    if (predictions.ovulationDays.any((d) => _isSameDay(d, normalizedDate))) {
      return DayType.ovulation;
    }

    // Check if it's a fertile day
    if (predictions.fertileDays.any((d) => _isSameDay(d, normalizedDate))) {
      return DayType.fertile;
    }

    return DayType.normal;
  }

  /// Log a new period start
  Future<void> logPeriodStart(DateTime date) async {
    await _storage.savePeriodStart(date);
    await _storage.markPeriodDay(date, true);
  }

  /// Log a period day
  Future<void> logPeriodDay(DateTime date, bool isPeriod) async {
    await _storage.markPeriodDay(date, isPeriod);
  }

  /// End current period
  Future<void> endPeriod(DateTime date) async {
    // Mark subsequent days as not period
    // This is a no-op for now, as we track individual days
  }

  // =====================
  // PRIVATE CALCULATIONS
  // =====================

  int _calculateAverageCycleLength(
      List<DateTime> periodStarts, int defaultLength) {
    if (periodStarts.length < 2) {
      return defaultLength;
    }

    // Use the most recent cycles (up to maxCyclesForAverage)
    final recentStarts = periodStarts.length > maxCyclesForAverage
        ? periodStarts.sublist(periodStarts.length - maxCyclesForAverage)
        : periodStarts;

    // Calculate weighted average (more recent = higher weight)
    double weightedSum = 0;
    double totalWeight = 0;

    for (int i = 1; i < recentStarts.length; i++) {
      final cycleLength =
          recentStarts[i].difference(recentStarts[i - 1]).inDays;

      // Skip obviously invalid cycle lengths
      if (cycleLength < 15 || cycleLength > 60) continue;

      // Weight increases for more recent cycles
      final weight = i.toDouble();
      weightedSum += cycleLength * weight;
      totalWeight += weight;
    }

    if (totalWeight == 0) {
      return defaultLength;
    }

    return (weightedSum / totalWeight).round();
  }

  int _calculateAveragePeriodLength(int defaultLength) {
    // For now, use the user-provided default
    // Future: Calculate from logged period days
    return defaultLength;
  }

  CyclePhase _determinePhase(
      int daysSinceLastPeriod, int cycleLength, int periodLength) {
    if (daysSinceLastPeriod < periodLength) {
      return CyclePhase.menstrual;
    }

    final follicularEnd = (cycleLength * 0.35).round();
    if (daysSinceLastPeriod < follicularEnd) {
      return CyclePhase.follicular;
    }

    final ovulationEnd = (cycleLength * 0.5).round() + 1;
    if (daysSinceLastPeriod < ovulationEnd) {
      return CyclePhase.ovulatory;
    }

    return CyclePhase.luteal;
  }

  double _calculateConfidence(int cycleCount) {
    if (cycleCount < minCyclesForPrediction) return 0.0;
    if (cycleCount >= 12) return 1.0;

    // Confidence increases with more data
    // 1 cycle: 30%, 3 cycles: 50%, 6 cycles: 75%, 12+ cycles: 100%
    return 0.3 + (cycleCount / 12) * 0.7;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Cycle phases
enum CyclePhase {
  menstrual,
  follicular,
  ovulatory,
  luteal,
}

extension CyclePhaseExtension on CyclePhase {
  String get displayName {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual';
      case CyclePhase.follicular:
        return 'Follicular';
      case CyclePhase.ovulatory:
        return 'Ovulatory';
      case CyclePhase.luteal:
        return 'Luteal';
    }
  }

  String get description {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Your period days';
      case CyclePhase.follicular:
        return 'Energy is building';
      case CyclePhase.ovulatory:
        return 'Peak fertility window';
      case CyclePhase.luteal:
        return 'Winding down';
    }
  }

  String get emoji {
    switch (this) {
      case CyclePhase.menstrual:
        return '🌸';
      case CyclePhase.follicular:
        return '🌱';
      case CyclePhase.ovulatory:
        return '🌺';
      case CyclePhase.luteal:
        return '🌙';
    }
  }
}

/// Day types for calendar display
enum DayType {
  normal,
  period,
  predictedPeriod,
  fertile,
  ovulation,
}

/// Complete cycle state
class CycleState {
  final bool hasData;
  final CyclePhase currentPhase;
  final int currentCycleDay;
  final DateTime? lastPeriodStart;
  final DateTime? nextPeriodDate;
  final int daysUntilNextPeriod;
  final int predictedCycleLength;
  final int predictedPeriodLength;
  final DateTime? fertileWindowStart;
  final DateTime? fertileWindowEnd;
  final DateTime? ovulationDay;
  final double confidenceScore;
  final int cycleCount;

  const CycleState({
    required this.hasData,
    required this.currentPhase,
    required this.currentCycleDay,
    this.lastPeriodStart,
    this.nextPeriodDate,
    required this.daysUntilNextPeriod,
    required this.predictedCycleLength,
    required this.predictedPeriodLength,
    this.fertileWindowStart,
    this.fertileWindowEnd,
    this.ovulationDay,
    required this.confidenceScore,
    required this.cycleCount,
  });

  factory CycleState.noData() {
    return const CycleState(
      hasData: false,
      currentPhase: CyclePhase.follicular,
      currentCycleDay: 0,
      daysUntilNextPeriod: 0,
      predictedCycleLength: 28,
      predictedPeriodLength: 5,
      confidenceScore: 0.0,
      cycleCount: 0,
    );
  }

  String get daysUntilNextPeriodText {
    if (daysUntilNextPeriod <= 0) {
      return 'Period may have started';
    } else if (daysUntilNextPeriod == 1) {
      return 'Period expected tomorrow';
    } else {
      return '$daysUntilNextPeriod days until period';
    }
  }

  String get confidenceText {
    if (confidenceScore < 0.3) return 'Low';
    if (confidenceScore < 0.6) return 'Moderate';
    if (confidenceScore < 0.85) return 'Good';
    return 'High';
  }
}

/// Calendar predictions
class CalendarPredictions {
  final List<DateTime> periodDays;
  final List<DateTime> predictedPeriodDays;
  final List<DateTime> fertileDays;
  final List<DateTime> ovulationDays;

  CalendarPredictions({
    required this.periodDays,
    required this.predictedPeriodDays,
    required this.fertileDays,
    required this.ovulationDays,
  });

  factory CalendarPredictions.empty() {
    return CalendarPredictions(
      periodDays: [],
      predictedPeriodDays: [],
      fertileDays: [],
      ovulationDays: [],
    );
  }
}
