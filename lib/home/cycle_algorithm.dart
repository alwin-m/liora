enum DayType { period, fertile, ovulation, normal }

class CycleAlgorithm {
  final DateTime lastPeriod;
  final int cycleLength;
  final int periodLength;

  CycleAlgorithm({
    required this.lastPeriod,
    required this.cycleLength,
    required this.periodLength,
  });

  /// Get day type for a specific date
  /// Handles both past and future dates correctly
  DayType getType(DateTime date) {
    // Normalize the date to start of day (remove time component)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedLastPeriod = DateTime(
      lastPeriod.year,
      lastPeriod.month,
      lastPeriod.day,
    );

    // Calculate days since last period
    final diff = normalizedDate.difference(normalizedLastPeriod).inDays;

    // Handle past dates (before last period) - treat as normal
    if (diff < 0) return DayType.normal;

    // Get position in current/future cycle
    final dayInCycle = diff % cycleLength;

    // Period days: from day 0 to (periodLength - 1)
    if (dayInCycle < periodLength) {
      return DayType.period;
    }

    // Ovulation typically occurs around day 14 of a 28-day cycle
    // For other cycle lengths, proportionally calculate ovulation day
    final ovulationDay = (cycleLength * 0.5).round();
    if (dayInCycle == ovulationDay) {
      return DayType.ovulation;
    }

    // Fertile window: typically 5 days before ovulation to day after ovulation
    final fertileStart = (ovulationDay - 5).clamp(0, cycleLength);
    final fertileEnd = (ovulationDay + 1).clamp(0, cycleLength);

    if (dayInCycle >= fertileStart && dayInCycle <= fertileEnd) {
      return DayType.fertile;
    }

    return DayType.normal;
  }

  /// Get next period start date
  DateTime getNextPeriodStart() {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final lastPeriodNormalized = DateTime(
      lastPeriod.year,
      lastPeriod.month,
      lastPeriod.day,
    );

    final daysSinceLast = todayNormalized.difference(lastPeriodNormalized).inDays;
    final daysIntoCurrentCycle = daysSinceLast % cycleLength;
    final daysUntilNextPeriod = cycleLength - daysIntoCurrentCycle;

    return todayNormalized.add(Duration(days: daysUntilNextPeriod));
  }

  /// Get current cycle day (1-indexed)
  int getCurrentCycleDay() {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final lastPeriodNormalized = DateTime(
      lastPeriod.year,
      lastPeriod.month,
      lastPeriod.day,
    );

    final daysSinceLast = todayNormalized.difference(lastPeriodNormalized).inDays;
    return (daysSinceLast % cycleLength) + 1;
  }
}
